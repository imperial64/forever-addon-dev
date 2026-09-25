<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# SimpleFontStringAPI:FindCharacterIndexAtCoordinate

```lua
characterIndex, inside = SimpleFontStringAPI:FindCharacterIndexAtCoordinate(x, y)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `x` | `uiUnit` | no |  |
| 2 | `y` | `uiUnit` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `characterIndex` | `luaIndex` | no |  |
| 2 | `inside` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `RequiresFontStringTextAccess` | `true` |
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretReturnsForAspect` | `{ 8 }` |
| this function | `SecretWhenAnchoringSecret` | `true` |

Blizzard's own rendering: `FindCharacterIndexAtCoordinate(x, y)`

System: `SimpleFontStringAPI` · Widget methods
