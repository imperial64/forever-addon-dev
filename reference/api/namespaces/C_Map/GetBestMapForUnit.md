<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Map.GetBestMapForUnit

> **COST — measured, not a restriction.** 0.610 - 0.636 µs, no measurable allocation. Cheap - seven to nine times cheaper than the position read.
> Measured 2026-09-20 on build 69913, n=5, on one machine, and NOT re-measured by `regenerate`. Evidence: §Q.3 in [findings](../../../../research/findings.md).
> 
> _Guidance:_ Resolve it on a zone-change event and hold the id, rather than re-asking inside the poll.

```lua
uiMapID = C_Map.GetBestMapForUnit(unitToken)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unitToken` | `UnitToken` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `uiMapID` | `number` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_Map.GetBestMapForUnit(unitToken)`

System: `MapUI` · Namespace: `C_Map`
