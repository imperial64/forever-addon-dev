<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_TradeSkillUI.CraftEnchant

```lua
C_TradeSkillUI.CraftEnchant(recipeSpellID, numCasts, craftingReagents, itemTarget, applyConcentration)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `recipeSpellID` | `number` | no |  |
| 2 | `numCasts` | `number` | no | `1` |
| 3 | `craftingReagents` | `table&lt;CraftingReagentInfo&gt;` | yes |  |
| 4 | `itemTarget` | `ItemLocation (ItemLocationMixin)` | yes |  |
| 5 | `applyConcentration` | `bool` | yes |  |

**Returns**

_None._

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_TradeSkillUI.CraftEnchant(recipeSpellID, optional numCasts, optional craftingReagents, optional itemTarget, optional applyConcentration)`

System: `TradeSkillUI` · Namespace: `C_TradeSkillUI`
