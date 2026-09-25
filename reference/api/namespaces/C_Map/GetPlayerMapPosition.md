<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Map.GetPlayerMapPosition

> **COST — measured, not a restriction.** bare call: 4.38 - 5.71 µs, 1864 bytes; plus GetXY() to get two numbers: 4.91 - 7.91 µs. Allocates 1864 bytes on EVERY call. The allocation is the constraint here, not the time.
> Measured 2026-09-20 on build 69913, n=5, on one machine, and NOT re-measured by `regenerate`. Evidence: §Q.2 in [findings](../../../../research/findings.md).
> 
> _Guidance:_ Poll position on an accumulator rather than per frame, and guard for a nil return.

```lua
position = C_Map.GetPlayerMapPosition(uiMapID, unitToken)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `uiMapID` | `number` | no |  |
| 2 | `unitToken` | `UnitToken` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `position` | `vector2 (Vector2DMixin)` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_Map.GetPlayerMapPosition(uiMapID, unitToken)`

System: `MapUI` · Namespace: `C_Map`
