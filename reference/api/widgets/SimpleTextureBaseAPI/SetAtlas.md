<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# SimpleTextureBaseAPI:SetAtlas

```lua
SimpleTextureBaseAPI:SetAtlas(atlas, useAtlasSize, filterMode, resetTexCoords, wrapModeHorizontal, wrapModeVertical)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `atlas` | `textureAtlas` | no |  |
| 2 | `useAtlasSize` | `bool` | no | `False` |
| 3 | `filterMode` | `FilterMode` | yes |  |
| 4 | `resetTexCoords` | `bool` | yes |  |
| 5 | `wrapModeHorizontal` | `cstring` | yes |  |
| 6 | `wrapModeVertical` | `cstring` | yes |  |

**Returns**

_None._

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenTainted"` |
| argument `useAtlasSize` | `NeverSecret` | `true` |
| argument `filterMode` | `NeverSecret` | `true` |
| argument `resetTexCoords` | `NeverSecret` | `true` |
| argument `wrapModeHorizontal` | `NeverSecret` | `true` |
| argument `wrapModeVertical` | `NeverSecret` | `true` |

Blizzard's own rendering: `SetAtlas(atlas, optional useAtlasSize, optional filterMode, optional resetTexCoords, optional wrapModeHorizontal, optional wrapModeVertical)`

System: `SimpleTextureBaseAPI` · Widget methods
