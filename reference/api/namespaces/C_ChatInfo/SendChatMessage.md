<!-- GENERATED from Blizzard_APIDocumentation, client build unknown. Do not edit; edit the generator. -->

# C_ChatInfo.SendChatMessage

> **RESTRICTED — Blizzard flag.** This function carries `HasRestrictions` in the client's own documentation, meaning it is gated on a hardware event or refuses to run from a script.

```lua
C_ChatInfo.SendChatMessage(message, chatType, languageID, target)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `message` | `cstring` | no |  |
| 2 | `chatType` | `SendChatMessageType` | yes |  |
| 3 | `languageID` | `number` | yes |  |
| 4 | `target` | `cstring` | yes |  |

**Returns**

_None._

Blizzard's own rendering: `C_ChatInfo.SendChatMessage(message, optional chatType, optional languageID, optional target)`

System: `ChatInfo` · Namespace: `C_ChatInfo`
