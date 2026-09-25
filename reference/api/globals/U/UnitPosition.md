<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# UnitPosition

> **COST — measured, not a restriction.** no measurable allocation. Present, returns plain numbers, and allocates nothing - the paired alternative to player-map-position on the axis that matters here.
> Measured 2026-09-20 on build 69913, n=1, on one machine, and NOT re-measured by `regenerate`. Evidence: §Q.8 in [findings](../../../../research/findings.md).
> 
> _Guidance:_ If you need world coordinates, this is the cheap read. If you need a position on a map, you still need player-map-position and its accumulator. Confirm the return ORDER against a known landmark on your own client before relying on it - the documented names and the retail folklore disagree, and neither was measured here.

```lua
positionX, positionY, positionZ, mapID = UnitPosition(unit)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unit` | `UnitToken` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `positionX` | `number` | no |  |
| 2 | `positionY` | `number` | no |  |
| 3 | `positionZ` | `number` | no |  |
| 4 | `mapID` | `number` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `UnitPosition(unit)`

System: `Unit`
