<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_TooltipInfo.GetItemByID

```lua
data = C_TooltipInfo.GetItemByID(itemID, quality, itemContext, treasureContextLevel)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `itemID` | `number` | no |  |
| 2 | `quality` | `number` | yes |  |
| 3 | `itemContext` | `number` | yes |  |
| 4 | `treasureContextLevel` | `number` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `data` | `TooltipData` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_TooltipInfo.GetItemByID(itemID, optional quality, optional itemContext, optional treasureContextLevel)`

System: `TooltipInfo` · Namespace: `C_TooltipInfo`
