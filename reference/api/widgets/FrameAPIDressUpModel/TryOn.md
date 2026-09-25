<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

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

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `TryOn(linkOrItemModifiedAppearanceID, optional handSlotName, optional spellEnchantID)`

System: `FrameAPIDressUpModel` · Widget methods
