"""Parse WoW SavedVariables into Python data.

SavedVariables is Lua, but only a very restricted dialect of it: the client writes
one global assignment per variable, and the values are nothing but tables,
strings, numbers, booleans and nil. No expressions, no function calls, no
comments. That is small enough to parse directly, which is the point of this
module.

The alternative was to shell out to luajit, which this repo already does for
syntax-gating the addon. But the plugin ships to people regenerating the
reference against their own client, and requiring them to install a Lua runtime
to read a data file is a poor trade. Pure Python keeps the regenerate path to
"you have Python".

Only what the format actually contains is implemented. Anything outside that
raises rather than guessing, because a silent misparse of an API reference is
worse than a crash.
"""

from __future__ import annotations

import re
from typing import Any

# Tokens, in priority order. Longest and most specific first so that `--` inside
# a string is never mistaken for anything else (the client does not write
# comments, but being order-correct costs nothing).
_TOKEN = re.compile(
    r"""
    (?P<space>    \s+ )
  | (?P<string>   " (?: \\. | [^"\\] )* " )
  | (?P<number>   -? (?: \d+\.?\d* | \.\d+ ) (?: [eE][-+]?\d+ )? )
  | (?P<name>     [A-Za-z_][A-Za-z0-9_]* )
  | (?P<punct>    [\[\]{}=,] )
    """,
    re.VERBOSE,
)

# Lua string escapes the client emits. \ddd is decimal, not octal.
_ESCAPES = {
    "a": "\a", "b": "\b", "f": "\f", "n": "\n",
    "r": "\r", "t": "\t", "v": "\v", "\\": "\\",
    '"': '"', "'": "'", "\n": "\n",
}


def _unescape(raw: str) -> str:
    """Turn a quoted Lua string literal into its value."""
    body = raw[1:-1]
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


class LuaSyntaxError(ValueError):
    """The file was not the SavedVariables subset this module handles."""


def _tokenize(text: str) -> list[tuple[str, str, int]]:
    tokens: list[tuple[str, str, int]] = []
    pos, end = 0, len(text)
    while pos < end:
        m = _TOKEN.match(text, pos)
        if not m:
            line = text.count("\n", 0, pos) + 1
            raise LuaSyntaxError(
                f"line {line}: cannot tokenize at {text[pos:pos + 40]!r}"
            )
        kind = m.lastgroup
        assert kind is not None
        if kind != "space":
            tokens.append((kind, m.group(), pos))
        pos = m.end()
    return tokens


class _Parser:
    def __init__(self, tokens: list[tuple[str, str, int]], text: str) -> None:
        self.tokens = tokens
        self.text = text
        self.i = 0

    def _fail(self, message: str) -> None:
        pos = self.tokens[self.i][2] if self.i < len(self.tokens) else len(self.text)
        line = self.text.count("\n", 0, pos) + 1
        raise LuaSyntaxError(f"line {line}: {message}")

    def peek(self) -> tuple[str, str, int] | None:
        return self.tokens[self.i] if self.i < len(self.tokens) else None

    def take(self, value: str) -> None:
        tok = self.peek()
        if tok is None or tok[1] != value:
            got = tok[1] if tok else "end of file"
            self._fail(f"expected {value!r}, got {got!r}")
        self.i += 1

    def value(self) -> Any:
        tok = self.peek()
        if tok is None:
            self._fail("unexpected end of file")
        kind, text, _ = tok  # type: ignore[misc]
        if text == "{":
            return self.table()
        self.i += 1
        if kind == "string":
            return _unescape(text)
        if kind == "number":
            # Lua has one number type; keep ints as ints so keys and counts read
            # naturally in the generated output.
            if re.fullmatch(r"-?\d+", text):
                return int(text)
            return float(text)
        if kind == "name":
            if text == "true":
                return True
            if text == "false":
                return False
            if text == "nil":
                return None
            self._fail(f"unexpected identifier {text!r}")
        self._fail(f"unexpected token {text!r}")

    def table(self) -> Any:
        self.take("{")
        items: dict[Any, Any] = {}
        positional: list[Any] = []
        while True:
            tok = self.peek()
            if tok is None:
                self._fail("unterminated table")
            if tok[1] == "}":
                self.i += 1
                break
            if tok[1] == "[":
                # ["key"] = value  or  [1] = value
                self.i += 1
                key = self.value()
                self.take("]")
                self.take("=")
                items[key] = self.value()
            else:
                # A bare positional entry. The client writes these for arrays.
                positional.append(self.value())
            nxt = self.peek()
            if nxt and nxt[1] == ",":
                self.i += 1
        if positional and not items:
            return positional
        if positional:
            # Mixed table: fold the positional part onto 1..n, Lua-style, so
            # nothing is silently dropped.
            for offset, item in enumerate(positional, start=1):
                items.setdefault(offset, item)
        return _maybe_list(items)


def _maybe_list(items: dict[Any, Any]) -> Any:
    """Turn {1: a, 2: b, ...} into [a, b, ...].

    The client writes arrays as consecutive integer keys from 1. Returning them
    as Python lists is what makes the generated output natural to work with; a
    table with any non-integer key, or a gap, stays a dict.
    """
    if not items:
        return {}
    keys = list(items)
    if all(isinstance(k, int) for k in keys):
        ordered = sorted(keys)
        if ordered == list(range(1, len(ordered) + 1)):
            return [items[k] for k in ordered]
    return items


def parse(text: str) -> dict[str, Any]:
    """Parse a SavedVariables file into {global_name: value}."""
    tokens = _tokenize(text)
    parser = _Parser(tokens, text)
    globals_: dict[str, Any] = {}
    while parser.peek() is not None:
        tok = parser.peek()
        assert tok is not None
        if tok[0] != "name":
            parser._fail(f"expected a global name, got {tok[1]!r}")
        name = tok[1]
        parser.i += 1
        parser.take("=")
        globals_[name] = parser.value()
    return globals_


def parse_file(path: str) -> dict[str, Any]:
    with open(path, "r", encoding="utf-8", errors="replace") as handle:
        return parse(handle.read())


if __name__ == "__main__":
    import json
    import sys

    if len(sys.argv) < 2:
        raise SystemExit("usage: svlua.py <SavedVariables.lua> [global] > out.json")
    data = parse_file(sys.argv[1])
    if len(sys.argv) > 2:
        data = data[sys.argv[2]]
    json.dump(data, sys.stdout, indent=1, ensure_ascii=False, sort_keys=True)
