<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# LuaLocaleContextAPI:FindStringMatches

```lua
byteOffsets = LuaLocaleContextAPI:FindStringMatches(text, pattern, strength)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `text` | `cstring` | no |  |
| 2 | `pattern` | `cstring` | no |  |
| 3 | `strength` | `CollationStrength` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `byteOffsets` | `table&lt;luaIndex&gt;` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenTainted"` |

Blizzard's own rendering: `FindStringMatches(text, pattern, strength)`

System: `LuaLocaleContextAPI` · Widget methods
