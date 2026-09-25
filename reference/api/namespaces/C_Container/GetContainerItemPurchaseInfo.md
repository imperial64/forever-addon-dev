<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Container.GetContainerItemPurchaseInfo

```lua
info = C_Container.GetContainerItemPurchaseInfo(containerIndex, slotIndex, isEquipped)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `containerIndex` | `BagIndex` | no |  |
| 2 | `slotIndex` | `luaIndex` | no |  |
| 3 | `isEquipped` | `bool` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `info` | `ItemPurchaseInfo` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_Container.GetContainerItemPurchaseInfo(containerIndex, slotIndex, isEquipped)`

System: `Container` · Namespace: `C_Container`
