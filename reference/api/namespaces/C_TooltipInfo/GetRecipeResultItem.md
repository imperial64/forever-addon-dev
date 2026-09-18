<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# C_TooltipInfo.GetRecipeResultItem

```lua
data = C_TooltipInfo.GetRecipeResultItem(recipeID, reagentInfos, recraftItemGUID, recipeLevel, overrideQualityID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `recipeID` | `number` | no |  |
| 2 | `reagentInfos` | `table&lt;CraftingReagentInfo&gt;` | yes |  |
| 3 | `recraftItemGUID` | `WOWGUID` | yes |  |
| 4 | `recipeLevel` | `luaIndex` | yes |  |
| 5 | `overrideQualityID` | `number` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `data` | `TooltipData` | no |  |

Blizzard's own rendering: `C_TooltipInfo.GetRecipeResultItem(recipeID, optional reagentInfos, optional recraftItemGUID, optional recipeLevel, optional overrideQualityID)`

System: `TooltipInfo` · Namespace: `C_TooltipInfo`
