<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_AutoComplete.GetAutoCompleteResults

```lua
results = C_AutoComplete.GetAutoCompleteResults(name, numResults, cursorPosition, allowFullMatch, includeFlags, excludeFlags)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `name` | `cstring` | no |  |
| 2 | `numResults` | `number` | no |  |
| 3 | `cursorPosition` | `number` | no |  |
| 4 | `allowFullMatch` | `bool` | no |  |
| 5 | `includeFlags` | `number` | no |  |
| 6 | `excludeFlags` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `results` | `table&lt;AutoCompleteResult&gt;` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_AutoComplete.GetAutoCompleteResults(name, numResults, cursorPosition, allowFullMatch, includeFlags, excludeFlags)`

System: `AutoComplete` · Namespace: `C_AutoComplete`
