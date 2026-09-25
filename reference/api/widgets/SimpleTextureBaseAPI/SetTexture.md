<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# SimpleTextureBaseAPI:SetTexture

```lua
success = SimpleTextureBaseAPI:SetTexture(textureAsset, wrapModeHorizontal, wrapModeVertical, filterMode)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `textureAsset` | `cstring` | yes |  |
| 2 | `wrapModeHorizontal` | `cstring` | yes |  |
| 3 | `wrapModeVertical` | `cstring` | yes |  |
| 4 | `filterMode` | `cstring` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `success` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenTainted"` |

Blizzard's own rendering: `SetTexture(optional textureAsset, optional wrapModeHorizontal, optional wrapModeVertical, optional filterMode)`

System: `SimpleTextureBaseAPI` · Widget methods
