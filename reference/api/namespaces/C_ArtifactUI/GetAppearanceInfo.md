<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_ArtifactUI.GetAppearanceInfo

```lua
artifactAppearanceID, appearanceName, displayIndex, unlocked, failureDescription, uiCameraID, altHandCameraID, swatchColorR, swatchColorG, swatchColorB, modelOpacity, modelSaturation, obtainable = C_ArtifactUI.GetAppearanceInfo(appearanceSetIndex, appearanceIndex)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `appearanceSetIndex` | `number` | no |  |
| 2 | `appearanceIndex` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `artifactAppearanceID` | `number` | no |  |
| 2 | `appearanceName` | `string` | no |  |
| 3 | `displayIndex` | `number` | no |  |
| 4 | `unlocked` | `bool` | no |  |
| 5 | `failureDescription` | `string` | yes |  |
| 6 | `uiCameraID` | `number` | no |  |
| 7 | `altHandCameraID` | `number` | yes |  |
| 8 | `swatchColorR` | `number` | no |  |
| 9 | `swatchColorG` | `number` | no |  |
| 10 | `swatchColorB` | `number` | no |  |
| 11 | `modelOpacity` | `number` | no |  |
| 12 | `modelSaturation` | `number` | no |  |
| 13 | `obtainable` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_ArtifactUI.GetAppearanceInfo(appearanceSetIndex, appearanceIndex)`

System: `ArtifactUI` · Namespace: `C_ArtifactUI`
