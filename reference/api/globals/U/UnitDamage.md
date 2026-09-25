<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# UnitDamage

```lua
minDamage, maxDamage, offhandMinDamage, offhandMaxDamage, posBuff, negBuff, percent = UnitDamage(unit)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unit` | `UnitToken` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `minDamage` | `number` | no |  |
| 2 | `maxDamage` | `number` | no |  |
| 3 | `offhandMinDamage` | `number` | no |  |
| 4 | `offhandMaxDamage` | `number` | no |  |
| 5 | `posBuff` | `number` | no |  |
| 6 | `negBuff` | `number` | no |  |
| 7 | `percent` | `number` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretWhenUnitStatsRestricted` | `true` |

Blizzard's own rendering: `UnitDamage(unit)`

System: `Unit`
