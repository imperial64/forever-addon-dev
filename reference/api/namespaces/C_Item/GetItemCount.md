<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Item.GetItemCount

```lua
count = C_Item.GetItemCount(itemInfo, includeBank, includeUses, includeReagentBank, includeAccountBank)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `itemInfo` | `ItemInfo` | no |  |
| 2 | `includeBank` | `bool` | no | `False` |
| 3 | `includeUses` | `bool` | no | `False` |
| 4 | `includeReagentBank` | `bool` | no | `False` |
| 5 | `includeAccountBank` | `bool` | no | `False` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `count` | `number` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_Item.GetItemCount(itemInfo, optional includeBank, optional includeUses, optional includeReagentBank, optional includeAccountBank)`

System: `Item` · Namespace: `C_Item`
