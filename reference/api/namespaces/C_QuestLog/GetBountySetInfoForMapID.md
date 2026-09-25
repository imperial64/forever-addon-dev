<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_QuestLog.GetBountySetInfoForMapID

```lua
displayLocation, lockQuestID, bountySetID, isActivitySet = C_QuestLog.GetBountySetInfoForMapID(uiMapID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `uiMapID` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `displayLocation` | `MapOverlayDisplayLocation` | no |  |
| 2 | `lockQuestID` | `number` | no |  |
| 3 | `bountySetID` | `number` | no |  |
| 4 | `isActivitySet` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_QuestLog.GetBountySetInfoForMapID(uiMapID)`

System: `QuestLog` · Namespace: `C_QuestLog`
