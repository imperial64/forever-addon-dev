<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_TooltipComparison.GetItemComparisonDelta

```lua
lines = C_TooltipComparison.GetItemComparisonDelta(comparisonItem, equippedItem, pairedItem, addPairedStats)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `comparisonItem` | `TooltipComparisonItem` | no |  |
| 2 | `equippedItem` | `TooltipComparisonItem` | no |  |
| 3 | `pairedItem` | `TooltipComparisonItem` | yes |  |
| 4 | `addPairedStats` | `bool` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `lines` | `table&lt;string&gt;` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_TooltipComparison.GetItemComparisonDelta(comparisonItem, equippedItem, optional pairedItem, optional addPairedStats)`

System: `TooltipComparison` · Namespace: `C_TooltipComparison`
