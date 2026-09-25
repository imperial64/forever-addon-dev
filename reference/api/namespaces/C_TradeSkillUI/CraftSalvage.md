<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_TradeSkillUI.CraftSalvage

```lua
C_TradeSkillUI.CraftSalvage(recipeSpellID, numCasts, itemTarget, craftingReagents, applyConcentration)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `recipeSpellID` | `number` | no |  |
| 2 | `numCasts` | `number` | no | `1` |
| 3 | `itemTarget` | `ItemLocation (ItemLocationMixin)` | no |  |
| 4 | `craftingReagents` | `table&lt;CraftingReagentInfo&gt;` | yes |  |
| 5 | `applyConcentration` | `bool` | yes |  |

**Returns**

_None._

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_TradeSkillUI.CraftSalvage(recipeSpellID, optional numCasts, itemTarget, optional craftingReagents, optional applyConcentration)`

System: `TradeSkillUI` · Namespace: `C_TradeSkillUI`
