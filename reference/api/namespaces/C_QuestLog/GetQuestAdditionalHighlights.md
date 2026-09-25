<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_QuestLog.GetQuestAdditionalHighlights

```lua
uiMapID, worldQuests, worldQuestsElite, dungeons, treasures = C_QuestLog.GetQuestAdditionalHighlights(questID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `questID` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `uiMapID` | `number` | no |  |
| 2 | `worldQuests` | `bool` | no |  |
| 3 | `worldQuestsElite` | `bool` | no |  |
| 4 | `dungeons` | `bool` | no |  |
| 5 | `treasures` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_QuestLog.GetQuestAdditionalHighlights(questID)`

System: `QuestLog` · Namespace: `C_QuestLog`
