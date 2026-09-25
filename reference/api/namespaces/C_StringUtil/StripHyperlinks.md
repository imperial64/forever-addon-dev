<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_StringUtil.StripHyperlinks

```lua
stripped = C_StringUtil.StripHyperlinks(text, maintainColor, maintainBrackets, stripNewlines, maintainAtlases, maintainTextures)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `text` | `string` | no |  |
| 2 | `maintainColor` | `bool` | no | `False` |
| 3 | `maintainBrackets` | `bool` | no | `False` |
| 4 | `stripNewlines` | `bool` | no | `False` |
| 5 | `maintainAtlases` | `bool` | no | `False` |
| 6 | `maintainTextures` | `bool` | no | `False` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `stripped` | `stringView` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenTainted"` |

Blizzard's own rendering: `C_StringUtil.StripHyperlinks(text, optional maintainColor, optional maintainBrackets, optional stripNewlines, optional maintainAtlases, optional maintainTextures)`

System: `StringUtil` · Namespace: `C_StringUtil`
