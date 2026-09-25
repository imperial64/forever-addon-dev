<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# SimpleTextureBaseAPI:SetSpriteSheetCell

```lua
SimpleTextureBaseAPI:SetSpriteSheetCell(cell, numRows, numColumns, cellWidth, cellHeight)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `cell` | `luaIndex` | no |  |
| 2 | `numRows` | `number` | no |  |
| 3 | `numColumns` | `number` | no |  |
| 4 | `cellWidth` | `number` | yes |  |
| 5 | `cellHeight` | `number` | yes |  |

**Returns**

_None._

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenTainted"` |
| this function | `SecretArgumentsAddAspect` | `{ 8192 }` |
| argument `cell` | `ConditionalSecret` | `true` |
| argument `numRows` | `NeverSecret` | `true` |
| argument `numColumns` | `NeverSecret` | `true` |
| argument `cellWidth` | `NeverSecret` | `true` |
| argument `cellHeight` | `NeverSecret` | `true` |

Blizzard's own rendering: `SetSpriteSheetCell(cell, numRows, numColumns, optional cellWidth, optional cellHeight)`

System: `SimpleTextureBaseAPI` · Widget methods
