<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_CraftingOrders.CalculateCraftingOrderPostingFee

```lua
deposit = C_CraftingOrders.CalculateCraftingOrderPostingFee(skillLineAbilityID, orderType, orderDuration)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `skillLineAbilityID` | `number` | no |  |
| 2 | `orderType` | `CraftingOrderType` | no |  |
| 3 | `orderDuration` | `CraftingOrderDuration` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `deposit` | `WOWMONEY` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_CraftingOrders.CalculateCraftingOrderPostingFee(skillLineAbilityID, orderType, orderDuration)`

System: `CraftingOrderUI` · Namespace: `C_CraftingOrders`
