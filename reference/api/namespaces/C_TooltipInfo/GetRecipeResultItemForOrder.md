<!-- GENERATED from Blizzard_APIDocumentation, client build unknown. Do not edit; edit the generator. -->

# C_TooltipInfo.GetRecipeResultItemForOrder

```lua
data = C_TooltipInfo.GetRecipeResultItemForOrder(recipeID, reagentInfos, orderID, recipeLevel, overrideQualityID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `recipeID` | `number` | no |  |
| 2 | `reagentInfos` | `table&lt;CraftingReagentInfo&gt;` | yes |  |
| 3 | `orderID` | `BigUInteger` | yes |  |
| 4 | `recipeLevel` | `luaIndex` | yes |  |
| 5 | `overrideQualityID` | `number` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `data` | `TooltipData` | no |  |

Blizzard's own rendering: `C_TooltipInfo.GetRecipeResultItemForOrder(recipeID, optional reagentInfos, optional orderID, optional recipeLevel, optional overrideQualityID)`

System: `TooltipInfo` · Namespace: `C_TooltipInfo`
