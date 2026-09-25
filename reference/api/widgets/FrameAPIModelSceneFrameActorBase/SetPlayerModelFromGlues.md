<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# FrameAPIModelSceneFrameActorBase:SetPlayerModelFromGlues

```lua
success = FrameAPIModelSceneFrameActorBase:SetPlayerModelFromGlues(characterIndex, sheatheWeapons, autoDress, hideWeapons, usePlayerNativeForm, customRaceID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `characterIndex` | `number` | yes |  |
| 2 | `sheatheWeapons` | `bool` | no | `False` |
| 3 | `autoDress` | `bool` | no | `True` |
| 4 | `hideWeapons` | `bool` | no | `False` |
| 5 | `usePlayerNativeForm` | `bool` | no | `True` |
| 6 | `customRaceID` | `number` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `success` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `SetPlayerModelFromGlues(optional characterIndex, optional sheatheWeapons, optional autoDress, optional hideWeapons, optional usePlayerNativeForm, optional customRaceID)`

System: `FrameAPIModelSceneFrameActorBase` · Widget methods
