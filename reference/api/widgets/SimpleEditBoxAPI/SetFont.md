<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# SimpleEditBoxAPI:SetFont

```lua
success = SimpleEditBoxAPI:SetFont(fontFile, height, flags)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `fontFile` | `cstring` | no |  |
| 2 | `height` | `uiFontHeight` | no |  |
| 3 | `flags` | `TBFFlags` | no |  |

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

Blizzard's own rendering: `SetFont(fontFile, height, flags)`

System: `SimpleEditBoxAPI` · Widget methods
