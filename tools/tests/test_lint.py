"""Regression test for the linter.

Two checks in this linter were written, looked right, and could never fire -
they read the event name from source that had already had its strings blanked.
A silent check is indistinguishable from a clean codebase, which is the whole
failure mode a linter exists to prevent, so the rules are asserted rather than
eyeballed.

    python tools/tests/test_lint.py
"""

from __future__ import annotations

import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(REPO / "tools"))

import json  # noqa: E402
from lint_addon import Rules, lint_file, lint_toc, toc_file_entry  # noqa: E402

FIXTURES = REPO / "tools/tests/fixtures"

# Every rule the linter can emit, and the line of tools/tests/BadAddon.lua that
# must trigger it. Add a rule, add a line here - that is the point.
EXPECTED = {
    "refused-event": 10,
    "unguarded-register": 14,
    "forbidden-call": 17,
    "blocked-in-combat": 23,
    "secret-read": 26,
    "secret-tostring": 33,
    "silent-failure": 36,
    "version-check-trap": 39,
    "not-on-this-client": 44,
    "bare-suppression": 47,
    "sv-file-scope-init": 52,
    "project-id-detection": 60,
    "loadstring-untainted-test": 66,
    "forbidden-aspect-literal": 71,
    "sv-file-scope-alias": 76,
}

# The same contract for tools/tests/BadAddon.toc.
EXPECTED_TOC = {
    "toc-no-forever-interface": 5,
    "toc-sv-first-value": 8,
    "toc-header-break": 10,
    "toc-file-condition-unknown": 14,
}

# The two heuristic rules, line by line in tools/tests/fixtures/Heuristics/
# Heuristics.lua: the rule a line must fire, or None where it must stay silent.
# The silent lines are the point - a heuristic that fires on every 4096 in an
# addon gets switched off.
HEURISTICS = {
    4: "loadstring-untainted-test",   # type(...) == "function"
    5: "loadstring-untainted-test",   # if not _G.loadstring_untainted
    6: "loadstring-untainted-test",   # _G["..."] or loadstring
    7: "loadstring-untainted-test",   # rawget(_G, "...")
    8: None,                          # recorded into a table, not tested
    9: None,                          # in a comment
    10: None,                         # in a string
    12: "forbidden-aspect-literal",   # hex, next to a *ForbiddenAspects call
    14: "forbidden-aspect-literal",   # table keyed by a moved aspect name
    15: None,                         # the enum, which is the fix
    17: None,                         # the enum again
    18: None,                         # 4096 with no aspect in sight
    19: None,                         # 2048 and 16384, likewise
    20: None,                         # 1024 did not move
}

# `## LoadSavedVariablesFirst: 1` changes what sv-file-scope-init has to say.
SV_FIRST_LINE, SV_FIRST_KEPT_LINE = 3, 4
# ...and what sv-file-scope-alias has to say: with the directive an alias is
# the restored table, so only line 7, whose global is replaced on line 9, fires.
SV_FIRST_REPLACED_ALIAS_LINE = 7

# tools/tests/fixtures/SVAlias/SVAlias.lua, no directive: the lines that alias a
# saved global at file scope. Every other line must stay silent - the safe
# initialiser, a lookalike name, an undeclared global, an alias re-pointed
# later, a comment, a comparison and an alias inside a function.
SV_ALIAS_LINES = {3, 4, 5}

# `X = X or {}` on a declared SavedVariables global is the correct idiom and
# must stay silent. Asserted rather than assumed: a rule that over-fires on the
# right answer gets the whole linter switched off, which costs more than the
# rule ever saved.
SAFE_SV_LINE = 57


def main() -> int:
    api = json.loads((REPO / "data/api.json").read_text(encoding="utf-8"))
    restrictions = json.loads((REPO / "data/restrictions.json").read_text(encoding="utf-8"))
    rules = Rules(api, restrictions)

    failures: list[str] = []

    # 1. The broken addon must trigger every rule, on the expected line.
    findings = lint_file(REPO / "tools/tests/BadAddon.lua", rules)
    got = {(f.rule, f.line) for f in findings}
    for rule, line in EXPECTED.items():
        if (rule, line) not in got:
            actual = sorted(f.line for f in findings if f.rule == rule)
            failures.append(
                f"rule {rule!r} did not fire on line {line}"
                + (f" (fired on {actual})" if actual else " (never fired at all)")
            )
    unexpected = {f.rule for f in findings} - set(EXPECTED)
    if unexpected:
        failures.append(f"unknown rules emitted, add them to EXPECTED: {sorted(unexpected)}")

    # 2. And nothing at all on the line that does it right.
    safe = [f for f in findings if f.line == SAFE_SV_LINE]
    if safe:
        failures.append(
            f"line {SAFE_SV_LINE} is the safe `X = X or {{}}` idiom and must be silent:\n    "
            + "\n    ".join(f.format(REPO) for f in safe)
        )

    # 3. The .toc half, held to the same contract.
    toc_findings = lint_toc(REPO / "tools/tests/BadAddon.toc", rules)
    got_toc = {(f.rule, f.line) for f in toc_findings}
    for rule, line in EXPECTED_TOC.items():
        if (rule, line) not in got_toc:
            actual = sorted(f.line for f in toc_findings if f.rule == rule)
            failures.append(
                f"rule {rule!r} did not fire on BadAddon.toc line {line}"
                + (f" (fired on {actual})" if actual else " (never fired at all)")
            )
    unexpected_toc = {f.rule for f in toc_findings} - set(EXPECTED_TOC)
    if unexpected_toc:
        failures.append(
            f"unknown .toc rules emitted, add them to EXPECTED_TOC: {sorted(unexpected_toc)}")

    # 4. The heuristics: every pinned line fires exactly its rule, or nothing.
    heuristic = lint_file(FIXTURES / "Heuristics/Heuristics.lua", rules)
    for line, rule in HEURISTICS.items():
        rules_here = sorted(f.rule for f in heuristic if f.line == line)
        wanted = [rule] if rule else []
        if rules_here != wanted:
            failures.append(f"Heuristics.lua line {line}: expected {wanted}, got {rules_here}")
    stray = sorted({f.line for f in heuristic} - set(HEURISTICS))
    if stray:
        failures.append(f"Heuristics.lua fired on unpinned lines {stray}")

    # 5. The SavedVariables message follows the directive. BadAddon.toc's value
    #    is not 1, so BadAddon.lua gets the ADDON_LOADED wording; the SVFirst
    #    fixture sets it and gets the discard wording.
    late = [f for f in findings if f.rule == "sv-file-scope-init"]
    if not late or "at ADDON_LOADED" not in late[0].message:
        failures.append("sv-file-scope-init without the directive should say the restore "
                        "happens at ADDON_LOADED")
    first = lint_file(FIXTURES / "SVFirst/SVFirst.lua", rules)
    got_first = {(f.rule, f.line) for f in first}
    want_first = {("sv-file-scope-init", SV_FIRST_LINE),
                  ("sv-file-scope-alias", SV_FIRST_REPLACED_ALIAS_LINE)}
    if got_first != want_first:
        failures.append(f"SVFirst.lua: expected {sorted(want_first)}, got {sorted(got_first)}")
    else:
        init = next(f for f in first if f.rule == "sv-file-scope-init")
        if "discards the restored data" not in init.message:
            failures.append("sv-file-scope-init with the directive should say the assignment "
                            "discards the restored data")
        alias = next(f for f in first if f.rule == "sv-file-scope-alias")
        if "line 9 gives" not in alias.message:
            failures.append("sv-file-scope-alias with the directive should name the line "
                            f"that replaces the global: {alias.message}")

    # 5b. sv-file-scope-alias without the directive: pinned line by line.
    alias_findings = lint_file(FIXTURES / "SVAlias/SVAlias.lua", rules)
    for line in range(1, 15):
        rules_here = sorted(f.rule for f in alias_findings if f.line == line)
        wanted = ["sv-file-scope-alias"] if line in SV_ALIAS_LINES else []
        if rules_here != wanted:
            failures.append(f"SVAlias.lua line {line}: expected {wanted}, got {rules_here}")
    no_directive = next((f for f in alias_findings if f.line == 3), None)
    if no_directive and ("at ADDON_LOADED" not in no_directive.message
                         or "second launch" not in no_directive.message):
        failures.append("sv-file-scope-alias without the directive should say the swap is at "
                        "ADDON_LOADED and that the first launch hides it")
    if lint_toc(FIXTURES / "SVAlias/SVAlias.toc", rules):
        failures.append("SVAlias.toc is a correct header and must lint clean")

    # 6. Entry parsing: the condition must come off the path.
    for line, want in (
        (r"Camelot\A.lua [AllowLoadGameType camelot]",
         ("Camelot\\A.lua", [("AllowLoadGameType", "camelot")])),
        ("B.lua  [AllowLoadGameType standard, camelot]",
         ("B.lua", [("AllowLoadGameType", "standard, camelot")])),
        (r"Locales\[TextLocale].lua", (r"Locales\[TextLocale].lua", [])),
        ("C.lua", ("C.lua", [])),
    ):
        if toc_file_entry(line) != want:
            failures.append(f"toc_file_entry({line!r}) = {toc_file_entry(line)!r}, "
                            f"want {want!r}")

    # 7. The probes must be clean, .toc included. They call forbidden things
    #    deliberately and suppress each with a stated reason, so a clean run
    #    here also proves the suppression mechanism works. The SVFirst fixture
    #    .toc rides along: it is the correct spelling of both new .toc forms.
    for relative in ("addons/ForeverProbe/ForeverProbe.lua",
                     "addons/ForeverProbe/ForeverProbe.toc",
                     "addons/ForeverProbe/SavedVars.lua",
                     "addons/ForeverProbeSV_First/ForeverProbeSV_First.toc",
                     "addons/ForeverProbeSV_First/Core.lua",
                     "addons/ForeverProbeSV_First/Init.lua",
                     "addons/ForeverProbeSV_Late/ForeverProbeSV_Late.toc",
                     "addons/ForeverProbeSV_Late/Core.lua",
                     "addons/ForeverProbeSV_Late/Init.lua",
                     "tools/tests/fixtures/SVFirst/SVFirst.toc"):
        path = REPO / relative
        probe = (lint_toc if path.suffix == ".toc" else lint_file)(path, rules)
        if probe:
            failures.append(
                f"{path.name} is not clean:\n    "
                + "\n    ".join(f.format(REPO) for f in probe)
            )

    if failures:
        print("FAIL")
        for failure in failures:
            print(f"  - {failure}")
        return 1

    print(f"ok: {len(EXPECTED)} rules fire on BadAddon.lua, {len(EXPECTED_TOC)} on "
          f"BadAddon.toc, {len(HEURISTICS)} heuristic lines hold, the probes are clean")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
