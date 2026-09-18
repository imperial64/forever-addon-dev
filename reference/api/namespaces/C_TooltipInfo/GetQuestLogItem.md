<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# C_TooltipInfo.GetQuestLogItem

```lua
data = C_TooltipInfo.GetQuestLogItem(type, itemIndex, questID, allowCollectionText)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `type` | `cstring` | no |  |
| 2 | `itemIndex` | `luaIndex` | no |  |
| 3 | `questID` | `number` | yes |  |
| 4 | `allowCollectionText` | `bool` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `data` | `TooltipData` | no |  |

Blizzard's own rendering: `C_TooltipInfo.GetQuestLogItem(type, itemIndex, optional questID, optional allowCollectionText)`

System: `TooltipInfo` · Namespace: `C_TooltipInfo`
