<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_QuestOffer.GetQuestRewardCurrencyInfo

```lua
questRewardCurrencyInfo = C_QuestOffer.GetQuestRewardCurrencyInfo(questInfoType, questRewardIndex)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `questInfoType` | `cstring` | no |  |
| 2 | `questRewardIndex` | `luaIndex` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `questRewardCurrencyInfo` | `QuestRewardCurrencyInfo` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_QuestOffer.GetQuestRewardCurrencyInfo(questInfoType, questRewardIndex)`

System: `QuestOffer` · Namespace: `C_QuestOffer`
