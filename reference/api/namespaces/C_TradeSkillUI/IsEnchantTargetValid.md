<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_TradeSkillUI.IsEnchantTargetValid

```lua
valid = C_TradeSkillUI.IsEnchantTargetValid(recipeID, itemGUID, craftingReagents)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `recipeID` | `number` | no |  |
| 2 | `itemGUID` | `WOWGUID` | no |  |
| 3 | `craftingReagents` | `table&lt;CraftingReagentInfo&gt;` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `valid` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_TradeSkillUI.IsEnchantTargetValid(recipeID, itemGUID, optional craftingReagents)`

System: `TradeSkillUI` · Namespace: `C_TradeSkillUI`
