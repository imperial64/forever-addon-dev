<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_TooltipInfo.GetQuestItem

```lua
data = C_TooltipInfo.GetQuestItem(type, itemIndex, allowCollectionText)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `type` | `cstring` | no |  |
| 2 | `itemIndex` | `luaIndex` | no |  |
| 3 | `allowCollectionText` | `bool` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `data` | `TooltipData` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_TooltipInfo.GetQuestItem(type, itemIndex, optional allowCollectionText)`

System: `TooltipInfo` · Namespace: `C_TooltipInfo`
