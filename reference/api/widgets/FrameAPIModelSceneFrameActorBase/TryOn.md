<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# FrameAPIModelSceneFrameActorBase:TryOn

```lua
reason = FrameAPIModelSceneFrameActorBase:TryOn(itemLinkOrItemModifiedAppearanceID, handSlotName, spellEnchantmentID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `itemLinkOrItemModifiedAppearanceID` | `cstring` | no |  |
| 2 | `handSlotName` | `cstring` | yes |  |
| 3 | `spellEnchantmentID` | `number` | no | `0` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `reason` | `ItemTryOnReason` | yes |  |

Blizzard's own rendering: `TryOn(itemLinkOrItemModifiedAppearanceID, optional handSlotName, optional spellEnchantmentID)`

System: `FrameAPIModelSceneFrameActorBase` · Widget methods
