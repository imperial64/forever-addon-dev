<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_TooltipInfo.GetAzeritePower

```lua
data = C_TooltipInfo.GetAzeritePower(itemID, itemLevel, powerID, owningItemLink)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `itemID` | `number` | no |  |
| 2 | `itemLevel` | `number` | no |  |
| 3 | `powerID` | `number` | no |  |
| 4 | `owningItemLink` | `cstring` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `data` | `TooltipData` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_TooltipInfo.GetAzeritePower(itemID, itemLevel, powerID, optional owningItemLink)`

System: `TooltipInfo` · Namespace: `C_TooltipInfo`
