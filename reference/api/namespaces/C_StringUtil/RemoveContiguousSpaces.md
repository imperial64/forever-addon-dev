<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_StringUtil.RemoveContiguousSpaces

```lua
trimmedText = C_StringUtil.RemoveContiguousSpaces(text, maxAllowedSpaces)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `text` | `stringView` | no |  |
| 2 | `maxAllowedSpaces` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `trimmedText` | `string` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenTainted"` |
| argument `maxAllowedSpaces` | `NeverSecret` | `true` |

Blizzard's own rendering: `C_StringUtil.RemoveContiguousSpaces(text, maxAllowedSpaces)`

System: `StringUtil` · Namespace: `C_StringUtil`
