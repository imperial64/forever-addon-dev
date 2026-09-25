<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_QuestLine.GetQuestLineInfo

```lua
questLineInfo = C_QuestLine.GetQuestLineInfo(questID, uiMapID, displayableOnly)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `questID` | `number` | no |  |
| 2 | `uiMapID` | `number` | yes |  |
| 3 | `displayableOnly` | `bool` | no | `False` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `questLineInfo` | `QuestLineInfo` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_QuestLine.GetQuestLineInfo(questID, optional uiMapID, optional displayableOnly)`

System: `QuestLineUI` · Namespace: `C_QuestLine`
