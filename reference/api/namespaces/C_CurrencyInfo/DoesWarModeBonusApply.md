<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_CurrencyInfo.DoesWarModeBonusApply

```lua
warModeApplies, limitOncePerTooltip = C_CurrencyInfo.DoesWarModeBonusApply(currencyID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `currencyID` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `warModeApplies` | `bool` | yes |  |
| 2 | `limitOncePerTooltip` | `bool` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_CurrencyInfo.DoesWarModeBonusApply(currencyID)`

System: `CurrencySystem` · Namespace: `C_CurrencyInfo`
