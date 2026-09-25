<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_TradeSkillUI.GetRecipeInfoForSkillLineAbility

```lua
recipeInfo = C_TradeSkillUI.GetRecipeInfoForSkillLineAbility(skillLineAbilityID, recipeLevel)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `skillLineAbilityID` | `number` | no |  |
| 2 | `recipeLevel` | `luaIndex` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `recipeInfo` | `TradeSkillRecipeInfo` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_TradeSkillUI.GetRecipeInfoForSkillLineAbility(skillLineAbilityID, optional recipeLevel)`

System: `TradeSkillUI` · Namespace: `C_TradeSkillUI`
