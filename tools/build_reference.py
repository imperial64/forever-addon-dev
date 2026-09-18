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


def _field_rows(fields: list[dict[str, Any]] | None) -> list[str]:
    if not fields:
        return []
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
        rows.append(
            "| {i} | `{name}` | `{type}` | {nilable} | {default} |".format(
                i=index,
                name=field.get("Name") or "",
                type=type_name or "?",
                nilable="yes" if field.get("Nilable") else "no",
                default=f"`{default}`" if default is not None else "",
            )
        )
    return rows


def _signature(function: dict[str, Any], qualified: str) -> str:
    args = ", ".join(
        (a.get("Name") or "?") for a in (function.get("Arguments") or [])
    )
    rets = ", ".join(
        (r.get("Name") or "?") for r in (function.get("Returns") or [])
    )
    call = f"{qualified}({args})"
    return f"{rets} = {call}" if rets else call


class ReferenceBuilder:
    def __init__(self, out_dir: Path, docs: dict[str, Any]) -> None:
        self.out = out_dir
        self.docs = docs
        self.systems: dict[str, Any] = docs["systems"]
        self.written = 0
        self.index: list[tuple[str, str]] = []  # (symbol, path) for the names index

    # -- page emission -----------------------------------------------------
    def _write(self, path: Path, lines: list[str]) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        body = "\n".join(lines).rstrip() + "\n"
        # newline="\n" so a regenerate on Windows is not a whole-tree diff
        path.write_text(body, encoding="utf-8", newline="\n")
        self.written += 1

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
        lines = [self._header(), "", f"# {qualified}", ""]

        if function.get("HasRestrictions"):
            lines += [
                "> **RESTRICTED — Blizzard flag.** This function carries"
                " `HasRestrictions` in the client's own documentation, meaning it is"
                " gated on a hardware event or refuses to run from a script.",
                "",
            ]

        lines += ["```lua", _signature(function, qualified), "```", ""]

        args = function.get("Arguments")
        lines += ["**Arguments**", ""]
        lines += _field_rows(args) if args else ["_None._"]
        lines += [""]

        rets = function.get("Returns")
        lines += ["**Returns**", ""]
        lines += _field_rows(rets) if rets else ["_None._"]
        lines += [""]

        blizzard = strip_colour(function.get("FullName"))
        if blizzard:
            lines += [f"Blizzard's own rendering: `{blizzard}`", ""]

        owner_name = owner.get("Name") or "?"
        lines += [
            f"System: `{owner_name}`"
            + (f" · Namespace: `{owner['Namespace']}`" if owner.get("Namespace") else "")
            + (" · Widget methods" if owner.get("Type") == "ScriptObject" else ""),
        ]
        self._write(directory / f"{_safe_name(name)}.md", lines)
        self.index.append((qualified, str(directory.relative_to(self.out) / f"{_safe_name(name)}.md")))

    def event_page(self, event: dict[str, Any], owner: dict[str, Any]) -> None:
        literal = event.get("LiteralName") or event.get("Name") or "unknown"
        directory = self.out / "events" / _bucket(literal)
        lines = [self._header(), "", f"# {literal}", ""]
        payload = event.get("Payload")
        lines += ["**Payload**", ""]
        lines += _field_rows(payload) if payload else ["_No payload._"]
        lines += ["", f"System: `{owner.get('Name') or '?'}`"]
        self._write(directory / f"{_safe_name(literal)}.md", lines)
        self.index.append((literal, f"events/{_bucket(literal)}/{_safe_name(literal)}.md"))

    def table_page(self, table: dict[str, Any], owner: dict[str, Any]) -> None:
        name = table.get("Name") or "unknown"
        kind = table.get("Type") or "Table"
        folder = "enums" if kind == "Enumeration" else "structures"
        directory = self.out / folder
        lines = [self._header(), "", f"# {name}", "", f"_{kind}_", ""]

        values = table.get("Values")
        if values:
            lines += ["| Name | Value |", "|---|---|"]
            for value in values:
                lines.append(f"| `{value.get('Name')}` | {value.get('EnumValue')} |")
            lines += [""]

        fields = table.get("Fields")
        if fields:
            lines += ["**Fields**", ""] + _field_rows(fields) + [""]

        lines += [f"System: `{owner.get('Name') or '?'}`"]
        self._write(directory / f"{_safe_name(name)}.md", lines)
        self.index.append((name, f"{folder}/{_safe_name(name)}.md"))

    # -- drivers -----------------------------------------------------------
    def build(self) -> None:
        for key in sorted(self.systems):
            system = self.systems[key]
            if not isinstance(system, dict):
                continue
            namespace = system.get("Namespace")
            is_widget = system.get("Type") == "ScriptObject"

            if namespace:
                directory = self.out / "namespaces" / _safe_name(namespace)
                prefix = f"{namespace}."
            elif is_widget:
                directory = self.out / "widgets" / _safe_name(system.get("Name") or key)
                prefix = f"{system.get('Name')}:"
            else:
                directory = None
                prefix = ""

            for function in system.get("Functions") or []:
                name = function.get("Name") or "unknown"
                if directory is None:
                    # A system with no namespace holds plain globals.
                    target = self.out / "globals" / _bucket(name)
                    self.function_page(function, system, target, name)
                else:
                    self.function_page(function, system, directory, prefix + name)

            for event in system.get("Events") or []:
                self.event_page(event, system)
            for table in system.get("Tables") or []:
                self.table_page(table, system)

        self.write_indexes()

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
        for field, value in info.items():
            lines.append(f"| {field} | {value if value is not None else '_unknown_'} |")
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
        self._write(self.out / "BUILD.md", lines)
        return info


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("capture", type=Path, help="ForeverProbe SavedVariables capture")
    parser.add_argument("--out", type=Path, default=Path("reference/api"))
    parser.add_argument("--json", type=Path, default=Path("data/api.json"),
                        help="normalized machine-readable copy")
    parser.add_argument("--clean", action="store_true",
                        help="remove the output tree first, so deletions show in the diff")
    args = parser.parse_args()

    data = svlua.parse_file(str(args.capture))
    db = data.get("ForeverProbeDB") or {}
    docs = db.get("apiDocs")
    if not docs or not docs.get("systems"):
        print(f"{args.capture}: no apiDocs in this capture. Run /fprobe docs dump first.",
              file=sys.stderr)
        return 1

    if args.clean and args.out.exists():
        shutil.rmtree(args.out)

    builder = ReferenceBuilder(args.out, docs)
    builder.build()
    info = builder.write_build_info(args.capture)

    args.json.parent.mkdir(parents=True, exist_ok=True)
    with args.json.open("w", encoding="utf-8", newline="\n") as handle:
        json.dump({"build": info, "systems": docs["systems"]}, handle,
                  indent=1, ensure_ascii=False, sort_keys=True)

    print(f"{builder.written} pages -> {args.out}")
    print(f"  {info['systems']} systems, {info['functions']} functions, "
          f"{info['events']} events, {info['tables']} tables")
    print(f"  machine-readable copy -> {args.json}")
    if not (docs.get("client") or {}).get("build"):
        print("  WARNING: capture does not record its client build; re-dump to fix")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
