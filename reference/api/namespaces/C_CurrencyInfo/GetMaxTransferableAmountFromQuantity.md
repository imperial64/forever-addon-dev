<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_CurrencyInfo.GetMaxTransferableAmountFromQuantity

```lua
maxTransferableAmount = C_CurrencyInfo.GetMaxTransferableAmountFromQuantity(currencyID, requestedQuantity)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `currencyID` | `number` | no |  |
| 2 | `requestedQuantity` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `maxTransferableAmount` | `number` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_CurrencyInfo.GetMaxTransferableAmountFromQuantity(currencyID, requestedQuantity)`

System: `CurrencySystem` · Namespace: `C_CurrencyInfo`
