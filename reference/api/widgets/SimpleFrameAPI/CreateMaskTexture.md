<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# SimpleFrameAPI:CreateMaskTexture

```lua
maskTexture = SimpleFrameAPI:CreateMaskTexture(name, drawLayer, templateName, subLevel)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `name` | `cstring` | yes |  |
| 2 | `drawLayer` | `DrawLayer` | yes |  |
| 3 | `templateName` | `cstring` | yes |  |
| 4 | `subLevel` | `number` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `maskTexture` | `SimpleMaskTexture` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"NotAllowed"` |

Blizzard's own rendering: `CreateMaskTexture(optional name, optional drawLayer, optional templateName, optional subLevel)`

System: `SimpleFrameAPI` · Widget methods
