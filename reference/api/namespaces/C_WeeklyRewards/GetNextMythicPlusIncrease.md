<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_WeeklyRewards.GetNextMythicPlusIncrease

```lua
hasSeasonData, nextMythicPlusLevel, itemLevel = C_WeeklyRewards.GetNextMythicPlusIncrease(mythicPlusLevel)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `mythicPlusLevel` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `hasSeasonData` | `bool` | no |  |
| 2 | `nextMythicPlusLevel` | `number` | yes |  |
| 3 | `itemLevel` | `number` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_WeeklyRewards.GetNextMythicPlusIncrease(mythicPlusLevel)`

System: `WeeklyRewards` · Namespace: `C_WeeklyRewards`
