<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# FrameAPIDressUpModel:SetItemTransmogInfo

```lua
result = FrameAPIDressUpModel:SetItemTransmogInfo(itemTransmogInfo, inventorySlot, ignoreChildItems)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `itemTransmogInfo` | `ItemTransmogInfo (ItemTransmogInfoMixin)` | no |  |
| 2 | `inventorySlot` | `luaIndex` | yes |  |
| 3 | `ignoreChildItems` | `bool` | no | `False` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `result` | `ItemTryOnReason` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `SetItemTransmogInfo(itemTransmogInfo, optional inventorySlot, optional ignoreChildItems)`

System: `FrameAPIDressUpModel` · Widget methods
