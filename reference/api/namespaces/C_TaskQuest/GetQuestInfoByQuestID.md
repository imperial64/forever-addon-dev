<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# C_TaskQuest.GetQuestInfoByQuestID

```lua
questTitle, factionID, capped, displayAsObjective = C_TaskQuest.GetQuestInfoByQuestID(questID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `questID` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `questTitle` | `cstring` | no |  |
| 2 | `factionID` | `number` | yes |  |
| 3 | `capped` | `bool` | yes |  |
| 4 | `displayAsObjective` | `bool` | yes |  |

Blizzard's own rendering: `C_TaskQuest.GetQuestInfoByQuestID(questID)`

System: `QuestTaskInfo` · Namespace: `C_TaskQuest`
