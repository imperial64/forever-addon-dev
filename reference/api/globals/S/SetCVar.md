<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# SetCVar

> **PERMITTED — measured, at all times.** Display brightness and contrast ARE addon-writable, live, at frame rate.
> Measured 2026-09-18 on build 69913. Evidence: §P.22 in [findings](../../../../research/findings.md).
> 
> _Workaround:_ Until /fprobe video has been run mid-fight, freeze on PLAYER_REGEN_DISABLED and resume on PLAYER_REGEN_ENABLED rather than assuming the write lands in combat.

> **COST — measured, not a restriction.** value changed: 0.786 - 0.823 µs; value unchanged: 0.304 - 0.316 µs. Sub-microsecond, so a CVar write is affordable at frame rate. A changed value costs about 2.6x a no-op write.
> Measured 2026-09-18 on build 69913, n=5, on one machine, and NOT re-measured by `regenerate`. Evidence: §Q.4 in [findings](../../../../research/findings.md).
> 
> _Guidance:_ Do not cache a CVar value to avoid the write; a redundant write is cheaper than most of the work you would do to avoid it.

> **Present on this client, but not documented by Blizzard.** It exists in the client's global table and can be called; Blizzard's own API documentation carries no signature for it, so none is shown here rather than one being invented.

Source: ForeverProbe global surface dump.
