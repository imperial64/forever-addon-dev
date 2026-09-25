<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_QuestLog.GetQuestRewardCurrencyInfo

```lua
questRewardCurrencyInfo = C_QuestLog.GetQuestRewardCurrencyInfo(questID, currencyIndex, isChoice)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `questID` | `number` | no |  |
| 2 | `currencyIndex` | `luaIndex` | no |  |
| 3 | `isChoice` | `bool` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `questRewardCurrencyInfo` | `QuestRewardCurrencyInfo` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_QuestLog.GetQuestRewardCurrencyInfo(questID, currencyIndex, isChoice)`

System: `QuestLog` · Namespace: `C_QuestLog`
