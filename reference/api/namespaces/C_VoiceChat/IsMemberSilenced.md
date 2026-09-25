<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_VoiceChat.IsMemberSilenced

```lua
silenced = C_VoiceChat.IsMemberSilenced(memberID, channelID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `memberID` | `number` | no |  |
| 2 | `channelID` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `silenced` | `bool` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretInChatMessagingLockdown` | `true` |

Blizzard's own rendering: `C_VoiceChat.IsMemberSilenced(memberID, channelID)`

System: `VoiceChat` · Namespace: `C_VoiceChat`
