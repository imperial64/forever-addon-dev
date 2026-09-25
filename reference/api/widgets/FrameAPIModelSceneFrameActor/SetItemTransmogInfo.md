<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# FrameAPIModelSceneFrameActor:SetItemTransmogInfo

```lua
result = FrameAPIModelSceneFrameActor:SetItemTransmogInfo(transmogInfo, inventorySlots, ignoreChildItems)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `transmogInfo` | `ItemTransmogInfo (ItemTransmogInfoMixin)` | no |  |
| 2 | `inventorySlots` | `number` | yes |  |
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

Blizzard's own rendering: `SetItemTransmogInfo(transmogInfo, optional inventorySlots, optional ignoreChildItems)`

System: `FrameAPIModelSceneFrameActor` · Widget methods
