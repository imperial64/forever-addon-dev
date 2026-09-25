"""Build an apiDocs capture from Blizzard's documentation SOURCE instead of a live client.

tools/build_reference.py reads what `/fprobe docs dump` writes: the client loads
Blizzard_APIDocumentationGenerated, ForeverProbe projects every documented system
to plain data, and the SavedVariables flush carries it out. That needs a client,
a character and a /reload.

The same documentation ships as Lua source - the `Blizzard_APIDocumentationGenerated`
folder of an interface export, such as the Gethe/wow-ui-source mirror. This module
reads that folder and emits a file of exactly the shape the dumper writes, so the
generator runs on it unchanged. It is the same data by a different road, and it
lets a new build be diffed the day its source lands, before anyone has logged in.

What it reproduces, and why each part matters:

- **Load order.** Files are read in `.toc` order. A documentation table with no
  `Name` is not a system: `APIDocumentation:AddDocumentationTable` files its
  Tables under `APIDocumentation.tables`, attached to no system. Those go to
  `apiDocs.tables`, keyed by Name (a repeat suffixed `~2` and recorded), which is
  where the dumper puts them; everything else goes to `.systems` as before.
- **The projection.** `projectSystem` and friends in ForeverProbe.lua keep a fixed
  set of scalar fields plus every secrecy and gating key (`restriction_key` in
  build_reference.py), and drop all prose. Mirrored field for field below; a key
  the dumper does not keep must not appear here either, or the two roads would
  produce different references from the same build.
- **Load-time evaluation.** Where the source writes `Enum.X.Y` or
  `Constants.X.Y` in a kept field, the client holds the number; so does this,
  resolved from the documentation's own tables. See `Environment`.
- **Blizzard's renderers.** The dump stores `GetFullName`, `GetArgumentString`
  and `GetReturnString` output. Those are small string formatters in
  Blizzard_APIDocumentation's mixins, re-implemented here with their colour
  escapes intact.
- **Collision keys.** A system is keyed by Name, prefixed `ScriptObject:` for
  widget APIs, and a repeat is suffixed `~2` and recorded, as the dumper does.

The one thing a source export cannot say is which client build it describes, so
the caller passes the version, build and interface. The commit is recorded too.

Usage:
    python tools/docs_from_source.py <Blizzard_APIDocumentationGenerated dir> <out.lua>
        --version 1.60.1 --build 70009 --interface 16001
        [--commit <sha>] [--captured-at "2026-09-24 22:03:25"]

Then:
    python tools/build_reference.py <out.lua> --out <dir> ...
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path
from typing import Any

sys.path.insert(0, str(Path(__file__).resolve().parent))
# One definition of which keys are carried, shared with the generator.
from build_reference import restriction_key  # noqa: E402


# --------------------------------------------------------------------------
# A reader for the Lua the documentation files are written in.
#
# svlua.py deliberately parses only the SavedVariables subset and raises on
# anything else. The documentation source is a little wider: `local X = {...}`,
# bare-name keys, comments, semicolons, and a handful of values that are
# expressions rather than literals (`Enum.ForbiddenAspect.SetTexture`,
# `NUM_BAG_SLOTS`, `Enum.A.B + Enum.A.C`). The client evaluates those at load
# time. The reader carries them as an Expr holding the source text; the
# projection resolves the ones the documentation itself defines (Environment,
# below) and emits the rest as nil, reported rather than guessed at.
# `Default = MAX_RAID_MARKERS` is the precedent: it was nil in the client when
# the documentation loaded (the 69913 dump has no Default there).
# --------------------------------------------------------------------------

_TOKEN = re.compile(
    r"""
    (?P<space>    \s+ )
  | (?P<comment>  --\[(?P<eq>=*)\[.*?\](?P=eq)\] | --[^\n]* )
  | (?P<lstring>  \[(?P<leq>=*)\[.*?\](?P=leq)\] )
  | (?P<string>   " (?: \\. | \\\n | [^"\\\n] )* " | ' (?: \\. | \\\n | [^'\\\n] )* ' )
  | (?P<number>   0[xX][0-9a-fA-F]+ | (?: \d+\.?\d* | \.\d+ ) (?: [eE][-+]?\d+ )? )
  | (?P<name>     [A-Za-z_][A-Za-z0-9_]* )
  | (?P<punct>    \.\.|[\[\]{}=,;.:()+\-*/] )
    """,
    re.VERBOSE | re.DOTALL,
)

_ESCAPES = {
    "a": "\a", "b": "\b", "f": "\f", "n": "\n", "r": "\r", "t": "\t",
    "v": "\v", "\\": "\\", '"': '"', "'": "'", "\n": "\n",
}


class LuaSourceError(ValueError):
    """The documentation file used Lua this reader does not handle."""


class Expr:
    """A value the client would compute at load time. Kept as source text."""

    def __init__(self, text: str) -> None:
        self.text = text

    def __repr__(self) -> str:
        return f"Expr({self.text!r})"

    def __eq__(self, other: object) -> bool:
        return isinstance(other, Expr) and other.text == self.text

    def __hash__(self) -> int:
        return hash(("Expr", self.text))


def _unescape(body: str) -> str:
    if "\\" not in body:
        return body
    out: list[str] = []
    i, n = 0, len(body)
    while i < n:
        ch = body[i]
        if ch != "\\":
            out.append(ch)
            i += 1
            continue
        i += 1
        if i >= n:
            break
        nxt = body[i]
        if nxt.isdigit():
            digits = ""
            while i < n and body[i].isdigit() and len(digits) < 3:
                digits += body[i]
                i += 1
            out.append(chr(int(digits)))
            continue
        out.append(_ESCAPES.get(nxt, nxt))
        i += 1
    return "".join(out)


def _tokenize(text: str) -> list[tuple[str, str, int]]:
    tokens: list[tuple[str, str, int]] = []
    pos, end = 0, len(text)
    while pos < end:
        m = _TOKEN.match(text, pos)
        if not m:
            line = text.count("\n", 0, pos) + 1
            raise LuaSourceError(f"line {line}: cannot tokenize at {text[pos:pos + 40]!r}")
        # lastgroup is unreliable here because the long-bracket alternatives
        # carry inner groups, so the two that have them are tested by name.
        kind = m.lastgroup
        if m.group("comment") is not None:
            kind = "comment"
        elif m.group("lstring") is not None:
            kind = "lstring"
        if kind not in ("space", "comment"):
            tokens.append((kind, m.group(), pos))
        pos = m.end()
    return tokens


class _Reader:
    def __init__(self, text: str, source: str = "?") -> None:
        self.text = text
        self.source = source
        self.tokens = _tokenize(text)
        self.i = 0

    def fail(self, message: str) -> None:
        pos = self.tokens[self.i][2] if self.i < len(self.tokens) else len(self.text)
        line = self.text.count("\n", 0, pos) + 1
        raise LuaSourceError(f"{self.source}:{line}: {message}")

    def peek(self, ahead: int = 0) -> tuple[str, str, int] | None:
        j = self.i + ahead
        return self.tokens[j] if j < len(self.tokens) else None

    def take(self, value: str) -> None:
        tok = self.peek()
        if tok is None or tok[1] != value:
            self.fail(f"expected {value!r}, got {tok[1] if tok else 'end of file'!r}")
        self.i += 1

    def name(self) -> str:
        tok = self.peek()
        if tok is None or tok[0] != "name":
            self.fail(f"expected a name, got {tok[1] if tok else 'end of file'!r}")
        self.i += 1
        return tok[1]  # type: ignore[index]

    # -- expressions -------------------------------------------------------
    def expression(self) -> Any:
        start = self.i
        value = self.primary()
        is_expr = isinstance(value, Expr)
        while True:
            tok = self.peek()
            if tok and tok[0] == "punct" and tok[1] in ("+", "-", "*", "/", ".."):
                self.i += 1
                self.primary()
                is_expr = True
                continue
            break
        if is_expr:
            first = self.tokens[start][2]
            last_tok = self.tokens[self.i - 1]
            return Expr(self.text[first:last_tok[2] + len(last_tok[1])])
        return value

    def primary(self) -> Any:
        tok = self.peek()
        if tok is None:
            self.fail("unexpected end of file")
        kind, text, _ = tok  # type: ignore[misc]
        if text == "{":
            return self.table()
        if text == "-" and kind == "punct":
            self.i += 1
            inner = self.primary()
            if isinstance(inner, (int, float)) and not isinstance(inner, bool):
                return -inner
            return Expr("-" + (inner.text if isinstance(inner, Expr) else str(inner)))
        if text == "(":
            self.i += 1
            inner = self.expression()
            self.take(")")
            return inner if not isinstance(inner, Expr) else Expr(f"({inner.text})")
        self.i += 1
        if kind == "string":
            return _unescape(text[1:-1])
        if kind == "lstring":
            body = text[text.index("[", 1) + 1:text.rindex("]", 0, len(text) - 1)]
            return body[1:] if body.startswith("\n") else body
        if kind == "number":
            if text.lower().startswith("0x"):
                return int(text, 16)
            if re.fullmatch(r"\d+", text):
                return int(text)
            number = float(text)
            # Lua 5.1 has one number type, and the SavedVariables writer prints
            # an integral double without a decimal point.
            return int(number) if number.is_integer() else number
        if kind == "name":
            if text == "true":
                return True
            if text == "false":
                return False
            if text == "nil":
                return None
            # A global or a dotted path into one: Enum.X.Y, NUM_BAG_SLOTS.
            path = [text]
            while self.peek() and self.peek()[1] == "." and self.peek(1) and self.peek(1)[0] == "name":
                self.i += 1
                path.append(self.name())
            return Expr(".".join(path))
        self.fail(f"unexpected token {text!r}")

    def table(self) -> Any:
        self.take("{")
        named: dict[Any, Any] = {}
        positional: list[Any] = []
        while True:
            tok = self.peek()
            if tok is None:
                self.fail("unterminated table")
            if tok[1] == "}":
                self.i += 1
                break
            nxt = self.peek(1)
            if tok[1] == "[" and tok[0] == "punct":
                self.i += 1
                key = self.expression()
                self.take("]")
                self.take("=")
                named[key] = self.expression()
            elif tok[0] == "name" and nxt is not None and nxt[1] == "=":
                self.i += 2
                named[tok[1]] = self.expression()
            else:
                positional.append(self.expression())
            sep = self.peek()
            if sep and sep[1] in (",", ";"):
                self.i += 1
        # Lua semantics: positional entries occupy 1..n. A value of nil is
        # simply absent, which is what the dumper would see.
        for offset, item in enumerate(positional, start=1):
            named.setdefault(offset, item)
        named = {k: v for k, v in named.items() if v is not None}
        return _as_list(named)

    # -- statements --------------------------------------------------------
    def chunk(self) -> list[Any]:
        """Run the only statements a documentation file contains, and return
        the tables handed to APIDocumentation:AddDocumentationTable, in order."""
        locals_: dict[str, Any] = {}
        added: list[Any] = []
        while self.peek() is not None:
            tok = self.peek()
            if tok[1] == ";":
                self.i += 1
                continue
            if tok[1] == "local":
                self.i += 1
                name = self.name()
                self.take("=")
                locals_[name] = self.expression()
                continue
            if tok[1] == "APIDocumentation":
                self.i += 1
                self.take(":")
                method = self.name()
                if method != "AddDocumentationTable":
                    self.fail(f"unhandled APIDocumentation:{method}")
                self.take("(")
                arg = self.expression()
                self.take(")")
                if isinstance(arg, Expr):
                    if arg.text not in locals_:
                        self.fail(f"AddDocumentationTable of unknown {arg.text!r}")
                    arg = locals_[arg.text]
                added.append(arg)
                continue
            self.fail(f"unhandled statement starting {tok[1]!r}")
        return added


def _as_list(items: dict[Any, Any]) -> Any:
    """{1: a, 2: b} -> [a, b], the way svlua reads the dumper's output."""
    if not items:
        return {}
    keys = list(items)
    if all(isinstance(k, int) and not isinstance(k, bool) for k in keys):
        ordered = sorted(keys)
        if ordered == list(range(1, len(ordered) + 1)):
            return [items[k] for k in ordered]
    return items


def _seq(value: Any) -> list[Any]:
    """What Lua's `for i = 1, #t` walks: the array part."""
    if isinstance(value, list):
        return value
    if isinstance(value, dict):
        out = []
        i = 1
        while i in value:
            out.append(value[i])
            i += 1
        return out
    return []


def read_documentation_file(path: Path) -> list[Any]:
    return _Reader(path.read_text(encoding="utf-8-sig"), path.name).chunk()


def toc_files(folder: Path) -> list[Path]:
    """The files the client loads, in the order it loads them."""
    tocs = sorted(folder.glob("*.toc"))
    if not tocs:
        raise FileNotFoundError(f"{folder}: no .toc")
    toc = next((t for t in tocs if t.stem == folder.name), tocs[0])
    files: list[Path] = []
    for raw in toc.read_text(encoding="utf-8-sig").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        # A load condition in brackets would need evaluating against the game
        # type. None exists on the builds this was written against; refuse
        # rather than include a file the client might not.
        if "[" in line:
            raise LuaSourceError(f"{toc.name}: conditional load line not handled: {line!r}")
        files.append(folder / line.replace("\\", "/"))
    return files


# --------------------------------------------------------------------------
# What the client evaluates at load time.
#
# `Enum.ForbiddenAspect.SetTexture` in the source is the number 2048 by the time
# the dumper sees it: the client defines Enum and Constants before the
# documentation loads. Where such an expression sits in a field the dumper
# keeps, the adapter has to produce the same number or the two roads diverge.
# It can, for the two tables the documentation itself defines - Enum.<T>.<M>
# (and Enum.<T>Meta.NumValues/MinValue/MaxValue) and Constants.<T>.<M> - and for
# + - * / over those. A bare global (NUM_BAG_SLOTS, MAX_RAID_MARKERS) is defined
# by FrameXML if at all, which the source cannot see; it is emitted as nil and
# reported, never guessed. On 69913 the one such global that reached a kept
# field, MAX_RAID_MARKERS, was nil in the client too.
# --------------------------------------------------------------------------

class Environment:
    def __init__(self) -> None:
        self.enums: dict[str, dict[str, Any]] = {}
        self.meta: dict[str, dict[str, Any]] = {}
        self.constants: dict[str, dict[str, Any]] = {}
        self._resolving: set[str] = set()

    def add_table(self, table: Any) -> None:
        if not isinstance(table, dict) or not isinstance(table.get("Name"), str):
            return
        name = table["Name"]
        if table.get("Type") == "Enumeration":
            self.enums.setdefault(name, {})
            for field in _seq(table.get("Fields")):
                if isinstance(field, dict) and isinstance(field.get("Name"), str):
                    self.enums[name][field["Name"]] = field.get("EnumValue")
            self.meta[name] = {k: table.get(k) for k in ("NumValues", "MinValue", "MaxValue")}
        for value in _seq(table.get("Values")):
            if isinstance(value, dict) and isinstance(value.get("Name"), str):
                self.constants.setdefault(name, {})[value["Name"]] = value.get("Value")

    @classmethod
    def from_documentation(cls, documentation: list[Any]) -> "Environment":
        env = cls()
        for doc in documentation:
            if isinstance(doc, dict):
                for table in _seq(doc.get("Tables")):
                    env.add_table(table)
        return env

    def lookup(self, path: str) -> Any:
        parts = path.split(".")
        if len(parts) != 3:
            return None
        root, table, member = parts
        if root == "Enum":
            if table in self.enums:
                value = self.enums[table].get(member)
            elif table.endswith("Meta") and table[:-4] in self.meta:
                value = self.meta[table[:-4]].get(member)
            else:
                return None
        elif root == "Constants":
            value = self.constants.get(table, {}).get(member)
        else:
            return None
        if isinstance(value, Expr):
            if path in self._resolving:  # a cycle would hang the client too
                return None
            self._resolving.add(path)
            try:
                return self.evaluate(value)
            finally:
                self._resolving.discard(path)
        return value

    def evaluate(self, expr: Expr) -> Any:
        """The value the client would hold, or None if the source cannot say."""
        try:
            tokens = _tokenize(expr.text)
        except LuaSourceError:
            return None
        pos = 0

        def peek() -> str | None:
            return tokens[pos][1] if pos < len(tokens) else None

        def primary() -> Any:
            nonlocal pos
            tok = tokens[pos] if pos < len(tokens) else None
            if tok is None:
                raise LuaSourceError("end of expression")
            pos += 1
            kind, text, _ = tok
            if text == "(":
                inner = additive()
                if peek() != ")":
                    raise LuaSourceError("unbalanced")
                pos += 1
                return inner
            if text == "-":
                inner = primary()
                return None if inner is None else -inner
            if kind == "number":
                return int(text, 16) if text.lower().startswith("0x") else (
                    int(text) if re.fullmatch(r"\d+", text) else float(text))
            if kind == "name":
                path = [text]
                while peek() == "." and pos + 1 < len(tokens) and tokens[pos + 1][0] == "name":
                    path.append(tokens[pos + 1][1])
                    pos += 2
                return self.lookup(".".join(path))
            raise LuaSourceError(f"unexpected {text!r}")

        def arith(op: str, a: Any, b: Any) -> Any:
            if not all(isinstance(x, (int, float)) and not isinstance(x, bool) for x in (a, b)):
                return None
            if op == "+":
                return a + b
            if op == "-":
                return a - b
            if op == "*":
                return a * b
            return a / b if b else None

        def term() -> Any:
            nonlocal pos
            value = primary()
            while peek() in ("*", "/"):
                op = peek()
                pos += 1
                value = arith(op, value, primary())
            return value

        def additive() -> Any:
            nonlocal pos
            value = term()
            while peek() in ("+", "-"):
                op = peek()
                pos += 1
                value = arith(op, value, term())
            return value

        try:
            value = additive()
        except LuaSourceError:
            return None
        if pos != len(tokens):
            return None
        # Lua 5.1 has one number type; the SavedVariables writer prints an
        # integral double without a decimal point.
        if isinstance(value, float) and value.is_integer():
            return int(value)
        return value


# --------------------------------------------------------------------------
# The projection - ForeverProbe.lua's projectSystem family, mirrored.
# --------------------------------------------------------------------------

class Projector:
    def __init__(self, env: Environment | None = None) -> None:
        self.env = env or Environment()
        # Expressions the client would have evaluated, found in a field the
        # dumper keeps, that the source alone cannot resolve.
        self.unevaluated: list[str] = []

    def scalar(self, value: Any, where: str = "") -> Any:
        if isinstance(value, Expr):
            resolved = self.env.evaluate(value)
            if resolved is None:
                self.unevaluated.append(f"{where}: {value.text}")
            return resolved
        if isinstance(value, (str, int, float, bool)):
            return value
        return None

    def plain(self, value: Any, where: str = "", depth: int = 0) -> Any:
        """A scalar, or a table of them, the way the dumper's plainValue copies
        it: nothing callable, nothing deeper than it needs to be."""
        if isinstance(value, (list, dict)):
            if depth >= 4:
                return None
            if isinstance(value, list):
                out = [p for p in (self.plain(v, where, depth + 1) for v in value) if p is not None]
                return out or None
            out_d = {k: p for k, p in ((k, self.plain(v, f"{where}.{k}", depth + 1))
                                       for k, v in value.items()) if p is not None}
            return out_d or None
        return self.scalar(value, where)

    def restriction_keys(self, entry: dict[str, Any], where: str) -> dict[str, Any]:
        return {k: self.plain(v, f"{where}.{k}") for k, v in entry.items() if restriction_key(k)}

    @staticmethod
    def _clean(record: dict[str, Any]) -> dict[str, Any]:
        return {k: v for k, v in record.items() if v is not None}

    def project_list(self, value: Any, fn) -> list[Any] | None:
        if not isinstance(value, (list, dict)):
            return None
        out = [p for p in (fn(item) for item in _seq(value)) if p is not None]
        return out or None

    def field(self, f: Any) -> dict[str, Any] | None:
        if not isinstance(f, dict):
            return None
        s = self.scalar
        return self._clean({
            **self.restriction_keys(f, "field"),
            "Name": s(f.get("Name"), "Name"),
            "Type": s(f.get("Type"), "Type"),
            "InnerType": s(f.get("InnerType"), "InnerType"),
            "Nilable": s(f.get("Nilable"), "Nilable"),
            "Default": s(f.get("Default"), "Default"),
            "Mixin": s(f.get("Mixin"), "Mixin"),
            "StrideIndex": s(f.get("StrideIndex"), "StrideIndex"),
            "EnumValue": s(f.get("EnumValue"), "EnumValue"),
        })

    def function(self, f: Any, system: dict[str, Any]) -> dict[str, Any] | None:
        if not isinstance(f, dict):
            return None
        s = self.scalar
        return self._clean({
            **self.restriction_keys(f, str(f.get("Name"))),
            "Name": s(f.get("Name"), "Name"),
            "Type": s(f.get("Type"), "Type"),
            # A function's own Namespace overrides its system's; "" is global.
            "Namespace": s(f.get("Namespace"), "Namespace"),
            "Arguments": self.project_list(f.get("Arguments"), self.field),
            "Returns": self.project_list(f.get("Returns"), self.field),
            "FullName": render_function_full_name(f, system, self.env),
            "ArgumentString": render_field_list(f.get("Arguments"), "55ddff", self.env),
            "ReturnString": render_field_list(f.get("Returns"), "55ddff", self.env),
        })

    def event(self, e: Any, system: dict[str, Any]) -> dict[str, Any] | None:
        if not isinstance(e, dict):
            return None
        s = self.scalar
        return self._clean({
            **self.restriction_keys(e, str(e.get("Name"))),
            "Name": s(e.get("Name"), "Name"),
            "LiteralName": s(e.get("LiteralName"), "LiteralName"),
            "Type": s(e.get("Type"), "Type"),
            "Payload": self.project_list(e.get("Payload"), self.field),
            "FullName": render_event_full_name(e, system, self.env),
        })

    def value(self, v: Any) -> dict[str, Any] | None:
        if not isinstance(v, dict):
            return None
        s = self.scalar
        name = v.get("Name")
        return self._clean({"Name": s(name, "Name"),
                            "Type": s(v.get("Type"), "Type"),
                            "Value": s(v.get("Value"), f"Value of {name}"),
                            "EnumValue": s(v.get("EnumValue"), "EnumValue")})

    def table(self, t: Any) -> dict[str, Any] | None:
        if not isinstance(t, dict):
            return None
        s = self.scalar
        return self._clean({
            "Name": s(t.get("Name"), "Name"),
            "Type": s(t.get("Type"), "Type"),
            "NumValues": s(t.get("NumValues"), "NumValues"),
            "MinValue": s(t.get("MinValue"), "MinValue"),
            "MaxValue": s(t.get("MaxValue"), "MaxValue"),
            "Fields": self.project_list(t.get("Fields"), self.field),
            "Values": self.project_list(t.get("Values"), self.value),
        })

    def system(self, sys_: Any) -> dict[str, Any] | None:
        if not isinstance(sys_, dict):
            return None
        s = self.scalar
        return self._clean({
            "Name": s(sys_.get("Name"), "Name"),
            "Namespace": s(sys_.get("Namespace"), "Namespace"),
            "Type": s(sys_.get("Type"), "Type"),
            "Functions": self.project_list(sys_.get("Functions"),
                                           lambda f: self.function(f, sys_)),
            "Events": self.project_list(sys_.get("Events"), lambda e: self.event(e, sys_)),
            "Tables": self.project_list(sys_.get("Tables"), self.table),
        })


# Blizzard_APIDocumentation's renderers, called the way the dumper calls them:
# no arguments, so optionals are decorated and colour codes are on. A nil name
# makes string.format raise in the client, the dumper's pcall swallows it, and
# the field is absent - hence None rather than "nil".

def _field_argument_string(field: Any, env: Environment | None = None) -> str | None:
    if not isinstance(field, dict) or not isinstance(field.get("Name"), str):
        return None
    # An Expr default counts only if the client would have had a value for it;
    # measured on 69913, `Default = MAX_RAID_MARKERS` arrived as nil.
    default = field.get("Default")
    if isinstance(default, Expr):
        default = env.evaluate(default) if env else None
    optional = default is not None or field.get("Nilable") is True
    prefix = "optional " if optional else ""
    return f"|cffffdd55{prefix}{field['Name']}|r"


def render_field_list(fields: Any, link_colour: str, env: Environment | None = None) -> str | None:
    if fields is None:
        return ""
    values = []
    for field in _seq(fields):
        rendered = _field_argument_string(field, env)
        if rendered is None:
            return None
        values.append(f"{rendered}|cff{link_colour}")
    return ", ".join(values)


def render_function_full_name(function: dict[str, Any], system: dict[str, Any],
                              env: Environment | None = None) -> str | None:
    # Blizzard's GetFullName prefixes the SYSTEM's namespace, even where the
    # function carries its own. Reproduced as written; the generator places
    # the page by the function's.
    name = function.get("Name")
    args = render_field_list(function.get("Arguments"), "55ddff", env)
    if not isinstance(name, str) or args is None:
        return None
    namespace = system.get("Namespace") if isinstance(system.get("Namespace"), str) else ""
    if namespace:
        return f"{namespace}.{name}({args})"
    return f"{name}({args})"


def render_event_full_name(event: dict[str, Any], system: dict[str, Any],
                           env: Environment | None = None) -> str | None:
    name = event.get("Name")
    payload = render_field_list(event.get("Payload"), "77ff22", env)
    if not isinstance(name, str) or payload is None or not isinstance(system.get("Name"), str):
        return None
    return f"Event.{system['Name']}.{name} -> {payload}"


def build_api_docs(folder: Path, client: dict[str, Any], captured_at: str | None = None,
                   source: dict[str, Any] | None = None) -> tuple[dict[str, Any], list[str]]:
    """The `apiDocs` table the dumper would have written, and any warnings."""
    documentation = [doc for path in toc_files(folder) for doc in read_documentation_file(path)]
    projector = Projector(Environment.from_documentation(documentation))
    systems: dict[str, Any] = {}
    shared: dict[str, Any] = {}
    collisions: list[str] = []
    table_collisions: list[str] = []
    n_sys = n_fn = n_ev = n_tb = failed = 0
    for doc in documentation:
        if not isinstance(doc, dict):
            continue
        if doc.get("Name") is None:
            # AddDocumentationTable files a nameless table's Tables under
            # APIDocumentation.tables, attached to no system. The dumper walks
            # them there, in load order, keyed by Name the way systems are.
            for table in _seq(doc.get("Tables")):
                projected_table = projector.table(table)
                if not projected_table or not projected_table.get("Name"):
                    continue
                key = projected_table["Name"]
                if key in shared:
                    table_collisions.append(key)
                    n = 2
                    while f"{key}~{n}" in shared:
                        n += 1
                    key = f"{key}~{n}"
                shared[key] = projected_table
            continue
        projected = projector.system(doc)
        if not projected or not projected.get("Name"):
            failed += 1
            continue
        key = projected["Name"]
        if projected.get("Type") == "ScriptObject":
            key = "ScriptObject:" + key
        if key in systems:
            collisions.append(key)
            n = 2
            while f"{key}~{n}" in systems:
                n += 1
            key = f"{key}~{n}"
        systems[key] = projected
        n_sys += 1
        n_fn += len(projected.get("Functions") or [])
        n_ev += len(projected.get("Events") or [])
        n_tb += len(projected.get("Tables") or [])
    docs: dict[str, Any] = {
        "client": {k: v for k, v in client.items() if v is not None},
        "systems": systems,
        "tables": shared,
        "counts": {"systems": n_sys, "stored": len(systems), "functions": n_fn,
                   "events": n_ev, "tables": n_tb, "failed": failed,
                   "collisions": collisions, "sharedTables": len(shared),
                   "tableCollisions": table_collisions},
    }
    if captured_at:
        docs["capturedAt"] = captured_at
    if source:
        docs["source"] = source
    warnings = [f"expression in a kept field that the source cannot resolve, emitted as"
                f" nil (a global the client may define; MAX_RAID_MARKERS was nil on 69913):"
                f" {w}" for w in projector.unevaluated]
    return docs, warnings


# --------------------------------------------------------------------------
# Writing it back out as the SavedVariables the generator already reads.
# --------------------------------------------------------------------------

def _lua_string(text: str) -> str:
    out = []
    for ch in text:
        if ch == "\\":
            out.append("\\\\")
        elif ch == '"':
            out.append('\\"')
        elif ch == "\n":
            out.append("\\n")
        elif ch == "\r":
            out.append("\\r")
        elif ord(ch) < 32:
            out.append(f"\\{ord(ch):03d}")
        else:
            out.append(ch)
    return '"' + "".join(out) + '"'


def _lua_value(value: Any, lines: list[str]) -> str | None:
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, int):
        return str(value)
    if isinstance(value, float):
        return repr(value)
    if isinstance(value, str):
        return _lua_string(value)
    if isinstance(value, (list, dict)):
        lines.append("{")
        items = enumerate(value, start=1) if isinstance(value, list) else sorted(
            value.items(), key=lambda kv: (not isinstance(kv[0], int), str(kv[0])))
        for key, item in items:
            if isinstance(value, list):
                prefix = ""
            elif isinstance(key, int):
                prefix = f"[{key}] = "
            else:
                prefix = f"[{_lua_string(str(key))}] = "
            inline = _lua_value(item, lines_nested := [])
            if inline is None:
                lines.append(prefix + lines_nested[0])
                lines.extend(lines_nested[1:])
            else:
                lines.append(prefix + inline + ",")
        lines.append("},")
        return None
    raise TypeError(f"cannot serialize {type(value).__name__}")


def to_savedvariables(docs: dict[str, Any]) -> str:
    lines: list[str] = []
    _lua_value({"apiDocs": docs}, lines)
    lines[0] = "ForeverProbeDB = {"
    lines[-1] = "}"
    return "\n".join(lines) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("source", type=Path, help="the Blizzard_APIDocumentationGenerated folder")
    parser.add_argument("out", type=Path, help="capture file to write (.lua)")
    parser.add_argument("--version", required=True, help="client version, e.g. 1.60.1")
    parser.add_argument("--build", required=True, help="client build, e.g. 70009")
    parser.add_argument("--interface", required=True, help="interface number, e.g. 16001")
    parser.add_argument("--date", default=None, help="GetBuildInfo date string, if known")
    parser.add_argument("--commit", default=None, help="source commit, recorded for provenance")
    parser.add_argument("--repo", default="Gethe/wow-ui-source")
    parser.add_argument("--captured-at", default=None,
                        help="stamp for BUILD.md's `generated` row; the commit date keeps "
                             "a rerun deterministic")
    args = parser.parse_args()

    client = {"version": args.version, "build": str(args.build),
              "interface": str(args.interface), "date": args.date}
    source = {"repo": args.repo, "commit": args.commit} if args.commit else None
    docs, warnings = build_api_docs(args.source, client, args.captured_at, source)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(to_savedvariables(docs), encoding="utf-8", newline="\n")
    counts = docs["counts"]
    print(f"{args.out}: {counts['stored']} systems, {counts['functions']} functions, "
          f"{counts['events']} events, {counts['tables']} tables, "
          f"{counts['sharedTables']} shared tables"
          + (f"; collisions {', '.join(counts['collisions'])}" if counts["collisions"] else "")
          + (f"; shared-table collisions {', '.join(counts['tableCollisions'])}"
             if counts["tableCollisions"] else ""))
    for warning in warnings:
        print(f"  WARNING: {warning}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
