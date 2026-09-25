<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_TooltipInfo.GetItemKey

```lua
data = C_TooltipInfo.GetItemKey(itemID, itemLevel, itemSuffix, requiredLevel)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `itemID` | `number` | no |  |
| 2 | `itemLevel` | `number` | no |  |
| 3 | `itemSuffix` | `number` | no |  |
| 4 | `requiredLevel` | `number` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `data` | `TooltipData` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_TooltipInfo.GetItemKey(itemID, itemLevel, itemSuffix, optional requiredLevel)`

System: `TooltipInfo` · Namespace: `C_TooltipInfo`
