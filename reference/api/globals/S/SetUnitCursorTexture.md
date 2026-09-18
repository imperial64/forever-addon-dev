<!-- GENERATED from Blizzard_APIDocumentation, client build unknown. Do not edit; edit the generator. -->

# SetUnitCursorTexture

```lua
hasCursor = SetUnitCursorTexture(textureObject, unit, style, includeLowPriority, preferGamepadIcon)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `textureObject` | `SimpleTexture` | no |  |
| 2 | `unit` | `UnitToken` | no |  |
| 3 | `style` | `CursorStyle` | yes |  |
| 4 | `includeLowPriority` | `bool` | yes |  |
| 5 | `preferGamepadIcon` | `bool` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `hasCursor` | `bool` | no |  |

Blizzard's own rendering: `SetUnitCursorTexture(textureObject, unit, optional style, optional includeLowPriority, optional preferGamepadIcon)`

System: `Unit`
