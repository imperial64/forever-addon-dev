<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_TradeSkillUI.GetRecipeOutputItemData

```lua
outputInfo = C_TradeSkillUI.GetRecipeOutputItemData(recipeSpellID, reagents, allocationItemGUID, overrideQualityID, recraftOrderID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `recipeSpellID` | `number` | no |  |
| 2 | `reagents` | `table&lt;CraftingReagentInfo&gt;` | yes |  |
| 3 | `allocationItemGUID` | `WOWGUID` | yes |  |
| 4 | `overrideQualityID` | `number` | yes |  |
| 5 | `recraftOrderID` | `BigUInteger` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `outputInfo` | `CraftingRecipeOutputInfo` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_TradeSkillUI.GetRecipeOutputItemData(recipeSpellID, optional reagents, optional allocationItemGUID, optional overrideQualityID, optional recraftOrderID)`

System: `TradeSkillUI` · Namespace: `C_TradeSkillUI`
