<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_TradeSkillUI.GetCraftingOperationInfoForOrder

```lua
info = C_TradeSkillUI.GetCraftingOperationInfoForOrder(recipeID, craftingReagents, orderID, applyConcentration)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `recipeID` | `number` | no |  |
| 2 | `craftingReagents` | `table&lt;CraftingReagentInfo&gt;` | no |  |
| 3 | `orderID` | `BigUInteger` | no |  |
| 4 | `applyConcentration` | `bool` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `info` | `CraftingOperationInfo` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_TradeSkillUI.GetCraftingOperationInfoForOrder(recipeID, craftingReagents, orderID, applyConcentration)`

System: `TradeSkillUI` · Namespace: `C_TradeSkillUI`
