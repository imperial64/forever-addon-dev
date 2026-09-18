<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# C_TradeSkillUI.RecraftRecipeForOrder

```lua
result = C_TradeSkillUI.RecraftRecipeForOrder(orderID, itemGUID, craftingReagents, removedModifications, applyConcentration)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `orderID` | `BigUInteger` | no |  |
| 2 | `itemGUID` | `WOWGUID` | no |  |
| 3 | `craftingReagents` | `table&lt;CraftingReagentInfo&gt;` | yes |  |
| 4 | `removedModifications` | `table&lt;CraftingItemSlotModification&gt;` | yes |  |
| 5 | `applyConcentration` | `bool` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `result` | `bool` | no |  |

Blizzard's own rendering: `C_TradeSkillUI.RecraftRecipeForOrder(orderID, itemGUID, optional craftingReagents, optional removedModifications, optional applyConcentration)`

System: `TradeSkillUI` · Namespace: `C_TradeSkillUI`
