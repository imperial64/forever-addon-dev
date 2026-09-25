<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# FrameAPIModelSceneFrameActor:AttachToMount

```lua
success = FrameAPIModelSceneFrameActor:AttachToMount(rider, animation, spellKitVisualID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `rider` | `ModelSceneFrameActor` | no |  |
| 2 | `animation` | `AnimationDataEnum` | no |  |
| 3 | `spellKitVisualID` | `number` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `success` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `AttachToMount(rider, animation, optional spellKitVisualID)`

System: `FrameAPIModelSceneFrameActor` · Widget methods
