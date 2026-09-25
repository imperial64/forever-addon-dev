<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_TradeSkillUI.GetEnchantItems

```lua
items = C_TradeSkillUI.GetEnchantItems(recipeID, craftingReagents)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `recipeID` | `number` | no |  |
| 2 | `craftingReagents` | `table&lt;CraftingReagentInfo&gt;` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `items` | `table&lt;WOWGUID&gt;` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_TradeSkillUI.GetEnchantItems(recipeID, optional craftingReagents)`

System: `TradeSkillUI` · Namespace: `C_TradeSkillUI`
