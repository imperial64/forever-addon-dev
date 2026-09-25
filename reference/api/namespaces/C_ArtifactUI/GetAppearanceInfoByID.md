<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_ArtifactUI.GetAppearanceInfoByID

```lua
artifactAppearanceSetID, artifactAppearanceID, appearanceName, displayIndex, unlocked, failureDescription, uiCameraID, altHandCameraID, swatchColorR, swatchColorG, swatchColorB, modelOpacity, modelSaturation, obtainable = C_ArtifactUI.GetAppearanceInfoByID(artifactAppearanceID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `artifactAppearanceID` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `artifactAppearanceSetID` | `number` | no |  |
| 2 | `artifactAppearanceID` | `number` | no |  |
| 3 | `appearanceName` | `string` | no |  |
| 4 | `displayIndex` | `number` | no |  |
| 5 | `unlocked` | `bool` | no |  |
| 6 | `failureDescription` | `string` | yes |  |
| 7 | `uiCameraID` | `number` | no |  |
| 8 | `altHandCameraID` | `number` | yes |  |
| 9 | `swatchColorR` | `number` | no |  |
| 10 | `swatchColorG` | `number` | no |  |
| 11 | `swatchColorB` | `number` | no |  |
| 12 | `modelOpacity` | `number` | no |  |
| 13 | `modelSaturation` | `number` | no |  |
| 14 | `obtainable` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_ArtifactUI.GetAppearanceInfoByID(artifactAppearanceID)`

System: `ArtifactUI` · Namespace: `C_ArtifactUI`
