<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

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

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `SetUnitCursorTexture(textureObject, unit, optional style, optional includeLowPriority, optional preferGamepadIcon)`

System: `Unit`
