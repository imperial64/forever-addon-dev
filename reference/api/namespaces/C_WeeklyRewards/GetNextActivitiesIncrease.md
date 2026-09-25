<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_WeeklyRewards.GetNextActivitiesIncrease

```lua
hasSeasonData, nextActivityTierID, nextLevel, itemLevel = C_WeeklyRewards.GetNextActivitiesIncrease(activityTierID, level)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `activityTierID` | `number` | no |  |
| 2 | `level` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `hasSeasonData` | `bool` | no |  |
| 2 | `nextActivityTierID` | `number` | yes |  |
| 3 | `nextLevel` | `number` | yes |  |
| 4 | `itemLevel` | `number` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_WeeklyRewards.GetNextActivitiesIncrease(activityTierID, level)`

System: `WeeklyRewards` · Namespace: `C_WeeklyRewards`
