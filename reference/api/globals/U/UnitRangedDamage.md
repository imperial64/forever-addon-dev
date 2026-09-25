<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# UnitRangedDamage

```lua
speed, minDamage, maxDamage, posBuff, negBuff, percent = UnitRangedDamage(unit)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unit` | `UnitToken` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `speed` | `number` | no |  |
| 2 | `minDamage` | `number` | no |  |
| 3 | `maxDamage` | `number` | no |  |
| 4 | `posBuff` | `number` | no |  |
| 5 | `negBuff` | `number` | no |  |
| 6 | `percent` | `number` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretWhenUnitStatsRestricted` | `true` |

Blizzard's own rendering: `UnitRangedDamage(unit)`

System: `Unit`
