<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# UnitStat

```lua
currentStat, effectiveStat, statPositiveBuff, statNegativeBuff = UnitStat(unit, index)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unit` | `UnitToken` | no |  |
| 2 | `index` | `luaIndex` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `currentStat` | `number` | no |  |
| 2 | `effectiveStat` | `number` | no |  |
| 3 | `statPositiveBuff` | `number` | no |  |
| 4 | `statNegativeBuff` | `number` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretWhenUnitStatsRestricted` | `true` |

Blizzard's own rendering: `UnitStat(unit, index)`

System: `Unit`
