<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Sound.PlaySound

```lua
success, soundHandle = C_Sound.PlaySound(soundKitID, uiSoundSubType, forceNoDuplicates, runFinishCallback, overridePriority, volumeOverride)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `soundKitID` | `number` | no |  |
| 2 | `uiSoundSubType` | `UISoundSubType` | no | `g_defaultSI3UISoundSubTypeForLua` |
| 3 | `forceNoDuplicates` | `bool` | no | `False` |
| 4 | `runFinishCallback` | `bool` | no | `False` |
| 5 | `overridePriority` | `number` | yes |  |
| 6 | `volumeOverride` | `number` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `success` | `bool` | no |  |
| 2 | `soundHandle` | `SoundHandle` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_Sound.PlaySound(soundKitID, optional uiSoundSubType, optional forceNoDuplicates, optional runFinishCallback, optional overridePriority, optional volumeOverride)`

System: `Sound` · Namespace: `C_Sound`
