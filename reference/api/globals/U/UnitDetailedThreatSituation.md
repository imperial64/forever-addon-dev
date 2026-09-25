<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# UnitDetailedThreatSituation

```lua
isTanking, status, scaledPercentage, rawPercentage, rawThreat = UnitDetailedThreatSituation(unit, mobGUID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unit` | `UnitToken` | no |  |
| 2 | `mobGUID` | `UnitToken` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `isTanking` | `bool` | no |  |
| 2 | `status` | `number` | no |  |
| 3 | `scaledPercentage` | `number` | no |  |
| 4 | `rawPercentage` | `number` | no |  |
| 5 | `rawThreat` | `number` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretWhenUnitThreatValuesRestricted` | `true` |

Blizzard's own rendering: `UnitDetailedThreatSituation(unit, mobGUID)`

System: `Unit`
