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
from lint_addon import Rules, lint_file, lint_toc  # noqa: E402

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
}

# The same contract for tools/tests/BadAddon.toc.
EXPECTED_TOC = {
    "toc-no-forever-interface": 5,
    "toc-header-break": 9,
}

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

    # 4. The probe must be clean, .toc included. It calls forbidden things
    #    deliberately and suppresses each with a stated reason, so a clean run
    #    here also proves the suppression mechanism works.
    for relative in ("addons/ForeverProbe/ForeverProbe.lua",
                     "addons/ForeverProbe/ForeverProbe.toc"):
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
          "BadAddon.toc, ForeverProbe is clean")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
