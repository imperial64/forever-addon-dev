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

# A file-scope local taken from a global: `local db = X`, `local db = X or {}`,
# `local cfg = X.field`, `local cfg = X[...]`. Matched on the blanked line, so
# a trailing comment is already spaces. Column 0 stands in for file scope.
_FILE_SCOPE_ALIAS = re.compile(
    r"^local\s+([A-Za-z_]\w*)\s*=\s*([A-Za-z_]\w*)\b\s*(?=$|or\b|\.\s*[A-Za-z_]|\[)")

# WOW_PROJECT_ID on either side of a comparison.
_PROJECT_ID = re.compile(r"\bWOW_PROJECT_ID\b\s*[=~]=|[=~]=\s*\bWOW_PROJECT_ID\b")

# Every spelling of "does loadstring_untainted exist". Matched against the RAW
# line, because two of the spellings carry the name inside a string; a match
# only counts when its first character survives blanking, which is what proves
# `rawget` / `_G` / the bare name is code and not a mention in a comment.
_LSU_REF = re.compile(
    r"""
      rawget \s*\( \s*_G\s*, \s*["']loadstring_untainted["'] \s*\)
    | _G \s*\[ \s*["']loadstring_untainted["'] \s*\]
    | (?<![\w.:"'])(?:_G\s*\.\s*)?loadstring_untainted\b
    """,
    re.X,
)
# What makes a reference a feature TEST rather than, say, a value being recorded
# into a table: a branch, a boolean operator or a comparison on the same line.
# Read off the blanked line, so `and` in a string or comment does not count.
#
# Limits: a test split across lines (`local has = loadstring_untainted` then
# `if has then` further down) is missed, and so is anything reached through a
# local alias. Recording `type(...)` into a table without testing it - which is
# what the probe does - is silent on purpose.
_FEATURE_TEST_CONTEXT = re.compile(
    r"\b(?:if|elseif|while|until|not|and|or|assert)\b|[=~]="
)

# Enum.ForbiddenAspect, as far as a regex can see it. 1 (SetToDefaults) through
# 1024 (ChangeParent) are the same on 69913 and 70009; everything above moved:
#
#                           69913    70009
#   SetTexture                  -     2048
#   QueryRotation               -     4096
#   QueryAnimationProgress   2048     8192
#   AddAnimations            4096    16384
#
# So a literal above 1024 means a different aspect depending on the build it was
# written against. Heuristic, and deliberately narrow: a number from the table
# fires only when the same (blanked) line names ForbiddenAspect - the enum or
# any of the *ForbiddenAspects widget methods - or assigns it to one of the four
# moved names, which is what a hand-rolled table keyed by aspect name looks
# like. It misses a literal reached through a local, a constant defined on
# another line, and bit.bor() arithmetic split across lines, and it cannot see
# whether a number next to a ForbiddenAspect mention is really the aspect
# argument. Anything else that happens to be 2048 or 4096 stays silent.
_ASPECT_70009 = {2048: "SetTexture", 4096: "QueryRotation",
                 8192: "QueryAnimationProgress", 16384: "AddAnimations"}
_ASPECT_69913 = {2048: "QueryAnimationProgress", 4096: "AddAnimations"}
_ASPECT_NUMBER = re.compile(
    r"(?<![\w.])(2048|4096|8192|16384|0[xX]0*(?:800|1000|2000|4000))(?![\w.])")
_ASPECT_CONTEXT = re.compile(r"ForbiddenAspect")
_ASPECT_KEYED = re.compile(
    r"\b(?:SetTexture|QueryRotation|QueryAnimationProgress|AddAnimations)\s*=\s*"
    r"(?:2048|4096|8192|16384|0[xX]0*(?:800|1000|2000|4000))(?![\w.])")

# `## LoadSavedVariablesFirst: 1` - a real directive on this client, used by
# Blizzard's own Blizzard_DamageMeter.toc on the forever branch. With it the
# saved globals exist before the addon's files run; without it they arrive at
# ADDON_LOADED. Only these two values are known.
_SV_FIRST_DIRECTIVE = "loadsavedvariablesfirst"
_SV_FIRST_VALUES = ("0", "1")

# A per-file load condition after a .toc file entry, as Blizzard's forever
# branch writes them: `Camelot\Overrides.lua [AllowLoadGameType camelot]`. The
# leading whitespace is what separates it from a `[TextLocale]`-style variable
# inside the path itself. More than one group is tolerated.
_TOC_FILE_CONDITIONS = re.compile(r"(?:\s+\[[^\]\n]*\])+\s*$")
_TOC_FILE_CONDITION = re.compile(r"\[\s*([A-Za-z]\w*)?\s*([^\]]*)\]")
_KNOWN_FILE_CONDITIONS = {"allowloadgametype"}

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


def _loads_sv_first(directory: Path) -> bool:
    """Whether a sibling .toc sets `## LoadSavedVariablesFirst: 1`.

    Unioned over every .toc the same way _declared_sv_globals is: if any flavour
    restores before file scope, a file-scope assignment is destructive there.
    """
    for toc in sorted(directory.glob("*.toc")):
        text = toc.read_text(encoding="utf-8", errors="replace")
        for raw in text.split("\n"):
            match = _TOC_DIRECTIVE.match(raw.strip())
            if (match and match.group(1).lower() == _SV_FIRST_DIRECTIVE
                    and match.group(2).strip() == "1"):
                return True
    return False


def toc_file_entry(line: str) -> tuple[str, list[tuple[str, str]]]:
    """Split a .toc file-list line into its path and its load conditions.

    `Camelot\\Overrides.lua [AllowLoadGameType camelot]` gives
    ("Camelot\\Overrides.lua", [("AllowLoadGameType", "camelot")]). Anything
    that checks the path - existence, extension - must use the first half, or a
    conditioned entry reads as a file whose name ends in `]`.
    """
    stripped = line.strip()
    tail = _TOC_FILE_CONDITIONS.search(stripped)
    if not tail:
        return stripped, []
    conditions = [((m.group(1) or ""), m.group(2).strip())
                  for m in _TOC_FILE_CONDITION.finditer(tail.group(0))]
    return stripped[:tail.start()].rstrip(), conditions


def lint_file(path: Path, rules: Rules) -> list[Finding]:
    text = path.read_text(encoding="utf-8", errors="replace")
    lines = text.split("\n")
    suppressed = _suppressions(lines)
    code = _blank_out(text)
    code_lines = code.split("\n")
    findings: list[Finding] = []
    add = _adder(path, suppressed, findings)
    sv_globals = _declared_sv_globals(path.parent)
    sv_first = _loads_sv_first(path.parent) if sv_globals else False
    # For sv-file-scope-alias: every line that gives a saved global a new table
    # (anything but `X = X or ...`), at any depth.
    replaced: dict[str, list[int]] = {}
    for index, source in enumerate(code_lines, start=1):
        match = re.match(r"^\s*([A-Za-z_]\w*)\s*=(?!=)", source)
        if match and match.group(1) in sv_globals:
            name = match.group(1)
            rhs = lines[index - 1][match.end():].strip() if index <= len(lines) else ""
            if not re.match(rf"{re.escape(name)}\s+or\b", rhs):
                replaced.setdefault(name, []).append(index)

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
                # Which way it goes wrong depends on when the client restores,
                # and `## LoadSavedVariablesFirst` is what decides that.
                if sv_first:
                    message = (
                        f"`{name}` is declared in the .toc and `## LoadSavedVariablesFirst: 1` "
                        "restores it BEFORE this file runs, so this unconditional assignment "
                        "discards the restored data and the client serialises the "
                        f"replacement. Write `{name} = {name} or {{...}}`, or bind it in "
                        "ADDON_LOADED and only mutate it.")
                else:
                    message = (
                        f"`{name}` is declared in the .toc. Without `## LoadSavedVariablesFirst: "
                        "1` the client restores it at ADDON_LOADED, replacing whatever file "
                        f"scope put there - `{name} = {{...}}` and `{name} = {name} or {{...}}` "
                        "alike - so read and bind it at or after ADDON_LOADED. The "
                        "unconditional form also throws the data away the day the directive "
                        "is added.")
                add(number, "sv-file-scope-init", "warning", message, "findings P.31")

        # -- a file-scope local aliasing a saved global --------------------
        #
        # The idiom that loses data by default. Without the directive the
        # client REPLACES the global at ADDON_LOADED, so a local taken at file
        # scope keeps nil or the file's own table - an orphan - and every write
        # through it misses the table that is saved. With the directive the
        # alias is the restored table and is fine, unless the global is given
        # a new table after the alias was taken.
        #
        # Silent when the alias is re-pointed later in the file (`db = ...` on
        # any line but its declaration): that is the author handling the swap,
        # which is what the probe's rebind guard does. Blind to aliases taken
        # in another file and to re-pointing done through a function.
        alias = _FILE_SCOPE_ALIAS.match(source) if sv_globals else None
        if alias and alias.group(2) in sv_globals:
            alias_name, name = alias.group(1), alias.group(2)
            later = [n for n in replaced.get(name, []) if n > number]
            repointed = any(
                re.match(rf"^\s*{re.escape(alias_name)}\s*=(?!=)", other)
                for other in code_lines[number:])
            if repointed:
                pass
            elif not sv_first:
                add(number, "sv-file-scope-alias", "warning",
                    f"`local {alias_name}` takes `{name}` at file scope. `{name}` is declared in "
                    "the .toc, and without `## LoadSavedVariablesFirst: 1` the client "
                    "REPLACES it with the restored table at ADDON_LOADED, after this file "
                    f"has run. `{alias_name}` keeps what `{name}` held here - nil, or a table the "
                    "client then discards - so every write through it is lost at logout, "
                    "with no error. If this file gave it a table, the first launch hides "
                    "the loss: with no saved file on disk yet, the client leaves that table "
                    "in place, so it only fails from the second launch on. Bind "
                    f"`{alias_name}` in ADDON_LOADED, or set the directive and keep "
                    f"`{name} = {name} or {{...}}`.",
                    "findings P.31")
            elif later:
                add(number, "sv-file-scope-alias", "warning",
                    f"`local {alias_name}` takes `{name}` at file scope, and line {later[0]} gives "
                    f"`{name}` a new table afterwards. The client saves whatever `{name}` "
                    f"holds at logout, so from then on `{alias_name}` points at a table that is "
                    f"not saved. Re-point `{alias_name}` wherever `{name}` is replaced, or bind it "
                    "in ADDON_LOADED.",
                    "findings P.31")

        # -- loadstring_untainted as a snippet feature test --------------
        #
        # Blizzard_EnvironmentCleanup removes the global by design, so its
        # absence says nothing about whether secure snippets run - they do, out
        # of combat, on 70009. A test for it is a false negative that switches a
        # working feature off, the same failure shape as project-id-detection,
        # hence the same severity.
        if _FEATURE_TEST_CONTEXT.search(source):
            for ref in _LSU_REF.finditer(raw):
                if ref.start() < len(source) and not source[ref.start()].isspace():
                    add(number, "loadstring-untainted-test", "warning",
                        "`loadstring_untainted` is removed by Blizzard_EnvironmentCleanup by "
                        "design, so testing for it says snippets are unsupported where they "
                        "run. Probe instead: out of combat, make a SecureHandlerBaseTemplate "
                        "frame, `f:Execute(\"self:SetAttribute('ok', 42)\")` and read `ok` "
                        "back; skip in combat, where Execute is refused (ADDON_ACTION_BLOCKED) "
                        "or raises on a frame made in combat.",
                        "findings P.32")
                    break  # one per line

        # -- hardcoded ForbiddenAspect numbers above 1024 ------------------
        literal = None
        if _ASPECT_CONTEXT.search(source):
            found = _ASPECT_NUMBER.search(source)
            literal = found.group(1) if found else None
        if literal is None:
            keyed = _ASPECT_KEYED.search(source)
            literal = _ASPECT_NUMBER.search(keyed.group(0)).group(1) if keyed else None
        if literal is not None:
            value = int(literal, 0)
            then = _ASPECT_69913.get(value, "unused")
            add(number, "forbidden-aspect-literal", "warning",
                f"`{literal}` as a ForbiddenAspect is build-dependent: every aspect above "
                "ChangeParent (1024) was renumbered in 70009, where it is "
                f"{_ASPECT_70009[value]} (on 69913: {then}). Use "
                "`Enum.ForbiddenAspect.<Name>`.",
                "reference/api/enums/ForbiddenAspect.md")

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
            elif name.lower() == _SV_FIRST_DIRECTIVE and value not in _SV_FIRST_VALUES:
                add(number, "toc-sv-first-value", "warning",
                    f"`## {name}: {value}` - the only values this directive is known to take "
                    "are 0 and 1. With 1 the saved globals exist before the addon's files "
                    "run; otherwise they arrive at ADDON_LOADED.",
                    "findings P.31")
            continue
        if stripped.startswith("#"):
            continue  # a plain comment does not end the header
        if seen_directive:
            header_ended = True  # blank line, or the file list has started
        if not stripped:
            continue

        # A file entry. Its load conditions are stripped here and checked on
        # their own; nothing downstream may treat the bracket as part of the
        # path. The path is deliberately NOT checked for existence: this client
        # silently ignores an entry naming a missing file, and some workarounds
        # list one on purpose.
        _, conditions = toc_file_entry(stripped)
        for key, _value in conditions:
            if key.lower() not in _KNOWN_FILE_CONDITIONS:
                add(number, "toc-file-condition-unknown", "note",
                    f"`[{key or '?'} ...]` is not a per-file load condition this linter "
                    "knows. Blizzard's forever-branch .toc files use "
                    "`[AllowLoadGameType standard, camelot]`; check the spelling.",
                    "findings 10")

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
            # Two builds, because the two sources move separately: the API
            # reference regenerates from each client's documentation, while
            # the restrictions are measured by hand and lag behind it.
            api_build = (json.loads(args.api.read_text(encoding="utf-8"))
                         .get("build") or {}).get("build", "?")
            measured = (json.loads(args.restrictions.read_text(encoding="utf-8"))
                        .get("meta") or {}).get("build", "?")
            print(f"clean against the API of build {api_build}, and restrictions measured "
                  f"on build {measured} unless reference/api/RESTRICTIONS.md says otherwise"
                  if str(api_build) != str(measured) else f"clean against build {api_build}")
        print("Regex-based: it cannot follow aliases, table lookups or dynamic calls, "
              "so a clean run is not a proof of correctness.")

    if errors or (warnings and args.warnings_as_errors):
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
