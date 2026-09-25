<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_CurrencyInfo.GetPlayerCurrencyCategoryInfo

```lua
info = C_CurrencyInfo.GetPlayerCurrencyCategoryInfo(categoryID, includeAccountWide)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `categoryID` | `number` | no |  |
| 2 | `includeAccountWide` | `bool` | no | `True` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `info` | `PlayerCurrencyCategoryInfo` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_CurrencyInfo.GetPlayerCurrencyCategoryInfo(categoryID, optional includeAccountWide)`

System: `CurrencySystem` · Namespace: `C_CurrencyInfo`
