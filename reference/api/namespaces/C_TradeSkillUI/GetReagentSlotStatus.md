<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_TradeSkillUI.GetReagentSlotStatus

```lua
locked, lockedReason = C_TradeSkillUI.GetReagentSlotStatus(mcrSlotID, recipeSpellID, skillLineAbilityID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `mcrSlotID` | `number` | no |  |
| 2 | `recipeSpellID` | `number` | no |  |
| 3 | `skillLineAbilityID` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `locked` | `bool` | no |  |
| 2 | `lockedReason` | `string` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_TradeSkillUI.GetReagentSlotStatus(mcrSlotID, recipeSpellID, skillLineAbilityID)`

System: `TradeSkillUI` · Namespace: `C_TradeSkillUI`
