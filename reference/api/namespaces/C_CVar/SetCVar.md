<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_CVar.SetCVar

> **PERMITTED — measured, at all times.** Display brightness and contrast ARE addon-writable, live, at frame rate.
> Measured 2026-09-20 on build 69913. Evidence: §P.22, §P.29 in [findings](../../../../research/findings.md).
> 
> _Workaround:_ None needed for combat. If you drive one of these from OnUpdate, the cost to watch is allocation rather than frame time - see cvar-write in research/costs.yaml.

> **COST — measured, not a restriction.** value changed: 0.786 - 0.823 µs, 822 bytes; value unchanged: 0.304 - 0.316 µs; numeric argument rather than a preformatted string: 827 bytes; the Lua-side ("%.2f"):format(v) alone, varying v: 38 bytes. Cheap in time and expensive in garbage, and the two point in opposite directions. Sub-microsecond per call, but ~822 bytes allocated on EVERY write.
> Measured 2026-09-20 on build 69913, n=5, on one machine, and NOT re-measured by `regenerate`. Evidence: §Q.4, §P.29 in [findings](../../../../research/findings.md).
> 
> _Guidance:_ Do not cache a CVar value to avoid the write on time grounds; a redundant write is cheaper in time than most of the work you would do to avoid it. Do think about the write RATE on allocation grounds - driving two CVars every frame is not free, and an epsilon skip or an accumulator is the lever.

```lua
success = C_CVar.SetCVar(name, value)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `name` | `cstring` | no |  |
| 2 | `value` | `cstring` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `success` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `RequiresNonReadOnlyCVar` | `true` |
| this function | `RequiresNonSecureCVar` | `true` |
| this function | `RequiresValidAndPublicCVar` | `true` |
| this function | `SecretArguments` | `"NotAllowed"` |

Blizzard's own rendering: `C_CVar.SetCVar(name, optional value)`

System: `CVarScripts` · Namespace: `C_CVar`
