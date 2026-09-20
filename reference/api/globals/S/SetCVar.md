<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# SetCVar

> **PERMITTED — measured, at all times.** Display brightness and contrast ARE addon-writable, live, at frame rate.
> Measured 2026-09-20 on build 69913. Evidence: §P.22, §P.29 in [findings](../../../../research/findings.md).
> 
> _Workaround:_ None needed for combat. If you drive one of these from OnUpdate, the cost to watch is allocation rather than frame time - see cvar-write in research/costs.yaml.

> **COST — measured, not a restriction.** value changed: 0.786 - 0.823 µs, 822 bytes; value unchanged: 0.304 - 0.316 µs; numeric argument rather than a preformatted string: 827 bytes; the Lua-side ("%.2f"):format(v) alone, varying v: 38 bytes. Cheap in time and expensive in garbage, and the two point in opposite directions. Sub-microsecond per call, but ~822 bytes allocated on EVERY write.
> Measured 2026-09-20 on build 69913, n=5, on one machine, and NOT re-measured by `regenerate`. Evidence: §Q.4, §P.29 in [findings](../../../../research/findings.md).
> 
> _Guidance:_ Do not cache a CVar value to avoid the write on time grounds; a redundant write is cheaper in time than most of the work you would do to avoid it. Do think about the write RATE on allocation grounds - driving two CVars every frame is not free, and an epsilon skip or an accumulator is the lever.

> **Present on this client, but not documented by Blizzard.** It exists in the client's global table and can be called; Blizzard's own API documentation carries no signature for it, so none is shown here rather than one being invented.

Source: ForeverProbe global surface dump.
