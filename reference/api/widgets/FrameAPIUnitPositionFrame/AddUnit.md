<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# FrameAPIUnitPositionFrame:AddUnit

```lua
FrameAPIUnitPositionFrame:AddUnit(unitTokenString, asset, width, height, r, g, b, a, sublayer, showFacing)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unitTokenString` | `cstring` | no |  |
| 2 | `asset` | `TextureAssetDisk` | no |  |
| 3 | `width` | `uiUnit` | yes |  |
| 4 | `height` | `uiUnit` | yes |  |
| 5 | `r` | `number` | yes |  |
| 6 | `g` | `number` | yes |  |
| 7 | `b` | `number` | yes |  |
| 8 | `a` | `number` | yes |  |
| 9 | `sublayer` | `number` | yes |  |
| 10 | `showFacing` | `bool` | yes |  |

**Returns**

_None._

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `AddUnit(unitTokenString, asset, optional width, optional height, optional r, optional g, optional b, optional a, optional sublayer, optional showFacing)`

System: `FrameAPIUnitPositionFrame` · Widget methods
