<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Commentator.SendAddonMessageLogged

```lua
result = C_Commentator.SendAddonMessageLogged(prefix, message, chatType, target)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `prefix` | `cstring` | no |  |
| 2 | `message` | `cstring` | no |  |
| 3 | `chatType` | `cstring` | yes |  |
| 4 | `target` | `cstring` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `result` | `SendAddonMessageResult` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_Commentator.SendAddonMessageLogged(prefix, message, optional chatType, optional target)`

System: `CommentatorFrame` · Namespace: `C_Commentator`
