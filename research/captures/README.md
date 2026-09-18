Probe output lands here via scripts/collect-savedvars.ps1. Timestamped so runs can be diffed.

## Captures

- `ForeverProbe_2026-09-18_144034_first-live-run.lua` - the first real capture, beta build
  1.60.1.69913. 303 KB. Contains the full global dump (5,958 functions, 269 C_ namespaces),
  the auction surface, the secrecy gates and the external data channel state. Note it holds
  the CRASHED run of 14:23 rather than the clean one that followed: the client flushes on
  logout, and the fix landed between the two. Its gate values read ERR for anything taking
  arguments; the corrected table is in research/findings.md section P.10.

That any capture exists at all is itself a finding: the client writes SavedVariables even
though it never reads them back, so the outbound direction works while the round trip inside
the client does not. See findings section P.9.
