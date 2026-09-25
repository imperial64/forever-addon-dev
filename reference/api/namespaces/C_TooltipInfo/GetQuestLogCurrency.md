<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_TooltipInfo.GetQuestLogCurrency

```lua
data = C_TooltipInfo.GetQuestLogCurrency(type, currencyIndex, questID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `type` | `cstring` | no |  |
| 2 | `currencyIndex` | `luaIndex` | no |  |
| 3 | `questID` | `number` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `data` | `TooltipData` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_TooltipInfo.GetQuestLogCurrency(type, currencyIndex, optional questID)`

System: `TooltipInfo` · Namespace: `C_TooltipInfo`
