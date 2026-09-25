<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_TradeSkillUI.GetRecipeSchematic

```lua
schematic = C_TradeSkillUI.GetRecipeSchematic(recipeSpellID, isRecraft, recipeLevel)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `recipeSpellID` | `number` | no |  |
| 2 | `isRecraft` | `bool` | no |  |
| 3 | `recipeLevel` | `luaIndex` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `schematic` | `CraftingRecipeSchematic` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_TradeSkillUI.GetRecipeSchematic(recipeSpellID, isRecraft, optional recipeLevel)`

System: `TradeSkillUI` · Namespace: `C_TradeSkillUI`
