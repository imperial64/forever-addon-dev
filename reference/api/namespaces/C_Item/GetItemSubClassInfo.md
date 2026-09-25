<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Item.GetItemSubClassInfo

```lua
subClassName, subClassUsesInvType = C_Item.GetItemSubClassInfo(itemClassID, itemSubClassID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `itemClassID` | `number` | no |  |
| 2 | `itemSubClassID` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `subClassName` | `cstring` | no |  |
| 2 | `subClassUsesInvType` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_Item.GetItemSubClassInfo(itemClassID, itemSubClassID)`

System: `Item` · Namespace: `C_Item`
