<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_VoiceChat.IsChannelJoinPending

```lua
isPending = C_VoiceChat.IsChannelJoinPending(channelType, clubId, streamId)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `channelType` | `ChatChannelType` | no |  |
| 2 | `clubId` | `ClubId` | yes |  |
| 3 | `streamId` | `ClubStreamId` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `isPending` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_VoiceChat.IsChannelJoinPending(channelType, optional clubId, optional streamId)`

System: `VoiceChat` · Namespace: `C_VoiceChat`
