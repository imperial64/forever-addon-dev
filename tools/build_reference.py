"""Turn a ForeverProbe API capture into the shipped Markdown reference.

The design rule is that Claude should be able to compute a path from a symbol
name and read exactly one small file. So every symbol gets its own page at a
predictable location, and nothing here produces a file large enough that reading
it is a mistake:

    reference/api/namespaces/C_AuctionHouse/SendBrowseQuery.md
    reference/api/globals/G/GetBuildInfo.md
    reference/api/events/A/AUCTION_HOUSE_SHOW.md
    reference/api/structures/AuctionHouseBrowseQuery.md
    reference/api/enums/Enum.AuctionHouseFilter.md

Determinism is load-bearing. Sort order is stable, formatting is stable, and no
per-symbol page carries a timestamp - the capture date lives only in BUILD.md.
That way regenerating against a newer client produces a git diff that IS the
patch delta, which is worth more than any changelog written by hand.

Usage:
    python tools/build_reference.py data/<capture>.lua [--out reference/api]
"""

from __future__ import annotations

import argparse
import json
import re
import shutil
import sys
from pathlib import Path
from typing import Any

try:
    import yaml
except ImportError:  # pragma: no cover - the reference still builds without it
    yaml = None

sys.path.insert(0, str(Path(__file__).resolve().parent))
import svlua  # noqa: E402

# Blizzard's own rendered signatures carry UI colour escapes - |cffffdd55index|r
# and friends - because they are written for the in-game /api window. They are
# kept in the capture for fidelity and stripped here, at generation time.
_COLOUR = re.compile(r"\|c[0-9a-fA-F]{8}|\|r")

# Windows will not create these as filenames, and several API names are
# case-variants of each other, which a case-insensitive filesystem also cannot
# hold. Both are handled by _safe_name.
_RESERVED = {
    "CON", "PRN", "AUX", "NUL",
    *(f"COM{i}" for i in range(1, 10)),
    *(f"LPT{i}" for i in range(1, 10)),
}
_UNSAFE = re.compile(r'[<>:"/\\|?*\x00-\x1f]')


def strip_colour(text: Any) -> str:
    if not isinstance(text, str):
        return ""
    return _COLOUR.sub("", text).strip()


def _safe_name(name: str) -> str:
    """A filename that survives Windows and case-insensitive filesystems."""
    cleaned = _UNSAFE.sub("_", name)
    if cleaned.upper() in _RESERVED:
        cleaned += "_"
    return cleaned


def _bucket(name: str) -> str:
    """Single-letter shard for the flat namespaces (globals, events)."""
    first = name[0].upper() if name else "_"
    return first if first.isalpha() else "_"


def restriction_key(key: Any) -> bool:
    """Whether a documentation key is carried onto pages verbatim.

    Every key whose name contains "secret" (case-insensitively, the way
    `/fprobe docs secrets` counted the taxonomy in findings §P.26), plus the
    other gating keys Blizzard writes on an entry. The adapter and the in-game
    dumper both project exactly these, so the two roads stay equivalent; keep
    the three in step. Nothing here is interpreted - the keys are Blizzard's
    and so is whatever they mean.
    """
    if not isinstance(key, str):
        return False
    return ("secret" in key.lower() or key.startswith("Requires")
            or key in ("ChecksForbiddenAspects", "IsProtectedFunction", "HasRestrictions"))


def lua_literal(value: Any) -> str:
    """A value as the Lua it was written in, deterministically. Dict keys sort;
    lists keep their order, because order is the source's."""
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, (int, float)):
        return repr(value)
    if isinstance(value, str):
        return '"' + value.replace("\\", "\\\\").replace('"', '\\"') + '"'
    if isinstance(value, list):
        return "{ " + ", ".join(lua_literal(v) for v in value) + " }" if value else "{}"
    if isinstance(value, dict):
        if not value:
            return "{}"
        parts = []
        for key in sorted(value, key=lambda k: (not isinstance(k, int), str(k))):
            if isinstance(key, str) and re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", key):
                label = key
            else:
                label = f"[{lua_literal(key)}]"
            parts.append(f"{label} = {lua_literal(value[key])}")
        return "{ " + ", ".join(parts) + " }"
    return "nil"


def _cell(text: str) -> str:
    """Inline code for a table cell; a pipe would end the cell early."""
    return "`" + text.replace("|", "\\|") + "`"


def _keys_rows(label: str, entry: dict[str, Any], skip: tuple[str, ...] = ()) -> list[str]:
    return [f"| {label} | `{key}` | {_cell(lua_literal(entry[key]))} |"
            for key in sorted(k for k in entry if restriction_key(k) and k not in skip)]


def documented_keys_section(rows: list[str]) -> list[str]:
    """The dedicated section for Blizzard's secrecy and gating keys. Rendered
    only when there is something in it, so a capture that predates these keys
    produces exactly the page it always did."""
    if not rows:
        return []
    return [
        "**Secrecy and restriction keys**", "",
        "Verbatim from Blizzard's documentation for this build, as the client loads it"
        " (an `Enum` reference is its number); not interpreted here.", "",
        "| Applies to | Key | Value |", "|---|---|---|",
        *rows, "",
    ]


def _field_rows(fields: list[dict[str, Any]] | None) -> list[str]:
    if not fields:
        return []
    # Enum members carry EnumValue. A capture that predates the dumper keeping
    # it has no Value column at all, rather than a column of blanks.
    valued = any("EnumValue" in field for field in fields)
    if valued:
        rows = ["| # | Name | Value | Type | Nilable | Default |", "|---|---|---|---|---|---|"]
    else:
        rows = ["| # | Name | Type | Nilable | Default |", "|---|---|---|---|---|"]
    for index, field in enumerate(fields, start=1):
        type_name = field.get("Type") or ""
        inner = field.get("InnerType")
        if inner:
            type_name = f"{type_name}&lt;{inner}&gt;"
        mixin = field.get("Mixin")
        if mixin:
            type_name = f"{type_name} ({mixin})"
        default = field.get("Default")
        value = ""
        if field.get("EnumValue") is not None:
            value = lua_literal(field["EnumValue"])
        rows.append(
            "| {i} | `{name}` |{value} `{type}` | {nilable} | {default} |".format(
                i=index,
                name=field.get("Name") or "",
                value=f" {value} |" if valued else "",
                type=type_name or "?",
                nilable="yes" if field.get("Nilable") else "no",
                default=f"`{default}`" if default is not None else "",
            )
        )
    return rows


def effective_namespace(function: dict[str, Any], system: dict[str, Any]) -> str | None:
    """A function's own `Namespace` wins over its system's; "" means global."""
    if "Namespace" in function:
        return function.get("Namespace") or None
    return system.get("Namespace") or None


def _shared_sort_key(key: str) -> tuple[str, int]:
    """"X" before "X~2" before "X~10": first-loaded keeps the plain key."""
    base, _, suffix = key.partition("~")
    return (base, int(suffix) if suffix.isdigit() else 0)


def _signature(function: dict[str, Any], qualified: str) -> str:
    args = ", ".join(
        (a.get("Name") or "?") for a in (function.get("Arguments") or [])
    )
    rets = ", ".join(
        (r.get("Name") or "?") for r in (function.get("Returns") or [])
    )
    call = f"{qualified}({args})"
    return f"{rets} = {call}" if rets else call


VERDICT_LABEL = {
    "forbidden": "FORBIDDEN",
    "blocked": "BLOCKED IN COMBAT",
    "secret": "SECRET",
    "silent": "FAILS SILENTLY",
    "broken": "BROKEN ON THIS BUILD",
    "caution": "CAUTION",
    "permitted": "PERMITTED",
}


class Restrictions:
    """The measured restriction data, indexed for lookup during generation.

    This is the part of the reference nobody else has: Blizzard's documentation
    says a function exists and what it takes, and says nothing about whether the
    client will actually let an addon call it, or whether the value it returns can
    be read. Both are measured, and both belong on the page rather than in a
    document the reader has to know to go and find.
    """

    def __init__(self, path: Path | None, findings_link: str = "research/findings.md") -> None:
        # Where the evidence document lives relative to the repo root. Kept
        # configurable because the restructure moves it to research/.
        self.findings_link = findings_link
        self.meta: dict[str, Any] = {}
        self.entries: list[dict[str, Any]] = []
        self.by_symbol: dict[str, list[dict[str, Any]]] = {}
        self.by_namespace: dict[str, list[dict[str, Any]]] = {}
        self.by_event: dict[str, list[dict[str, Any]]] = {}
        if not path or not path.exists():
            return
        if yaml is None:
            print("PyYAML not installed; restriction banners will be omitted",
                  file=sys.stderr)
            return
        data = yaml.safe_load(path.read_text(encoding="utf-8")) or {}
        self.meta = data.get("meta") or {}
        self.entries = data.get("entries") or []
        for entry in self.entries:
            for symbol in entry.get("symbols") or []:
                self.by_symbol.setdefault(symbol, []).append(entry)
            for namespace in entry.get("namespaces") or []:
                self.by_namespace.setdefault(namespace, []).append(entry)
            for event in entry.get("events") or []:
                self.by_event.setdefault(event, []).append(entry)

    def for_function(self, qualified: str, namespace: str | None) -> list[dict[str, Any]]:
        found = list(self.by_symbol.get(qualified, []))
        if namespace:
            found += [e for e in self.by_namespace.get(namespace, []) if e not in found]
        return found

    # An entry may carry its own `build` and `measured_on`, for one re-measured
    # on a later client than the rest of the file. Unset, it inherits meta's.
    # Each output that states a build states the entry's own, so a re-measured
    # entry never sits under a line naming the build it was not measured on.
    def build_of(self, entry: dict[str, Any]) -> str:
        return str(entry.get("build") or self.meta.get("build", ""))

    def measured_of(self, entry: dict[str, Any]) -> str:
        return str(entry.get("measured_on") or self.meta.get("measured_on", ""))

    def own_build(self, entry: dict[str, Any]) -> bool:
        """Whether the entry was measured somewhere other than meta says, and
        so has to say where on outputs that otherwise state meta's build once."""
        return ((entry.get("build") is not None
                 and str(entry["build"]) != str(self.meta.get("build", "")))
                or (entry.get("measured_on") is not None
                    and str(entry["measured_on"]) != str(self.meta.get("measured_on", ""))))

    def own_build_note(self, entry: dict[str, Any]) -> str:
        """The suffix a one-line row carries when the entry has its own build."""
        if not self.own_build(entry):
            return ""
        return f" _(measured {self.measured_of(entry)} on build {self.build_of(entry)})_"

    def banner(self, entries: list[dict[str, Any]], depth: int = 4) -> list[str]:
        lines: list[str] = []
        for entry in entries:
            verdict = entry.get("verdict", "caution")
            label = VERDICT_LABEL.get(verdict, verdict.upper())
            scope = entry.get("scope", "always")
            scope_text = "in combat only" if scope == "in-combat" else "at all times"
            measured = self.measured_of(entry)
            build = self.build_of(entry)
            lines.append(
                f"> **{label} — measured, {scope_text}.** "
                + " ".join((entry.get("summary") or "").split())
            )
            evidence = entry.get("evidence") or []
            if evidence:
                refs = ", ".join(f"§{e}" for e in evidence)
                up = "../" * depth
                lines.append(
                    f"> Measured {measured} on build {build}. Evidence: {refs} in"
                    f" [findings]({up}{self.findings_link})."
                )
            workaround = entry.get("workaround")
            if workaround:
                lines.append("> ")
                lines.append("> _Workaround:_ " + " ".join(workaround.split()))
            lines.append("")
        return lines


class Costs:
    """The measured cost data, indexed the same way the restrictions are.

    Deliberately a separate source from Restrictions rather than a `kind` inside
    it. A restriction is what the client refuses - policy, identical on every
    machine, true until Blizzard changes it. A cost is what a permitted call
    prices - a measurement, tied to one build on one machine, with nothing
    refusing anything. They answer different questions and go stale at different
    rates, so they are kept apart and the banner says which one the reader is
    looking at.
    """

    def __init__(self, path: Path | None, findings_link: str = "research/findings.md") -> None:
        self.findings_link = findings_link
        self.meta: dict[str, Any] = {}
        self.entries: list[dict[str, Any]] = []
        self.by_symbol: dict[str, list[dict[str, Any]]] = {}
        if not path or not path.exists():
            return
        if yaml is None:
            print("PyYAML not installed; cost banners will be omitted", file=sys.stderr)
            return
        data = yaml.safe_load(path.read_text(encoding="utf-8")) or {}
        self.meta = data.get("meta") or {}
        self.entries = data.get("entries") or []
        for entry in self.entries:
            for symbol in entry.get("symbols") or []:
                self.by_symbol.setdefault(symbol, []).append(entry)

    def for_function(self, qualified: str) -> list[dict[str, Any]]:
        # No namespace fallback, unlike Restrictions: a restriction can govern a
        # whole namespace, but a cost is always a measurement of one call.
        return list(self.by_symbol.get(qualified, []))

    @staticmethod
    def span(values: list[Any]) -> str:
        """Render a [min, max] range with both ends at the same precision.

        YAML parses 0.610 to the float 0.61, which would publish a measurement
        as one significant figure shorter than it was taken. Padding to the
        widest end of the range puts the precision back without asking the
        source file to quote its numbers as strings."""
        if not values:
            return ""
        places = max((len(str(v).split(".")[1]) if "." in str(v) else 0) for v in values)
        return " - ".join(f"{float(v):.{places}f}" if places else str(v) for v in values)

    @staticmethod
    def figures(entry: dict[str, Any]) -> str:
        """One line of numbers, for the banner. The table form is in COSTS.md."""
        parts: list[str] = []
        for measurement in entry.get("measurements") or []:
            timing = measurement.get("time_us") or []
            bits: list[str] = []
            if timing:
                bits.append(f"{Costs.span(timing)} µs")
            allocated = measurement.get("bytes")
            if allocated:
                bits.append(f"{allocated} bytes")
            elif allocated == 0:
                bits.append("no measurable allocation")
            label = measurement.get("label")
            joined = ", ".join(bits)
            parts.append(f"{label}: {joined}" if label and len(entry.get("measurements") or []) > 1
                         else joined)
        return "; ".join(p for p in parts if p)

    def banner(self, entries: list[dict[str, Any]], depth: int = 4) -> list[str]:
        lines: list[str] = []
        build = self.meta.get("build", "")
        measured = self.meta.get("measured_on", "")
        for entry in entries:
            runs = entry.get("runs")
            figures = self.figures(entry)
            lines.append(
                "> **COST — measured, not a restriction.** "
                + (figures + ". " if figures else "")
                + " ".join((entry.get("summary") or "").split())
            )
            lines.append(
                f"> Measured {measured} on build {build}"
                + (f", n={runs}" if runs else "")
                + ", on one machine, and NOT re-measured by `regenerate`."
                + (f" Evidence: {', '.join(chr(167) + str(e) for e in entry['evidence'])} in"
                   f" [findings]({'../' * depth}{self.findings_link})."
                   if entry.get("evidence") else "")
            )
            guidance = entry.get("guidance")
            if guidance:
                lines.append("> ")
                lines.append("> _Guidance:_ " + " ".join(guidance.split()))
            lines.append("")
        return lines


class ReferenceBuilder:
    def __init__(self, out_dir: Path, docs: dict[str, Any],
                 restrictions: Restrictions | None = None,
                 costs: Costs | None = None) -> None:
        self.out = out_dir
        self.docs = docs
        self.systems: dict[str, Any] = docs["systems"]
        self.restrictions = restrictions or Restrictions(None)
        self.costs = costs or Costs(None)
        self.written = 0
        self.index: list[tuple[str, str]] = []  # (symbol, path) for the names index
        self.annotated: set[str] = set()
        self.costed: set[str] = set()
        self.surface: dict[str, Any] = {}
        # The build the --surface capture was taken on. None means it did not
        # say, which is treated like a mismatch: unverifiable.
        self.surface_build: str | None = None
        self.stubs = 0
        # Lowercased table page path -> the table names written there.
        self.table_path_owner: dict[str, list[str]] = {}
        self.table_collisions: list[str] = []
        self.shared_tables = 0

    @property
    def docs_build(self) -> str | None:
        build = (self.docs.get("client") or {}).get("build")
        return str(build) if build is not None else None

    @property
    def surface_mismatch(self) -> bool:
        """True when the surface dump cannot be shown to come from the build
        the documentation describes. A stub is a claim about one client; a
        surface from another build cannot make it."""
        if not self.surface:
            return False
        return (self.surface_build is None or self.docs_build is None
                or self.surface_build != self.docs_build)

    # -- page emission -----------------------------------------------------
    def _write(self, path: Path, lines: list[str]) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        body = "\n".join(lines).rstrip() + "\n"
        # newline="\n" so a regenerate on Windows is not a whole-tree diff
        path.write_text(body, encoding="utf-8", newline="\n")
        self.written += 1

    def _depth(self, directory: Path) -> int:
        """How many `../` it takes to get from a page in `directory` back to the
        repo root: the depth of the reference root plus the page's depth inside
        it. Callers pass the page's own directory and nothing else - an off-by-one
        here silently produces links that 404 from some pages and work from
        others, which is worse than one that is wrong everywhere."""
        try:
            relative = directory.resolve().relative_to(self.out.resolve())
        except ValueError:
            return len(self.out.parts)
        return len(self.out.parts) + len(relative.parts)

    def _header(self) -> str:
        client = self.docs.get("client") or {}
        build = client.get("build") or "unknown"
        return (
            f"<!-- GENERATED from Blizzard_APIDocumentation, client build {build}. "
            "Do not edit; edit the generator. -->"
        )

    def function_page(self, function: dict[str, Any], owner: dict[str, Any],
                      directory: Path, qualified: str) -> None:
        name = function.get("Name") or "unknown"
        namespace = effective_namespace(function, owner)
        lines = [self._header(), "", f"# {qualified}", ""]

        # Our measured restrictions go ABOVE Blizzard's own flag: the flag says
        # the call is gated, ours says what the client actually did.
        measured = self.restrictions.for_function(qualified, namespace)
        if measured:
            lines += self.restrictions.banner(measured, self._depth(directory))
            for entry in measured:
                self.annotated.add(entry["id"])

        if function.get("HasRestrictions"):
            lines += [
                "> **RESTRICTED — Blizzard flag.** This function carries"
                " `HasRestrictions` in the client's own documentation, meaning it is"
                " gated on a hardware event or refuses to run from a script.",
                "",
            ]

        # Cost goes below both, because "may I call this" is the question that
        # decides whether "what does it cost" is worth reading.
        priced = self.costs.for_function(qualified)
        if priced:
            lines += self.costs.banner(priced, self._depth(directory))
            for entry in priced:
                self.costed.add(entry["id"])

        lines += ["```lua", _signature(function, qualified), "```", ""]

        args = function.get("Arguments")
        lines += ["**Arguments**", ""]
        lines += _field_rows(args) if args else ["_None._"]
        lines += [""]

        rets = function.get("Returns")
        lines += ["**Returns**", ""]
        lines += _field_rows(rets) if rets else ["_None._"]
        lines += [""]

        # HasRestrictions already has its banner above; everything else the
        # documentation says about secrecy and gating goes here, verbatim.
        keyed = _keys_rows("this function", function, skip=("HasRestrictions",))
        for kind, fields in (("argument", args), ("return", rets)):
            for field in fields or []:
                keyed += _keys_rows(f"{kind} `{field.get('Name') or '?'}`", field)
        lines += documented_keys_section(keyed)

        blizzard = strip_colour(function.get("FullName"))
        if blizzard:
            lines += [f"Blizzard's own rendering: `{blizzard}`", ""]

        owner_name = owner.get("Name") or "?"
        if "Namespace" in function:
            # The function's own Namespace overrode its system's. Say so, since
            # Blizzard's rendering above still uses the system's.
            system_ns = owner.get("Namespace")
            placed = f" · Namespace: `{namespace}`" if namespace else " · Global"
            placed += (" (function-level `Namespace`; the system's is "
                       + (f"`{system_ns}`)" if system_ns else "none)"))
        else:
            placed = f" · Namespace: `{owner['Namespace']}`" if owner.get("Namespace") else ""
        lines += [
            f"System: `{owner_name}`"
            + placed
            + (" · Widget methods" if owner.get("Type") == "ScriptObject" else ""),
        ]
        self._write(directory / f"{_safe_name(name)}.md", lines)
        self.index.append((qualified, str(directory.relative_to(self.out) / f"{_safe_name(name)}.md")))

    def event_page(self, event: dict[str, Any], owner: dict[str, Any]) -> None:
        literal = event.get("LiteralName") or event.get("Name") or "unknown"
        directory = self.out / "events" / _bucket(literal)
        lines = [self._header(), "", f"# {literal}", ""]
        measured = self.restrictions.by_event.get(literal, [])
        if measured:
            lines += self.restrictions.banner(measured, self._depth(directory))
            for entry in measured:
                self.annotated.add(entry["id"])
        payload = event.get("Payload")
        lines += ["**Payload**", ""]
        lines += _field_rows(payload) if payload else ["_No payload._"]
        lines += [""]
        # Events have no HasRestrictions banner, so here it goes in the table.
        keyed = _keys_rows("this event", event)
        for field in payload or []:
            keyed += _keys_rows(f"payload `{field.get('Name') or '?'}`", field)
        lines += documented_keys_section(keyed)
        lines += [f"System: `{owner.get('Name') or '?'}`"]
        self._write(directory / f"{_safe_name(literal)}.md", lines)
        self.index.append((literal, f"events/{_bucket(literal)}/{_safe_name(literal)}.md"))

    @staticmethod
    def table_path(table: dict[str, Any]) -> str:
        name = table.get("Name") or "unknown"
        folder = "enums" if table.get("Type") == "Enumeration" else "structures"
        return f"{folder}/{_safe_name(name)}.md"

    def table_page(self, table: dict[str, Any], owner: dict[str, Any] | None) -> None:
        """`owner` is None for a shared table: one filed in a nameless
        documentation table, which the client keeps in APIDocumentation.tables
        and never attaches to a system."""
        name = table.get("Name") or "unknown"
        kind = table.get("Type") or "Table"
        relative = self.table_path(table)
        lines = [self._header(), "", f"# {name}", "", f"_{kind}_", ""]

        values = table.get("Values")
        if values:
            if any("Value" in v or "EnumValue" in v for v in values):
                lines += ["| Name | Type | Value |", "|---|---|---|"]
                for value in values:
                    raw = value.get("Value", value.get("EnumValue"))
                    lines.append(
                        f"| `{value.get('Name')}` | `{value.get('Type') or '?'}` |"
                        f" {_cell(lua_literal(raw)) if raw is not None else ''} |")
            else:
                # A capture from before the dumper kept constant values. Left
                # exactly as it always rendered, so old captures still
                # reproduce the tree they produced.
                lines += ["| Name | Value |", "|---|---|"]
                for value in values:
                    lines.append(f"| `{value.get('Name')}` | {value.get('EnumValue')} |")
            lines += [""]

        fields = table.get("Fields")
        if fields:
            lines += ["**Fields**", ""] + _field_rows(fields) + [""]
            keyed: list[str] = []
            for field in fields:
                keyed += _keys_rows(f"field `{field.get('Name') or '?'}`", field)
            lines += documented_keys_section(keyed)

        if owner is None:
            lines += ["System: none (a shared table, filed in `APIDocumentation.tables`)"]
        else:
            lines += [f"System: `{owner.get('Name') or '?'}`"]
        self._write(self.out / relative, lines)
        self.index.append((name, relative))

    # -- drivers -----------------------------------------------------------
    def placement(self, function: dict[str, Any], system: dict[str, Any],
                  key: str) -> tuple[Path, str]:
        """Where a function's page goes and the name it is called by.

        A function's own `Namespace` overrides its system's, and an empty one
        means a plain global: InCombatLockdown is documented inside
        C_RestrictedActions but is called as a global, and
        GetDefaultAbbreviationBreakpoints sits in a namespace-less system but
        is C_StringUtil's. Captures from before the dumper kept the field fall
        back to the system's, which is what they always did."""
        name = function.get("Name") or "unknown"
        namespace = effective_namespace(function, system)
        if namespace:
            return (self.out / "namespaces" / _safe_name(namespace), f"{namespace}.{name}")
        if system.get("Type") == "ScriptObject" and "Namespace" not in function:
            owner = system.get("Name") or key
            return self.out / "widgets" / _safe_name(owner), f"{system.get('Name')}:{name}"
        # A system with no namespace holds plain globals.
        return self.out / "globals" / _bucket(name), name

    def build(self) -> None:
        for key in sorted(self.systems):
            system = self.systems[key]
            if not isinstance(system, dict):
                continue
            for function in system.get("Functions") or []:
                directory, qualified = self.placement(function, system, key)
                self.function_page(function, system, directory, qualified)

            for event in system.get("Events") or []:
                self.event_page(event, system)
            for table in system.get("Tables") or []:
                self.table_path_owner.setdefault(self.table_path(table).lower(), []).append(
                    table.get("Name") or "unknown")
                self.table_page(table, system)

        self.write_shared_tables()
        # Deliberately after the documented pass, so a stub never shadows a real
        # page.
        self.write_stubs()
        self.write_indexes()

    def write_shared_tables(self) -> None:
        """Pages for tables filed in nameless documentation tables.

        The client keeps these in APIDocumentation.tables and attaches them to
        no system, so a dump that walks only .systems never sees them - which
        is how Enum.ForbiddenAspect, the flag set half the widget API checks,
        went without a page. A capture from before the dumper walked them has
        no `tables` key and this writes nothing.

        Paths are derived from the name exactly as a system table's are. Two
        tables that would share a path (compared case-insensitively, because
        the tree must check out on Windows) are not suffixed, since a suffix
        would make the path underivable: the system table keeps the page, the
        shared one is skipped, and the collision is reported."""
        for path, names in sorted(self.table_path_owner.items()):
            if len(names) > 1:
                # Pre-existing behaviour, now reported rather than silent: the
                # last system table written to a path is the page that stands.
                self.table_collisions.append(
                    f"system tables {', '.join(f'`{n}`' for n in names)} share {path};"
                    f" `{names[-1]}` stands")
        shared = self.docs.get("tables")
        if not isinstance(shared, dict):
            return
        for key in sorted(shared, key=_shared_sort_key):
            table = shared[key]
            if not isinstance(table, dict) or not table.get("Name"):
                continue
            path = self.table_path(table).lower()
            if path in self.table_path_owner:
                self.table_collisions.append(
                    f"shared table `{table['Name']}` (key `{key}`) not paged: "
                    f"{self.table_path(table)} already belongs to "
                    + ", ".join(f"`{n}`" for n in self.table_path_owner[path]))
                continue
            self.table_path_owner[path] = [table["Name"]]
            self.table_page(table, None)
            self.shared_tables += 1

    def write_stubs(self) -> None:
        """Pages for symbols the client HAS but Blizzard does not document.

        This is not padding. The validation pass found that UseAction, ReloadUI
        and the binding setters - four of the most restricted functions on this
        client - appear nowhere in Blizzard's own documentation. Without stubs,
        the restriction data would have had nowhere to land, and a missing file
        would have been ambiguous between "not on this build" and "we failed to
        find it".

        With stubs, a missing file means exactly one thing: the symbol is not in
        this client. That is worth several thousand small files.
        """
        if not self.surface:
            return
        documented = {symbol for symbol, _ in self.index}
        stubs = 0
        for name in sorted(self.surface.get("globals", [])):
            if name in documented:
                continue
            target = self.out / "globals" / _bucket(name)
            self._stub_page(target / f"{_safe_name(name)}.md", name, None)
            self.index.append((name, f"globals/{_bucket(name)}/{_safe_name(name)}.md"))
            stubs += 1
        for namespace, members in sorted(self.surface.get("namespaces", {}).items()):
            for member in sorted(members):
                qualified = f"{namespace}.{member}"
                if qualified in documented:
                    continue
                target = self.out / "namespaces" / _safe_name(namespace)
                self._stub_page(target / f"{_safe_name(member)}.md", qualified, namespace)
                self.index.append(
                    (qualified, f"namespaces/{_safe_name(namespace)}/{_safe_name(member)}.md"))
                stubs += 1
        self.stubs = stubs

    def _stub_page(self, path: Path, qualified: str, namespace: str | None) -> None:
        lines = [self._header(), "", f"# {qualified}", ""]
        measured = self.restrictions.for_function(qualified, namespace)
        if measured:
            lines += self.restrictions.banner(measured, self._depth(path.parent))
            for entry in measured:
                self.annotated.add(entry["id"])
        priced = self.costs.for_function(qualified)
        if priced:
            lines += self.costs.banner(priced, self._depth(path.parent))
            for entry in priced:
                self.costed.add(entry["id"])
        if self.surface_mismatch:
            # The surface was dumped on a different (or unrecorded) build, so
            # it cannot say the symbol is on THIS client. Say what it can.
            seen = self.surface_build or "an unrecorded build"
            here = self.docs_build or "an unrecorded build"
            lines += [
                f"> **Seen on client build {seen}, not documented by Blizzard on"
                f" build {here}.** The global surface dump behind this stub was taken"
                f" on build {seen}, not on the build this reference describes, so"
                " whether the symbol exists on this client is unverified. Blizzard's"
                " own API documentation carries no signature for it, so none is shown"
                " here rather than one being invented.",
                "",
                f"Source: ForeverProbe global surface dump, build {seen}.",
            ]
        else:
            lines += [
                "> **Present on this client, but not documented by Blizzard.**"
                " It exists in the client's global table and can be called; Blizzard's"
                " own API documentation carries no signature for it, so none is shown"
                " here rather than one being invented.",
                "",
                "Source: ForeverProbe global surface dump.",
            ]
        if namespace:
            lines.append(f"Namespace: `{namespace}`")
        self._write(path, lines)

    def write_indexes(self) -> None:
        # Namespace index: which namespace owns what, for the "I don't know the
        # name" case. Small enough to read whole.
        rows = ["| Namespace | System | Functions | Events | Tables |",
                "|---|---|---|---|---|"]
        widget_rows = ["| Widget type | Methods |", "|---|---|"]
        for key in sorted(self.systems):
            system = self.systems[key]
            if not isinstance(system, dict):
                continue
            counts = (
                len(system.get("Functions") or []),
                len(system.get("Events") or []),
                len(system.get("Tables") or []),
            )
            if system.get("Type") == "ScriptObject":
                widget_rows.append(
                    f"| [{system.get('Name')}](../widgets/{_safe_name(system.get('Name') or key)}/) | {counts[0]} |"
                )
            elif system.get("Namespace"):
                rows.append(
                    f"| [{system['Namespace']}]({_safe_name(system['Namespace'])}/) "
                    f"| {system.get('Name')} | {counts[0]} | {counts[1]} | {counts[2]} |"
                )
        self._write(self.out / "namespaces" / "_index.md",
                    [self._header(), "", "# Namespaces", ""] + rows)
        self._write(self.out / "widgets" / "_index.md",
                    [self._header(), "", "# Widget types", "",
                     "Methods on frames and other script objects.", ""] + widget_rows)

        # The names index. Deliberately NOT how Claude should normally look
        # things up - a derived path or a Glob is cheaper - but it is what makes
        # "does this exist on my build" answerable with no capture at all, and
        # it is the one artifact that is safe to ship for every client.
        index_lines = [self._header(), "", "# Symbol index", "",
                       "One line per documented symbol. Prefer computing the path"
                       " from the name; this is the fallback.", ""]
        for symbol, path in sorted(set(self.index)):
            index_lines.append(f"- `{symbol}` → {path}")
        self._write(self.out / "INDEX.md", index_lines)

    def write_restrictions_page(self) -> None:
        """One page carrying every restriction, so the question can be answered
        in a single read rather than a tour of the tree."""
        entries = self.restrictions.entries
        if not entries:
            return
        meta = self.restrictions.meta
        own = any(self.restrictions.own_build(e) for e in entries)
        lines = [
            self._header(), "", "# Restrictions", "",
            f"Measured on client {meta.get('client')} build {meta.get('build')}"
            f" (interface {meta.get('interface')}) with {meta.get('measured_by')}"
            + (", except where an entry names its own build." if own else "."), "",
            "Everything here was measured against a running client. Blizzard's own"
            " documentation says what a function takes; this says whether the client"
            " will let an addon call it and whether the value can be read.", "",
            "| Applies to | Verdict | Scope | Summary |",
            "|---|---|---|---|",
        ]
        for entry in sorted(entries, key=lambda e: (e.get("scope", ""), e["id"])):
            targets = (entry.get("symbols") or entry.get("events")
                       or entry.get("namespaces") or [entry.get("gate") or entry["id"]])
            target_text = ", ".join(f"`{t}`" for t in targets[:3])
            if len(targets) > 3:
                target_text += f" +{len(targets) - 3}"
            lines.append(
                "| {target} | **{verdict}** | {scope} | {summary} |".format(
                    target=target_text,
                    verdict=VERDICT_LABEL.get(entry.get("verdict", ""), entry.get("verdict", "")),
                    scope=entry.get("scope", ""),
                    summary=" ".join((entry.get("summary") or "").split())
                    + self.restrictions.own_build_note(entry),
                )
            )
        lines.append("")
        for entry in sorted(entries, key=lambda e: e["id"]):
            lines += [f"## {entry['id']}", ""]
            lines.append(" ".join((entry.get("summary") or "").split()))
            if self.restrictions.own_build(entry):
                lines += ["", f"**Measured {self.restrictions.measured_of(entry)} on build"
                              f" {self.restrictions.build_of(entry)}**, not on the build"
                              " named at the top of this page."]
            detail = entry.get("detail")
            if detail:
                lines += ["", " ".join(detail.split())]
            workaround = entry.get("workaround")
            if workaround:
                lines += ["", "**Workaround.** " + " ".join(workaround.split())]
            evidence = entry.get("evidence") or []
            if evidence:
                refs = ", ".join(f"§{e}" for e in evidence)
                lines += ["", f"_Evidence: {refs} in `research/findings.md`._"]
            lines.append("")
        self._write(self.out / "RESTRICTIONS.md", lines)

    def write_costs_page(self) -> None:
        """The cost half of the same promise RESTRICTIONS.md makes: one page that
        answers "what does this price" without a tour of the tree."""
        entries = self.costs.entries
        if not entries:
            return
        meta = self.costs.meta
        lines = [
            self._header(), "", "# Costs", "",
            f"What permitted calls cost on client {meta.get('client')} build"
            f" {meta.get('build')}, measured with {meta.get('measured_by')}.", "",
            "**Nothing here is a restriction.** Every call on this page is allowed;"
            " what is recorded is what it prices. For what the client refuses, see"
            " `RESTRICTIONS.md`.", "",
        ]
        staleness = meta.get("staleness")
        if staleness:
            lines += ["> **These go stale differently from the rest of this reference.** "
                      + " ".join(staleness.split()), ""]
        lines += [
            "| Field | Value |", "|---|---|",
            f"| Measured | {meta.get('measured_on')} |",
            f"| Machine | {meta.get('machine')} |",
            f"| Combat state | {meta.get('combat')} |",
            f"| Capture | `{meta.get('capture')}` |",
            "",
            "Method: " + " ".join((meta.get("method") or "").split()), "",
            "Instrument: " + " ".join((meta.get("instrument") or "").split()), "",
            "| Call | Measured | Time (µs/call) | Allocation (bytes/call) |",
            "|---|---|---|---|",
        ]
        for entry in sorted(entries, key=lambda e: e["id"]):
            symbols = ", ".join(f"`{s}`" for s in entry.get("symbols") or [])
            for measurement in entry.get("measurements") or []:
                timing = measurement.get("time_us") or []
                time_text = Costs.span(timing).replace(" - ", " – ") if timing else "—"
                allocated = measurement.get("bytes")
                alloc_text = ("none measurable" if allocated == 0
                              else f"**{allocated}**" if allocated else "—")
                lines.append(f"| {symbols} | {measurement.get('label') or ''} |"
                             f" {time_text} | {alloc_text} |")
                symbols = ""  # only label the first row of a multi-row entry
        lines += [
            "",
            "An em dash in the allocation column means the figure was not"
            " separately measured for that row, not that the call allocates"
            " nothing; `none measurable` is the measured zero.",
            "",
        ]
        for entry in sorted(entries, key=lambda e: e["id"]):
            lines += [f"## {entry['id']}", ""]
            label = entry.get("label")
            if label:
                lines += [f"_{label}_", ""]
            lines.append(" ".join((entry.get("summary") or "").split()))
            figures = Costs.figures(entry)
            runs = entry.get("runs")
            if figures:
                lines += ["", f"**Measured.** {figures}"
                              + (f" (n={runs})" if runs else "") + "."]
            detail = entry.get("detail")
            if detail:
                lines += ["", " ".join(detail.split())]
            guidance = entry.get("guidance")
            if guidance:
                lines += ["", "**Guidance.** " + " ".join(guidance.split())]
            evidence = entry.get("evidence") or []
            if evidence:
                refs = ", ".join(f"§{e}" for e in evidence)
                lines += ["", f"_Evidence: {refs} in `research/findings.md`._"]
            lines.append("")
        self._write(self.out / "COSTS.md", lines)

    def update_skill_table(self, skill: Path) -> bool:
        """Rewrite the generated block inside the restrictions skill.

        The skill carries the whole table inline so that "what am I not allowed to
        do" is answerable in one load with no follow-up reads. Inline content
        drifts from its source, so the table is written here instead of by hand:
        the prose around the markers is hand-written, everything between them is
        generated from restrictions.yaml.
        """
        begin = "<!-- BEGIN GENERATED restrictions-table -->"
        end = "<!-- END GENERATED restrictions-table -->"
        if not skill.exists() or not self.restrictions.entries:
            return False
        text = skill.read_text(encoding="utf-8")
        if begin not in text or end not in text:
            return False

        rows = ["## Every restriction, measured", "",
                "| Applies to | Verdict | Scope | What happens |",
                "|---|---|---|---|"]
        for entry in sorted(self.restrictions.entries,
                            key=lambda e: (e.get("scope", ""), e["id"])):
            # A label wins when one is given: most of these entries are
            # behaviours, not symbols, and printing an internal id in the
            # "applies to" column reads like a bug.
            if entry.get("label"):
                target_text = entry["label"]
            else:
                targets = (entry.get("symbols") or entry.get("events")
                           or entry.get("namespaces") or [entry.get("gate") or entry["id"]])
                target_text = ", ".join(f"`{t}`" for t in targets[:2])
                if len(targets) > 2:
                    target_text += f" +{len(targets) - 2}"
            rows.append(
                "| {t} | **{v}** | {s} | {summary} |".format(
                    t=target_text,
                    v=VERDICT_LABEL.get(entry.get("verdict", ""), entry.get("verdict", "")),
                    s=entry.get("scope", ""),
                    summary=" ".join((entry.get("summary") or "").split())
                    + self.restrictions.own_build_note(entry),
                )
            )
        meta = self.restrictions.meta
        own = any(self.restrictions.own_build(e) for e in self.restrictions.entries)
        rows += ["",
                 f"Measured {meta.get('measured_on')} on client {meta.get('client')} build"
                 f" {meta.get('build')}"
                 + (", except where a row names its own build." if own else ".")
                 + " Detail and evidence for each: `reference/api/RESTRICTIONS.md`."]

        head = text.split(begin)[0]
        tail = text.split(end)[1]
        skill.write_text(head + begin + "\n" + "\n".join(rows) + "\n" + end + tail,
                         encoding="utf-8", newline="\n")
        return True

    def validate(self, findings: Path) -> list[str]:
        """A restriction pointing at a symbol that no longer exists is the failure
        that actually bites: Blizzard removes a function and the guidance keeps
        recommending it. Same for an evidence anchor that has been renamed."""
        problems: list[str] = []
        known = {symbol for symbol, _ in self.index}
        headings = ""
        if findings.exists():
            headings = findings.read_text(encoding="utf-8", errors="replace")

        for entry in self.restrictions.entries:
            if not entry.get("no_api_page"):
                for symbol in entry.get("symbols") or []:
                    if symbol not in known:
                        problems.append(
                            f"{entry['id']}: symbol {symbol!r} has no generated page"
                            " (mark no_api_page if that is expected)"
                        )
            for namespace in entry.get("namespaces") or []:
                if not any(s.startswith(namespace + ".") for s in known):
                    problems.append(f"{entry['id']}: namespace {namespace!r} generated nothing")
            for event in entry.get("events") or []:
                if event not in known:
                    problems.append(f"{entry['id']}: event {event!r} has no generated page")
            if headings:
                for anchor in entry.get("evidence") or []:
                    if not re.search(rf"^#+\s*{re.escape(str(anchor))}[\s.]", headings, re.M):
                        problems.append(
                            f"{entry['id']}: evidence anchor {anchor!r} not found in {findings}"
                        )

        # Same two failures, same consequences, for the cost data: a number
        # attached to a function that no longer exists is worse than no number.
        for entry in self.costs.entries:
            for symbol in entry.get("symbols") or []:
                if symbol not in known:
                    problems.append(f"cost {entry['id']}: symbol {symbol!r} has no generated page")
            if not entry.get("measurements"):
                problems.append(f"cost {entry['id']}: no measurements")
            if headings:
                for anchor in entry.get("evidence") or []:
                    if not re.search(rf"^#+\s*{re.escape(str(anchor))}[\s.]", headings, re.M):
                        problems.append(
                            f"cost {entry['id']}: evidence anchor {anchor!r} not found in {findings}"
                        )
        return problems

    def write_build_info(self, capture: Path) -> dict[str, Any]:
        client = self.docs.get("client") or {}
        counts = self.docs.get("counts") or {}
        info = {
            "version": client.get("version"),
            "build": client.get("build"),
            "interface": client.get("interface"),
            "generated": self.docs.get("capturedAt"),
            "systems": counts.get("stored") or counts.get("systems"),
            "functions": counts.get("functions"),
            "events": counts.get("events"),
            "tables": counts.get("tables"),
            "capture": capture.name,
        }
        lines = [
            self._header(), "", "# Reference build", "",
            "| Field | Value |", "|---|---|",
        ]
        # Rows that exist only when there is something to say, so a capture
        # without shared tables and a matching surface yields the BUILD.md it
        # always did.
        if isinstance(self.docs.get("tables"), dict):
            info["shared_tables"] = self.shared_tables
        if self.surface_mismatch:
            info["surface_build"] = self.surface_build
        for field, value in info.items():
            lines.append(f"| {field} | {value if value is not None else '_unknown_'} |")
        if self.surface_mismatch:
            lines += ["", "> " + self.surface_warning()]
        if not client:
            lines += [
                "",
                "> **This capture does not record its client build.** It predates the"
                " dumper reading `GetBuildInfo` directly. Re-dump to get a reference"
                " that can state which client it describes.",
            ]
        collisions = counts.get("collisions") or []
        if collisions:
            lines += ["", f"Name collisions, suffixed rather than dropped: "
                          + ", ".join(f"`{c}`" for c in collisions)]
        shared_collisions = counts.get("tableCollisions") or []
        if shared_collisions:
            lines += ["", "Shared-table name collisions in the capture, suffixed: "
                          + ", ".join(f"`{c}`" for c in shared_collisions)]
        if self.table_collisions:
            lines += ["", "Table page collisions (one name, one path, so one page):", ""]
            lines += [f"- {c}" for c in self.table_collisions]
        self._write(self.out / "BUILD.md", lines)
        return info

    def surface_warning(self) -> str:
        return (f"**WARNING: the --surface capture is from client build"
                f" {self.surface_build or '(unrecorded)'}, but the documentation is from"
                f" build {self.docs_build or '(unrecorded)'}.** Its {self.stubs} stubs"
                " are labelled as seen on the surface's build, not as present on this"
                " client. Take a fresh `/fprobe` surface dump on this build before"
                " landing.")


DOCS_VERSION_HEADER = """\
-- DocsVersion.lua
--
-- GENERATED by tools/build_reference.py (--docs-version) from the same capture
-- as reference/api/BUILD.md. Do not edit by hand; regenerate. It records the
-- client build the shipped API reference was generated from, so the addon can
-- tell a player when their client has moved on and the reference may be wrong.
--
-- This matters more here than it would in a shipped game. Blizzard moved this
-- beta from build 69893 to 69913 inside a single day, so a reference that is
-- slightly behind the client is the NORMAL case, not an edge case. The warning
-- is deliberately not silenced by default for that reason.
--
-- Counts are carried so the warning can say what the reference actually covers
-- rather than only naming a build number.
"""


def docs_version_lua(info: dict[str, Any]) -> str:
    """The addon's copy of BUILD.md's identity rows, as Lua.

    `generated` is the date half of the capture stamp, so a rerun on the same
    capture writes the same file."""
    def number(value: Any) -> str:
        text = str(value) if value is not None else ""
        return text if text.isdigit() else "nil"

    def string(value: Any) -> str:
        return lua_literal(str(value)) if value is not None else "nil"

    generated = str(info.get("generated") or "").split(" ")[0] or None
    rows = [
        ("version", string(info.get("version"))),
        ("build", string(info.get("build"))),
        ("interface", number(info.get("interface"))),
        ("generated", string(generated)),
        ("systems", number(info.get("systems"))),
        ("functions", number(info.get("functions"))),
        ("events", number(info.get("events"))),
        ("tables", number(info.get("tables"))),
    ]
    body = "\n".join(f"    {key:<9} = {value}," for key, value in rows)
    return DOCS_VERSION_HEADER + "\nForeverProbeDocsVersion = {\n" + body + "\n}\n"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("capture", type=Path, help="ForeverProbe SavedVariables capture")
    parser.add_argument("--out", type=Path, default=Path("reference/api"))
    parser.add_argument("--json", type=Path, default=Path("data/api.json"),
                        help="normalized machine-readable copy")
    parser.add_argument("--clean", action="store_true",
                        help="remove the output tree first, so deletions show in the diff")
    parser.add_argument("--restrictions", type=Path, default=Path("research/restrictions.yaml"))
    parser.add_argument("--restrictions-json", type=Path, default=Path("data/restrictions.json"))
    parser.add_argument("--costs", type=Path, default=Path("research/costs.yaml"),
                        help="measured per-call costs; separate from restrictions "
                             "because a cost is not a refusal and goes stale faster")
    parser.add_argument("--costs-json", type=Path, default=Path("data/costs.json"))
    parser.add_argument("--findings", type=Path, default=Path("research/findings.md"))
    parser.add_argument("--skill-table", type=Path,
                        default=Path("skills/restrictions/SKILL.md"),
                        help="skill file whose generated restrictions table to refresh")
    parser.add_argument("--surface", type=Path, default=None,
                        help="a capture containing globalFunctions/namespaces, used to "
                             "stub symbols the client has but Blizzard does not document")
    parser.add_argument("--strict", action="store_true",
                        help="fail if any restriction fails to resolve")
    parser.add_argument("--docs-version", type=Path,
                        default=Path("addons/ForeverProbe/DocsVersion.lua"),
                        help="the probe's record of which build the reference describes; "
                             "written only if its folder exists")
    args = parser.parse_args()

    data = svlua.parse_file(str(args.capture))
    db = data.get("ForeverProbeDB") or {}
    docs = db.get("apiDocs")
    if not docs or not docs.get("systems"):
        print(f"{args.capture}: no apiDocs in this capture. Run /fprobe docs dump first.",
              file=sys.stderr)
        return 1

    if args.clean and args.out.exists():
        # --clean removes the whole tree, so the "everything here is generated"
        # boundary is load-bearing: a hand-written file under --out would be
        # deleted and never re-emitted. ALIASES.md was exactly that, and lost a
        # regeneration to it before moving to reference/guides/aliases.md.
        strays = [path for path in sorted(args.out.rglob("*")) if path.is_file()
                  and "GENERATED" not in path.read_text(
                      encoding="utf-8", errors="replace")[:200]]
        if strays:
            print(f"{args.out} holds files that were not generated; --clean would "
                  f"delete them. Move them out of the generated tree:", file=sys.stderr)
            for path in strays:
                print(f"  {path}", file=sys.stderr)
            return 1
        shutil.rmtree(args.out)

    findings_link = str(args.findings).replace("\\", "/")
    restrictions = Restrictions(args.restrictions, findings_link=findings_link)
    costs = Costs(args.costs, findings_link=findings_link)
    builder = ReferenceBuilder(args.out, docs, restrictions, costs)
    if args.surface:
        surface_db = svlua.parse_file(str(args.surface)).get("ForeverProbeDB") or {}
        builder.surface = {
            "globals": surface_db.get("globalFunctions") or [],
            "namespaces": surface_db.get("namespaces") or {},
        }
        # A full /fprobe run records GetBuildInfo under `build`; a capture from
        # before that, or one that only ran the doc dump, may not.
        recorded = surface_db.get("build")
        if isinstance(recorded, dict) and recorded.get("build") is not None:
            builder.surface_build = str(recorded["build"])
        elif isinstance((surface_db.get("apiDocs") or {}).get("client"), dict):
            client_build = surface_db["apiDocs"]["client"].get("build")
            builder.surface_build = str(client_build) if client_build is not None else None
    builder.build()
    builder.write_restrictions_page()
    builder.write_costs_page()
    info = builder.write_build_info(args.capture)

    if builder.update_skill_table(args.skill_table):
        print(f"  restrictions table refreshed in {args.skill_table}")

    problems = builder.validate(args.findings)
    unused = [e["id"] for e in restrictions.entries
              if e["id"] not in builder.annotated
              and (e.get("symbols") or e.get("namespaces") or e.get("events"))
              and not e.get("no_api_page")]
    for entry_id in unused:
        problems.append(f"{entry_id}: matched no generated page")
    for entry in costs.entries:
        if entry["id"] not in builder.costed and entry.get("symbols"):
            problems.append(f"cost {entry['id']}: matched no generated page")

    if restrictions.entries:
        args.restrictions_json.parent.mkdir(parents=True, exist_ok=True)
        with args.restrictions_json.open("w", encoding="utf-8", newline="\n") as handle:
            # default=str because YAML parses a bare 2026-09-18 into a date
            # object, and the linter wants a string it can print.
            json.dump({"meta": restrictions.meta, "entries": restrictions.entries},
                      handle, indent=1, ensure_ascii=False, sort_keys=True, default=str)

    if costs.entries:
        args.costs_json.parent.mkdir(parents=True, exist_ok=True)
        with args.costs_json.open("w", encoding="utf-8", newline="\n") as handle:
            json.dump({"meta": costs.meta, "entries": costs.entries},
                      handle, indent=1, ensure_ascii=False, sort_keys=True, default=str)

    args.json.parent.mkdir(parents=True, exist_ok=True)
    machine = {"build": info, "systems": docs["systems"]}
    if isinstance(docs.get("tables"), dict):
        machine["tables"] = docs["tables"]
    with args.json.open("w", encoding="utf-8", newline="\n") as handle:
        json.dump(machine, handle, indent=1, ensure_ascii=False, sort_keys=True)

    # Only where the addon already is: a scratch run from a mirror directory
    # has no addons/ folder and should not grow one.
    wrote_docs_version = args.docs_version.parent.is_dir()
    if wrote_docs_version:
        args.docs_version.write_text(docs_version_lua(info), encoding="utf-8", newline="\n")

    print(f"{builder.written} pages -> {args.out}")
    print(f"  {info['systems']} systems, {info['functions']} functions, "
          f"{info['events']} events, {info['tables']} tables")
    if builder.shared_tables:
        print(f"  {builder.shared_tables} shared tables paged from APIDocumentation.tables")
    for collision in builder.table_collisions:
        print(f"  TABLE COLLISION: {collision}", file=sys.stderr)
    if builder.stubs:
        print(f"  {builder.stubs} undocumented symbols stubbed from the client surface")
    if builder.surface_mismatch:
        # Loud on both streams: this is the warning that stops a stale surface
        # from turning a removed function into a "present" stub.
        banner = "=" * 72
        warning = builder.surface_warning().replace("**", "").replace("`", "")
        for stream in (sys.stdout, sys.stderr):
            print(banner, file=stream)
            print(f"  {warning}", file=stream)
            print(banner, file=stream)
    print(f"  machine-readable copy -> {args.json}")
    if wrote_docs_version:
        print(f"  probe's reference version -> {args.docs_version}")
    if restrictions.entries:
        print(f"  {len(restrictions.entries)} restrictions, "
              f"{len(builder.annotated)} matched pages -> {args.restrictions_json}")
    if costs.entries:
        print(f"  {len(costs.entries)} costs, "
              f"{len(builder.costed)} matched pages -> {args.costs_json}")
    if not (docs.get("client") or {}).get("build"):
        print("  WARNING: capture does not record its client build; re-dump to fix")
    for problem in problems:
        print(f"  RESTRICTION: {problem}", file=sys.stderr)
    if problems and args.strict:
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
