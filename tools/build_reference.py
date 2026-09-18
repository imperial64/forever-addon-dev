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

    def banner(self, entries: list[dict[str, Any]], depth: int = 4) -> list[str]:
        lines: list[str] = []
        for entry in entries:
            verdict = entry.get("verdict", "caution")
            label = VERDICT_LABEL.get(verdict, verdict.upper())
            scope = entry.get("scope", "always")
            scope_text = "in combat only" if scope == "in-combat" else "at all times"
            measured = self.meta.get("measured_on", "")
            build = self.meta.get("build", "")
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


class ReferenceBuilder:
    def __init__(self, out_dir: Path, docs: dict[str, Any],
                 restrictions: Restrictions | None = None) -> None:
        self.out = out_dir
        self.docs = docs
        self.systems: dict[str, Any] = docs["systems"]
        self.restrictions = restrictions or Restrictions(None)
        self.written = 0
        self.index: list[tuple[str, str]] = []  # (symbol, path) for the names index
        self.annotated: set[str] = set()
        self.surface: dict[str, Any] = {}
        self.stubs = 0

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
        lines = [self._header(), "", f"# {qualified}", ""]

        # Our measured restrictions go ABOVE Blizzard's own flag: the flag says
        # the call is gated, ours says what the client actually did.
        measured = self.restrictions.for_function(qualified, owner.get("Namespace"))
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
        measured = self.restrictions.by_event.get(literal, [])
        if measured:
            lines += self.restrictions.banner(measured, self._depth(directory))
            for entry in measured:
                self.annotated.add(entry["id"])
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

        # Deliberately after the documented pass, so a stub never shadows a real
        # page.
        self.write_stubs()
        self.write_indexes()

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
        lines = [
            self._header(), "", "# Restrictions", "",
            f"Measured on client {meta.get('client')} build {meta.get('build')}"
            f" (interface {meta.get('interface')}) with {meta.get('measured_by')}.", "",
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
                    summary=" ".join((entry.get("summary") or "").split()),
                )
            )
        lines.append("")
        for entry in sorted(entries, key=lambda e: e["id"]):
            lines += [f"## {entry['id']}", ""]
            lines.append(" ".join((entry.get("summary") or "").split()))
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
                    summary=" ".join((entry.get("summary") or "").split()),
                )
            )
        meta = self.restrictions.meta
        rows += ["",
                 f"Measured {meta.get('measured_on')} on client {meta.get('client')} build"
                 f" {meta.get('build')}. Detail and evidence for each:"
                 " `reference/api/RESTRICTIONS.md`."]

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
    parser.add_argument("--restrictions", type=Path, default=Path("research/restrictions.yaml"))
    parser.add_argument("--restrictions-json", type=Path, default=Path("data/restrictions.json"))
    parser.add_argument("--findings", type=Path, default=Path("research/findings.md"))
    parser.add_argument("--skill-table", type=Path,
                        default=Path("skills/restrictions/SKILL.md"),
                        help="skill file whose generated restrictions table to refresh")
    parser.add_argument("--surface", type=Path, default=None,
                        help="a capture containing globalFunctions/namespaces, used to "
                             "stub symbols the client has but Blizzard does not document")
    parser.add_argument("--strict", action="store_true",
                        help="fail if any restriction fails to resolve")
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

    restrictions = Restrictions(args.restrictions, findings_link=str(args.findings).replace("\\", "/"))
    builder = ReferenceBuilder(args.out, docs, restrictions)
    if args.surface:
        surface_db = svlua.parse_file(str(args.surface)).get("ForeverProbeDB") or {}
        builder.surface = {
            "globals": surface_db.get("globalFunctions") or [],
            "namespaces": surface_db.get("namespaces") or {},
        }
    builder.build()
    builder.write_restrictions_page()
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

    if restrictions.entries:
        args.restrictions_json.parent.mkdir(parents=True, exist_ok=True)
        with args.restrictions_json.open("w", encoding="utf-8", newline="\n") as handle:
            # default=str because YAML parses a bare 2026-09-18 into a date
            # object, and the linter wants a string it can print.
            json.dump({"meta": restrictions.meta, "entries": restrictions.entries},
                      handle, indent=1, ensure_ascii=False, sort_keys=True, default=str)

    args.json.parent.mkdir(parents=True, exist_ok=True)
    with args.json.open("w", encoding="utf-8", newline="\n") as handle:
        json.dump({"build": info, "systems": docs["systems"]}, handle,
                  indent=1, ensure_ascii=False, sort_keys=True)

    print(f"{builder.written} pages -> {args.out}")
    print(f"  {info['systems']} systems, {info['functions']} functions, "
          f"{info['events']} events, {info['tables']} tables")
    if builder.stubs:
        print(f"  {builder.stubs} undocumented symbols stubbed from the client surface")
    print(f"  machine-readable copy -> {args.json}")
    if restrictions.entries:
        print(f"  {len(restrictions.entries)} restrictions, "
              f"{len(builder.annotated)} matched pages -> {args.restrictions_json}")
    if not (docs.get("client") or {}).get("build"):
        print("  WARNING: capture does not record its client build; re-dump to fix")
    for problem in problems:
        print(f"  RESTRICTION: {problem}", file=sys.stderr)
    if problems and args.strict:
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
