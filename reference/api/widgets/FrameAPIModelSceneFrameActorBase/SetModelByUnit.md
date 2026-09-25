<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# FrameAPIModelSceneFrameActorBase:SetModelByUnit

```lua
success = FrameAPIModelSceneFrameActorBase:SetModelByUnit(unit, sheatheWeapons, autoDress, hideWeapons, usePlayerNativeForm, holdBowString, customRaceID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unit` | `UnitToken` | no |  |
| 2 | `sheatheWeapons` | `bool` | no | `False` |
| 3 | `autoDress` | `bool` | no | `True` |
| 4 | `hideWeapons` | `bool` | no | `False` |
| 5 | `usePlayerNativeForm` | `bool` | no | `True` |
| 6 | `holdBowString` | `bool` | no | `False` |
| 7 | `customRaceID` | `number` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `success` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `RequiresDeclassifiedUnitIdentity` | `true` |
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `SetModelByUnit(unit, optional sheatheWeapons, optional autoDress, optional hideWeapons, optional usePlayerNativeForm, optional holdBowString, optional customRaceID)`

System: `FrameAPIModelSceneFrameActorBase` · Widget methods
