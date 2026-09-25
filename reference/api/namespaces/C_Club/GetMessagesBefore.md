<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Club.GetMessagesBefore

```lua
messages = C_Club.GetMessagesBefore(clubId, streamId, newest, count)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `clubId` | `ClubId` | no |  |
| 2 | `streamId` | `ClubStreamId` | no |  |
| 3 | `newest` | `ClubMessageIdentifier` | no |  |
| 4 | `count` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `messages` | `table&lt;ClubMessageInfo&gt;` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `RequiresClubsInitialized` | `true` |
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretInChatMessagingLockdown` | `true` |

Blizzard's own rendering: `C_Club.GetMessagesBefore(clubId, streamId, newest, count)`

System: `Club` · Namespace: `C_Club`
