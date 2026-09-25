<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_ModelInfo.GetModelSceneInfoByID

```lua
modelSceneType, modelCameraIDs, modelActorsIDs, flags = C_ModelInfo.GetModelSceneInfoByID(modelSceneID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `modelSceneID` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `modelSceneType` | `ModelSceneType` | no |  |
| 2 | `modelCameraIDs` | `table&lt;number&gt;` | no |  |
| 3 | `modelActorsIDs` | `table&lt;number&gt;` | no |  |
| 4 | `flags` | `number` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_ModelInfo.GetModelSceneInfoByID(modelSceneID)`

System: `ModelInfo` · Namespace: `C_ModelInfo`
