<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_ChatInfo.ReplaceIconAndGroupExpressions

```lua
output = C_ChatInfo.ReplaceIconAndGroupExpressions(input, noIconReplacement, noGroupReplacement)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `input` | `string` | no |  |
| 2 | `noIconReplacement` | `bool` | yes |  |
| 3 | `noGroupReplacement` | `bool` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `output` | `string` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenTainted"` |
| argument `noIconReplacement` | `NeverSecret` | `true` |
| argument `noGroupReplacement` | `NeverSecret` | `true` |

Blizzard's own rendering: `C_ChatInfo.ReplaceIconAndGroupExpressions(input, optional noIconReplacement, optional noGroupReplacement)`

System: `ChatInfo` · Namespace: `C_ChatInfo`
