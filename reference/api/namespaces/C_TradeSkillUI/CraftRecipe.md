<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_TradeSkillUI.CraftRecipe

```lua
C_TradeSkillUI.CraftRecipe(recipeSpellID, numCasts, craftingReagents, recipeLevel, orderID, applyConcentration)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `recipeSpellID` | `number` | no |  |
| 2 | `numCasts` | `number` | no | `1` |
| 3 | `craftingReagents` | `table&lt;CraftingReagentInfo&gt;` | yes |  |
| 4 | `recipeLevel` | `luaIndex` | yes |  |
| 5 | `orderID` | `BigUInteger` | yes |  |
| 6 | `applyConcentration` | `bool` | yes |  |

**Returns**

_None._

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_TradeSkillUI.CraftRecipe(recipeSpellID, optional numCasts, optional craftingReagents, optional recipeLevel, optional orderID, optional applyConcentration)`

System: `TradeSkillUI` · Namespace: `C_TradeSkillUI`
