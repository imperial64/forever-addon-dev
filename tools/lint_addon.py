"""Check addon Lua against what this client actually permits.

Two sources of truth, both generated, neither hand-maintained here:

    data/api.json          - every symbol the client has, from the capture
    data/restrictions.json - what is forbidden, secret, throttled or protected,
                             from research/restrictions.yaml

**This is a regex linter, not a Lua parser.** It reads source as text, so it
cannot follow a call through a local alias, a table lookup or anything dynamic.
It will therefore miss things. It is built to be quiet and specific rather than
thorough: a linter that cries wolf on a probe addon gets turned off, and then it
catches nothing at all.

The `.toc` is linted too, because two of the mistakes that cost other porters a
day are header mistakes, not code mistakes.

Usage:
    python tools/lint_addon.py path/to/Addon.lua [more.lua ...]
    python tools/lint_addon.py path/to/Addon.toc
    python tools/lint_addon.py path/to/AddonFolder/

Suppressing a finding. Some addons call forbidden things deliberately - a probe
that measures restrictions is the obvious case. Put a comment on the line, or on
the line above it:

    UseAction(1)  -- lint-allow: forbidden-call - measuring the refusal on purpose

The reason is required. A bare suppression is itself reported, because a
suppression with no stated reason is indistinguishable from a mistake. In a
`.toc` the same suppression is written with the `.toc` comment marker:

    # lint-allow: toc-no-forever-interface - retail-only build of this addon
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any, Iterable, NamedTuple

REPO = Path(__file__).resolve().parent.parent

# A Lua comment may sit on the offending line or the line above it.
_SUPPRESS = re.compile(r"--\s*lint-allow:\s*([\w-]+)\s*(?:-+\s*(?P<reason>.+))?$")
# The same thing spelled for a .toc, whose comment marker is `#`. Kept separate
# from _SUPPRESS rather than folded into it: `#` is Lua's length operator, and a
# shared pattern would let `#t -- lint-allow: ...` mean two things at once.
_TOC_SUPPRESS = re.compile(r"#\s*lint-allow:\s*([\w-]+)\s*(?:-+\s*(?P<reason>.+))?$")

# `## Directive: value` in a .toc. Anything else is a comment, a file entry or
# blank, and the difference is what the header-break rule turns on.
_TOC_DIRECTIVE = re.compile(r"^##\s*([A-Za-z][\w-]*)\s*:\s*(.*)$")

# The directives that name a global the client will restore and re-serialise.
_SV_DIRECTIVES = ("savedvariables", "savedvariablespercharacter")

# Call sites: C_Foo.Bar( ... ) and bare Baz( ... ). Deliberately not trying to
# handle method calls or aliases - see the module docstring.
_NAMESPACED = re.compile(r"\b(C_[A-Za-z0-9_]+)\s*\.\s*([A-Za-z0-9_]+)\s*\(")
_BARE = re.compile(r"(?<![\w.:])([A-Z][A-Za-z0-9_]*)\s*\(")

# RegisterEvent("FOO") and its unregister twin.
_REGISTER = re.compile(r"[:.]\s*RegisterEvent\s*\(\s*[\"']([A-Z0-9_]+)[\"']")

# The idiom that silently sends a Retail addon down its Classic path here.
_VERSION_TRAP = re.compile(
    r"select\s*\(\s*4\s*,\s*GetBuildInfo\s*\(\s*\)\s*\)\s*(>=|>|<|<=)\s*(\d{5,})"
)

# tostring() wrapped straight around a read that can return a secret.
_TOSTRING = re.compile(r"\btostring\s*\(\s*([A-Za-z_][\w.]*)\s*\(")

# An assignment at column 0 - file scope, near enough for a regex. The RHS is
# deliberately not captured: strings are blanked before matching, so the RHS has
# to be read back off the raw line. `=(?!=)` keeps `==` out.
_FILE_SCOPE_ASSIGN = re.compile(r"^([A-Za-z_]\w*)\s*=(?!=)\s*")

# WOW_PROJECT_ID on either side of a comparison.
_PROJECT_ID = re.compile(r"\bWOW_PROJECT_ID\b\s*[=~]=|[=~]=\s*\bWOW_PROJECT_ID\b")

# Strings and comments, blanked before matching so a mention is not a call.
#
# ONE alternation, not two passes. Blanking strings first and comments second
# looks equivalent and is not: an apostrophe inside a comment - "Blizzard's" -
# opens a string that runs to the next apostrophe, blanking every line between
# them. That made this linter silently see almost no code and report a clean
# run, which is the worst failure available to a tool whose job is finding
# things. Scanning a single alternation left to right means whichever construct
# opens first wins, which is what Lua does.
_LUA_SKIP = re.compile(
    r"""
      --\[\[ .*? \]\]            # long comment
    | --[^\n]*                   # line comment
    | "(?:\\.|[^"\\])*"          # double-quoted string
    | '(?:\\.|[^'\\])*'          # single-quoted string
    | \[\[ .*? \]\]              # long string
    """,
    re.S | re.X,
)


class Finding(NamedTuple):
    path: Path
    line: int
    rule: str
    severity: str  # error | warning | note
    message: str
    evidence: str

    def format(self, root: Path) -> str:
        try:
            shown = self.path.relative_to(root)
        except ValueError:
            shown = self.path
        tail = f"  [{self.evidence}]" if self.evidence else ""
        return f"{shown}:{self.line}: {self.severity}: {self.rule}: {self.message}{tail}"


def _blank_out(text: str) -> str:
    """Replace string and comment bodies with spaces, keeping offsets intact.

    Offsets have to survive so line numbers stay right, and blanking rather than
    deleting is what keeps a function named inside a comment from looking like a
    call.
    """
    def blank(match: re.Match[str]) -> str:
        # Newlines survive so line numbers stay right; everything else blanks.
        return re.sub(r"[^\n]", " ", match.group(0))
    return _LUA_SKIP.sub(blank, text)


class Rules:
    def __init__(self, api: dict[str, Any], restrictions: dict[str, Any]) -> None:
        self.symbols: set[str] = set()
        self.namespaces: set[str] = set()
        for key, system in (api.get("systems") or {}).items():
            namespace = system.get("Namespace")
            if namespace:
                self.namespaces.add(namespace)
            for function in system.get("Functions") or []:
                name = function.get("Name")
                if not name:
                    continue
                self.symbols.add(f"{namespace}.{name}" if namespace else name)

        self.entries = restrictions.get("entries") or []
        self.by_symbol: dict[str, dict[str, Any]] = {}
        self.by_namespace: dict[str, dict[str, Any]] = {}
        self.refused_events: dict[str, dict[str, Any]] = {}
        for entry in self.entries:
            for symbol in entry.get("symbols") or []:
                self.by_symbol[symbol] = entry
            for namespace in entry.get("namespaces") or []:
                self.by_namespace[namespace] = entry
            if entry.get("verdict") == "forbidden":
                for event in entry.get("events") or []:
                    self.refused_events[event] = entry

    @staticmethod
    def _evidence(entry: dict[str, Any]) -> str:
        refs = entry.get("evidence") or []
        return "findings " + ", ".join(str(r) for r in refs) if refs else ""


def _suppressions(lines: list[str], pattern: re.Pattern[str] = _SUPPRESS,
                  comment: str = "--") -> dict[int, tuple[str, str | None]]:
    """Map line number -> (rule, reason) for suppressions that apply to it.

    The pattern and comment marker are arguments only so a .toc can be scanned
    with `#`; the Lua defaults are the ones every caller but lint_toc wants.
    """
    found: dict[int, tuple[str, str | None]] = {}
    for index, raw in enumerate(lines, start=1):
        match = pattern.search(raw)
        if not match:
            continue
        rule = match.group(1)
        reason = (match.group("reason") or "").strip() or None
        found[index] = (rule, reason)
        # A suppression on its own line covers the line below it.
        if raw.strip().startswith(comment):
            found[index + 1] = (rule, reason)
    return found


def _adder(path: Path, suppressed: dict[int, tuple[str, str | None]],
           findings: list[Finding]):
    """Build the `add` a linting pass reports through.

    Shared by lint_file and lint_toc so the suppression rules - including that a
    reasonless suppression is itself a finding - cannot drift apart between the
    two file kinds.
    """
    def add(line: int, rule: str, severity: str, message: str, evidence: str = "") -> None:
        held = suppressed.get(line)
        if held and held[0] == rule:
            if held[1] is None:
                findings.append(Finding(
                    path, line, "bare-suppression", "warning",
                    f"`lint-allow: {rule}` with no reason given. State why, or remove it.",
                    "",
                ))
            return
        findings.append(Finding(path, line, rule, severity, message, evidence))
    return add


def _declared_sv_globals(directory: Path) -> set[str]:
    """Globals a sibling .toc asks the client to save and restore.

    Every *.toc in the directory counts and they are unioned: an addon may ship
    one .toc per flavour, and a global saved under any of them is still one this
    file must not clobber.

    Directives that land after a header break count too, even though the client
    ignores them. lint_toc reports that break separately; taking the author at
    their word here keeps one bug from hiding the other.
    """
    names: set[str] = set()
    for toc in sorted(directory.glob("*.toc")):
        text = toc.read_text(encoding="utf-8", errors="replace")
        for raw in text.split("\n"):
            match = _TOC_DIRECTIVE.match(raw.strip())
            if match and match.group(1).lower() in _SV_DIRECTIVES:
                names.update(part.strip() for part in match.group(2).split(",") if part.strip())
    return names


def lint_file(path: Path, rules: Rules) -> list[Finding]:
    text = path.read_text(encoding="utf-8", errors="replace")
    lines = text.split("\n")
    suppressed = _suppressions(lines)
    code = _blank_out(text)
    code_lines = code.split("\n")
    findings: list[Finding] = []
    add = _adder(path, suppressed, findings)
    sv_globals = _declared_sv_globals(path.parent)

    raw_lines = lines
    for number, source in enumerate(code_lines, start=1):
        raw = raw_lines[number - 1] if number <= len(raw_lines) else ""
        # -- restricted and absent calls ---------------------------------
        for namespace, member in _NAMESPACED.findall(source):
            qualified = f"{namespace}.{member}"
            entry = rules.by_symbol.get(qualified) or rules.by_namespace.get(namespace)
            if entry:
                _report_entry(add, number, qualified, entry, rules)
            elif namespace in rules.namespaces and qualified not in rules.symbols:
                add(number, "not-on-this-client", "error",
                    f"`{qualified}` is not on this client. Check reference/guides/aliases.md.")

        for name in _BARE.findall(source):
            entry = rules.by_symbol.get(name)
            if entry:
                _report_entry(add, number, name, entry, rules)

        # -- refused event subscriptions ---------------------------------
        #
        # Matched against the RAW line, because the event name lives in a string
        # and strings are blanked before matching - reading it from `source`
        # meant these two checks could never fire, and a check that cannot fire
        # looks exactly like a codebase with no problems.
        # `RegisterEvent` surviving in the blanked line is what proves the call
        # site is real code rather than a mention in a comment.
        for event in (_REGISTER.findall(raw) if "RegisterEvent" in source else []):
            entry = rules.refused_events.get(event)
            if entry:
                add(number, "refused-event", "error",
                    f"Addons may not register `{event}`. The call does not raise; the "
                    "frame simply never receives it.",
                    Rules._evidence(entry))
            elif "pcall" not in raw:
                add(number, "unguarded-register", "warning",
                    "RegisterEvent on an event this client does not have RAISES and aborts "
                    "the rest of the file. Wrap it in pcall.",
                    "findings P.1")

        # -- the version-check trap --------------------------------------
        for _, threshold in _VERSION_TRAP.findall(source):
            add(number, "version-check-trap", "error",
                f"`select(4, GetBuildInfo()) >= {threshold}` is false on Forever, whose "
                "interface is 16001. This sends Retail addons down their Classic path.",
                "findings 0.5")

        # -- unguarded tostring on a read that can be secret --------------
        for called in _TOSTRING.findall(source):
            entry = rules.by_symbol.get(called)
            if entry and entry.get("verdict") == "secret":
                findings[:] = [f for f in findings
                               if not (f.line == number and f.rule == "secret-read")]
                add(number, "secret-tostring", "error",
                    f"`tostring({called}(...))` does not launder a secret - it returns a "
                    "secret STRING that throws wherever it is next indexed. Use "
                    "issecretvalue before and after conversion.",
                    "findings P.2")

        # -- clobbering a restored SavedVariables table -------------------
        #
        # `Name = Name or {}` is the safe idiom and must stay silent: it keeps
        # whatever was restored. Only an unconditional assignment is the bug.
        assignment = _FILE_SCOPE_ASSIGN.match(source) if sv_globals else None
        if assignment and assignment.group(1) in sv_globals:
            name = assignment.group(1)
            # Blanking preserves offsets, so the blanked match indexes the raw
            # line - which is where the right-hand side has survived.
            rhs = raw[assignment.end():].strip()
            if not re.match(rf"{re.escape(name)}\s+or\b", rhs):
                add(number, "sv-file-scope-init", "warning",
                    f"`{name}` is declared in the .toc, and this client loads saved "
                    "variables around addon file execution. An unconditional file-scope "
                    "assignment replaces the restored table, and the client then "
                    "serialises the empty one. Bind the global inside an ADDON_LOADED "
                    "handler and only mutate it.",
                    "findings 11, 12")

        # -- WOW_PROJECT_ID cannot see Forever ----------------------------
        if _PROJECT_ID.search(source):
            add(number, "project-id-detection", "warning",
                "Forever ships no `WOW_PROJECT_*` constant of its own and reports "
                "`WOW_PROJECT_MAINLINE`, so `WOW_PROJECT_ID` cannot tell it from retail. "
                "Blizzard's own modules gate on the .toc directive "
                "`## AllowLoadGameType: standard, camelot` instead.",
                "findings 10")

    return findings


def _report_entry(add, line: int, symbol: str, entry: dict[str, Any], rules: Rules) -> None:
    verdict = entry.get("verdict")
    scope = entry.get("scope", "always")
    evidence = Rules._evidence(entry)
    summary = " ".join((entry.get("summary") or "").split())
    if verdict == "forbidden":
        add(line, "forbidden-call", "error",
            f"`{symbol}` is forbidden {'at all times' if scope == 'always' else 'in combat'}. "
            + summary, evidence)
    elif verdict == "blocked":
        add(line, "blocked-in-combat", "warning",
            f"`{symbol}` is blocked in combat. " + summary, evidence)
    elif verdict == "secret":
        add(line, "secret-read", "warning",
            f"`{symbol}` returns a secret "
            + ("at all times" if scope == "always" else "in combat")
            + ". " + summary, evidence)
    elif verdict == "silent":
        add(line, "silent-failure", "warning",
            f"`{symbol}` can fail silently. " + summary, evidence)
    elif verdict == "caution":
        add(line, "caution", "note",
            f"`{symbol}`: " + summary, evidence)


def lint_toc(path: Path, rules: Rules) -> list[Finding]:
    """Check an addon's .toc header.

    `rules` is unused. The signature matches lint_file so main can hand a path
    to whichever suits its suffix, and nothing in the restriction data has
    anything to say about a .toc yet.
    """
    lines = path.read_text(encoding="utf-8", errors="replace").split("\n")
    findings: list[Finding] = []
    add = _adder(path, _suppressions(lines, _TOC_SUPPRESS, "#"), findings)

    interfaces: list[tuple[int, str]] = []
    seen_directive = False
    header_ended = False
    for number, raw in enumerate(lines, start=1):
        stripped = raw.strip()
        directive = _TOC_DIRECTIVE.match(stripped)
        if directive:
            name, value = directive.group(1), directive.group(2).strip()
            if header_ended:
                add(number, "toc-header-break", "error",
                    f"`## {name}` sits below the end of the header - a blank line or a "
                    "file entry above it closed it. The client stops reading directives "
                    "there and does not say so; a `## SavedVariables` below the break "
                    "means the addon's saved data is dropped at login. Keep every "
                    "directive contiguous at the top.",
                    "findings 11")
                # One report per break. The directives after it are contiguous
                # with this one, and naming them all would bury the fix.
                header_ended = False
            seen_directive = True
            if name.lower() == "interface":
                interfaces.append((number, value))
            continue
        if stripped.startswith("#"):
            continue  # a plain comment does not end the header
        if seen_directive:
            header_ended = True  # blank line, or the file list has started

    if interfaces:
        versions = {part.strip()
                    for _, value in interfaces
                    for part in value.split(",") if part.strip()}
        if "16001" not in versions:
            add(interfaces[0][0], "toc-no-forever-interface", "note",
                "No `## Interface: 16001`, so this addon does not load on Forever. One "
                ".toc may carry several comma-separated interface versions - "
                "`## Interface: 110107, 16001` - so adding Forever does not mean "
                "splitting the .toc per flavour.",
                "findings 9")

    return findings


def iter_lua(targets: Iterable[Path]) -> list[Path]:
    files: list[Path] = []
    for target in targets:
        if target.is_dir():
            files.extend(sorted(target.rglob("*.lua")))
        elif target.suffix == ".lua":
            files.append(target)
    return files


def iter_toc(targets: Iterable[Path]) -> list[Path]:
    files: list[Path] = []
    for target in targets:
        if target.is_dir():
            files.extend(sorted(target.rglob("*.toc")))
        elif target.suffix == ".toc":
            files.append(target)
    return files


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("targets", nargs="+", type=Path)
    parser.add_argument("--api", type=Path, default=REPO / "data/api.json")
    parser.add_argument("--restrictions", type=Path, default=REPO / "data/restrictions.json")
    parser.add_argument("--quiet", action="store_true", help="findings only, no summary")
    parser.add_argument("--warnings-as-errors", action="store_true")
    args = parser.parse_args()

    for required in (args.api, args.restrictions):
        if not required.exists():
            print(f"missing {required}. Run tools/build_reference.py first.", file=sys.stderr)
            return 2

    rules = Rules(json.loads(args.api.read_text(encoding="utf-8")),
                  json.loads(args.restrictions.read_text(encoding="utf-8")))

    lua_files = iter_lua(args.targets)
    toc_files = iter_toc(args.targets)
    if not lua_files and not toc_files:
        print("no .lua or .toc files found", file=sys.stderr)
        return 2

    findings: list[Finding] = []
    for path in lua_files:
        findings.extend(lint_file(path, rules))
    for path in toc_files:
        findings.extend(lint_toc(path, rules))

    order = {"error": 0, "warning": 1, "note": 2}
    findings.sort(key=lambda f: (str(f.path), f.line, order.get(f.severity, 3)))
    for finding in findings:
        print(finding.format(REPO))

    errors = sum(1 for f in findings if f.severity == "error")
    warnings = sum(1 for f in findings if f.severity == "warning")
    if not args.quiet:
        print(f"\n{len(lua_files) + len(toc_files)} file(s), {errors} error(s), "
              f"{warnings} warning(s), "
              f"{len(findings) - errors - warnings} note(s)")
        if not findings:
            print("clean against build "
                  + str((json.loads(args.restrictions.read_text(encoding='utf-8'))
                         .get('meta') or {}).get('build', '?')))
        print("Regex-based: it cannot follow aliases, table lookups or dynamic calls, "
              "so a clean run is not a proof of correctness.")

    if errors or (warnings and args.warnings_as_errors):
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
