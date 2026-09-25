<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_PvP.GetBrawlRewards

```lua
honor, experience, itemRewards, currencyRewards, roleShortageBonus, hasWon = C_PvP.GetBrawlRewards(brawlType)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `brawlType` | `BrawlType` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `honor` | `number` | no |  |
| 2 | `experience` | `number` | no |  |
| 3 | `itemRewards` | `table&lt;BattlefieldItemReward&gt;` | yes |  |
| 4 | `currencyRewards` | `table&lt;BattlefieldCurrencyReward&gt;` | yes |  |
| 5 | `roleShortageBonus` | `RoleShortageReward` | yes |  |
| 6 | `hasWon` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_PvP.GetBrawlRewards(brawlType)`

System: `PvpInfo` · Namespace: `C_PvP`
