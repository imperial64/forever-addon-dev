<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# C_ChatInfo.SendAddonMessageLogged

> **CAUTION — measured, at all times.** AreOutgoingAddonChatMessagesRestricted() returns true, in and out of combat.
> Measured 2026-09-20 on build 69913. Evidence: §P.10, §P.18 in [findings](../../../../research/findings.md).

```lua
result = C_ChatInfo.SendAddonMessageLogged(prefix, message, chatType, target)
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

Blizzard's own rendering: `C_ChatInfo.SendAddonMessageLogged(prefix, message, optional chatType, optional target)`

System: `ChatInfo` · Namespace: `C_ChatInfo`
