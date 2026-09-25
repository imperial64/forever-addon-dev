<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Club.GetInfoFromLastCommunityChatLine

```lua
messageInfo, clubId, streamId, clubType = C_Club.GetInfoFromLastCommunityChatLine()
```

**Arguments**

_None._

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `messageInfo` | `ClubMessageInfo` | no |  |
| 2 | `clubId` | `ClubId` | no |  |
| 3 | `streamId` | `ClubStreamId` | no |  |
| 4 | `clubType` | `ClubType` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `RequiresClubsInitialized` | `true` |
| this function | `SecretInChatMessagingLockdown` | `true` |

Blizzard's own rendering: `C_Club.GetInfoFromLastCommunityChatLine()`

System: `Club` · Namespace: `C_Club`
