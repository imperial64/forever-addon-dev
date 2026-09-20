Probe output lands here via scripts/collect-savedvars.ps1. Timestamped so runs can be diffed.

## Captures

- `ForeverProbe_2026-09-18_144034_first-live-run.lua` - the first real capture, beta build
  1.60.1.69913. 303 KB. Contains the full global dump (5,958 functions, 269 C_ namespaces),
  the auction surface, the secrecy gates and the external data channel state. Note it holds
  the CRASHED run of 14:23 rather than the clean one that followed: the client flushes on
  logout, and the fix landed between the two. Its gate values read ERR for anything taking
  arguments; the corrected table is in research/findings.md section P.10.

- `AmbianceCost_2026-09-18_215313_cost-bench.lua` - **not ForeverProbe output.** A
  microbenchmark capture from `AmbianceCost`, an addon in a separate repository, handed over
  on 2026-09-18 and checked in so that the numbers in research/findings.md section Q can be
  re-derived rather than taken on trust. Same client, build 1.60.1.69913, out of combat,
  five runs. Nothing in this repo produces or refreshes it, and `/fprobe` does not reproduce
  it. Note that the `phases` table inside it is **not evidence** and is not cited anywhere:
  the phases run once in a fixed order with no warm-up discard, so drift lands on the later
  ones. Section Q.7 records why.

- `DynamicAmbiance_2026-09-20_120259_selftest.lua` and
  `DynamicAmbiance_2026-09-20_120605_selftest-combat.lua` - **not ForeverProbe output.** A
  pair of self-test captures from `DynamicAmbiance`, a different addon in the same separate
  repository, handed over on 2026-09-20. Same client, build 1.60.1.69913. They are the
  evidence behind findings section P.29: the first was taken out of combat, the second
  mid-fight one pull apart, and the only material difference between them is
  `env.combat`. What makes them evidence rather than a report is the `blocked` table in
  each - the instrument registers `ADDON_ACTION_BLOCKED` and `ADDON_ACTION_FORBIDDEN` at
  load and clears the list per run, so an empty table is a captured absence of refusals
  rather than a `pcall` that returned true. `/fprobe video` in combat still has not been
  run and would be an independent check on the same question.

That any capture exists at all is itself a finding: the client writes SavedVariables even
though it never reads them back, so the outbound direction works while the round trip inside
the client does not. See findings section P.9.
