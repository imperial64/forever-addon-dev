<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# C_TradeSkillUI.GetCraftingReagentBonusText

```lua
bonusText = C_TradeSkillUI.GetCraftingReagentBonusText(recipeSpellID, craftingReagentIndex, craftingReagents, allocationItemGUID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `recipeSpellID` | `number` | no |  |
| 2 | `craftingReagentIndex` | `luaIndex` | no |  |
| 3 | `craftingReagents` | `table&lt;CraftingReagentInfo&gt;` | no |  |
| 4 | `allocationItemGUID` | `WOWGUID` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `bonusText` | `table&lt;string&gt;` | no |  |

Blizzard's own rendering: `C_TradeSkillUI.GetCraftingReagentBonusText(recipeSpellID, craftingReagentIndex, craftingReagents, optional allocationItemGUID)`

System: `TradeSkillUI` · Namespace: `C_TradeSkillUI`
