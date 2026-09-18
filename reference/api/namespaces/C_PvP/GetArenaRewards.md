<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# C_PvP.GetArenaRewards

```lua
honor, experience, itemRewards, currencyRewards, roleShortageBonus = C_PvP.GetArenaRewards(teamSize)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `teamSize` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `honor` | `number` | no |  |
| 2 | `experience` | `number` | no |  |
| 3 | `itemRewards` | `table&lt;BattlefieldItemReward&gt;` | yes |  |
| 4 | `currencyRewards` | `table&lt;BattlefieldCurrencyReward&gt;` | yes |  |
| 5 | `roleShortageBonus` | `RoleShortageReward` | yes |  |

Blizzard's own rendering: `C_PvP.GetArenaRewards(teamSize)`

System: `PvpInfo` · Namespace: `C_PvP`
