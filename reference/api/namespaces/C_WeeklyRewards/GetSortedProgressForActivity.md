<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_WeeklyRewards.GetSortedProgressForActivity

```lua
progress = C_WeeklyRewards.GetSortedProgressForActivity(type, combineSharedDifficulty)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `type` | `WeeklyRewardChestThresholdType` | no |  |
| 2 | `combineSharedDifficulty` | `bool` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `progress` | `table&lt;WeeklyRewardActivityTierProgress&gt;` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_WeeklyRewards.GetSortedProgressForActivity(type, combineSharedDifficulty)`

System: `WeeklyRewards` · Namespace: `C_WeeklyRewards`
