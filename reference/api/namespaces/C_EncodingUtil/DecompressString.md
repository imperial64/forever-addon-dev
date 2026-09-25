<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_EncodingUtil.DecompressString

```lua
output = C_EncodingUtil.DecompressString(source, method)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `source` | `stringView` | no |  |
| 2 | `method` | `CompressionMethod` | no | `Deflate` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `output` | `string` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_EncodingUtil.DecompressString(source, optional method)`

System: `EncodingUtil` · Namespace: `C_EncodingUtil`
