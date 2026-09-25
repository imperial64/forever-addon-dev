<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

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

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_TaskQuest.GetQuestInfoByQuestID(questID)`

System: `QuestTaskInfo` · Namespace: `C_TaskQuest`
