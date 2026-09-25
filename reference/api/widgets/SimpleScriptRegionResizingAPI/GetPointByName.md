<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# SimpleScriptRegionResizingAPI:GetPointByName

```lua
point, relativeTo, relativePoint, offsetX, offsetY = SimpleScriptRegionResizingAPI:GetPointByName(point, resolveCollapsed)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `point` | `FramePoint` | no |  |
| 2 | `resolveCollapsed` | `bool` | no | `False` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `point` | `FramePoint` | no |  |
| 2 | `relativeTo` | `ScriptRegion` | no |  |
| 3 | `relativePoint` | `FramePoint` | no |  |
| 4 | `offsetX` | `uiUnit` | no |  |
| 5 | `offsetY` | `uiUnit` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `ConstSecretAccessor` | `true` |
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretWhenAnchoringSecret` | `true` |

Blizzard's own rendering: `GetPointByName(point, optional resolveCollapsed)`

System: `SimpleScriptRegionResizingAPI` · Widget methods
