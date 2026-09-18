<!-- GENERATED from Blizzard_APIDocumentation, client build unknown. Do not edit; edit the generator. -->

# SimpleScriptRegionResizingAPI:GetPoint

```lua
point, relativeTo, relativePoint, offsetX, offsetY = SimpleScriptRegionResizingAPI:GetPoint(anchorIndex, resolveCollapsed)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `anchorIndex` | `luaIndex` | no | `0` |
| 2 | `resolveCollapsed` | `bool` | no | `False` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `point` | `FramePoint` | no |  |
| 2 | `relativeTo` | `ScriptRegion` | no |  |
| 3 | `relativePoint` | `FramePoint` | no |  |
| 4 | `offsetX` | `uiUnit` | no |  |
| 5 | `offsetY` | `uiUnit` | no |  |

Blizzard's own rendering: `GetPoint(optional anchorIndex, optional resolveCollapsed)`

System: `SimpleScriptRegionResizingAPI` · Widget methods
