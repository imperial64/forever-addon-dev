<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

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

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `TryOn(itemLinkOrItemModifiedAppearanceID, optional handSlotName, optional spellEnchantmentID)`

System: `FrameAPIModelSceneFrameActorBase` · Widget methods
