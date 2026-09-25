<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Garrison.GetTalentTreeResetInfo

```lua
goldCost, currencyCosts = C_Garrison.GetTalentTreeResetInfo(garrTalentTreeID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `garrTalentTreeID` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `goldCost` | `number` | no |  |
| 2 | `currencyCosts` | `table&lt;GarrisonTalentCurrencyCostInfo&gt;` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_Garrison.GetTalentTreeResetInfo(garrTalentTreeID)`

System: `GarrisonInfo` · Namespace: `C_Garrison`
