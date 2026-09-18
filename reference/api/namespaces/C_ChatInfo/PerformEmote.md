<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# C_ChatInfo.PerformEmote

> **RESTRICTED — Blizzard flag.** This function carries `HasRestrictions` in the client's own documentation, meaning it is gated on a hardware event or refuses to run from a script.

```lua
success = C_ChatInfo.PerformEmote(emoteName, targetName, suppressMoveError)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `emoteName` | `cstring` | no |  |
| 2 | `targetName` | `cstring` | yes |  |
| 3 | `suppressMoveError` | `bool` | no | `False` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `success` | `bool` | no |  |

Blizzard's own rendering: `C_ChatInfo.PerformEmote(emoteName, optional targetName, optional suppressMoveError)`

System: `ChatInfo` · Namespace: `C_ChatInfo`
