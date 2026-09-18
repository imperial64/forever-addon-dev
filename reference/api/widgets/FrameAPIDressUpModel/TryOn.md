<!-- GENERATED from Blizzard_APIDocumentation, client build unknown. Do not edit; edit the generator. -->

# FrameAPIDressUpModel:TryOn

```lua
result = FrameAPIDressUpModel:TryOn(linkOrItemModifiedAppearanceID, handSlotName, spellEnchantID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `linkOrItemModifiedAppearanceID` | `IDOrLink` | no |  |
| 2 | `handSlotName` | `cstring` | yes |  |
| 3 | `spellEnchantID` | `number` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `result` | `ItemTryOnReason` | yes |  |

Blizzard's own rendering: `TryOn(linkOrItemModifiedAppearanceID, optional handSlotName, optional spellEnchantID)`

System: `FrameAPIDressUpModel` · Widget methods
