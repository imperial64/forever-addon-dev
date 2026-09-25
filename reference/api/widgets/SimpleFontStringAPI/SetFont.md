<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# SimpleFontStringAPI:SetFont

```lua
success = SimpleFontStringAPI:SetFont(fontFile, fontHeight, flags)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `fontFile` | `FontAsset` | no |  |
| 2 | `fontHeight` | `uiFontHeight` | no |  |
| 3 | `flags` | `TBFFlags` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `success` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `RequiresValidFontAsset` | `true` |
| this function | `RequiresValidFontHeight` | `true` |
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `SetFont(fontFile, fontHeight, optional flags)`

System: `SimpleFontStringAPI` · Widget methods
