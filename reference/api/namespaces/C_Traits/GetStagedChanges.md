<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Traits.GetStagedChanges

```lua
nodeIDsWithPurchases, nodeIDsWithRefunds, nodeIDsWithSelectionSwaps = C_Traits.GetStagedChanges(configID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `configID` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `nodeIDsWithPurchases` | `table&lt;number&gt;` | no |  |
| 2 | `nodeIDsWithRefunds` | `table&lt;number&gt;` | no |  |
| 3 | `nodeIDsWithSelectionSwaps` | `table&lt;number&gt;` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_Traits.GetStagedChanges(configID)`

System: `SharedTraits` · Namespace: `C_Traits`
