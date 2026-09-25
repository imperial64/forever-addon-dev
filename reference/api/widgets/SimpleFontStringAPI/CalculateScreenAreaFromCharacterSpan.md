<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# SimpleFontStringAPI:CalculateScreenAreaFromCharacterSpan

```lua
areas = SimpleFontStringAPI:CalculateScreenAreaFromCharacterSpan(leftIndex, rightIndex)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `leftIndex` | `luaIndex` | no |  |
| 2 | `rightIndex` | `luaIndex` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `areas` | `table&lt;uiBoundsRect&gt;` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `RequiresFontStringTextAccess` | `true` |
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretReturnsForAspect` | `{ 8 }` |
| this function | `SecretWhenAnchoringSecret` | `true` |

Blizzard's own rendering: `CalculateScreenAreaFromCharacterSpan(leftIndex, rightIndex)`

System: `SimpleFontStringAPI` · Widget methods
