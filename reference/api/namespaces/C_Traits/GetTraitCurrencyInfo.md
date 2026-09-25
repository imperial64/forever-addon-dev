<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Traits.GetTraitCurrencyInfo

```lua
flags, type, currencyTypesID, icon = C_Traits.GetTraitCurrencyInfo(traitCurrencyID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `traitCurrencyID` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `flags` | `number` | no |  |
| 2 | `type` | `number` | no |  |
| 3 | `currencyTypesID` | `number` | yes |  |
| 4 | `icon` | `number` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_Traits.GetTraitCurrencyInfo(traitCurrencyID)`

System: `SharedTraits` · Namespace: `C_Traits`
