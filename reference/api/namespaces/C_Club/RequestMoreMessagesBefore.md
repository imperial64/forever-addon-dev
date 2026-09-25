<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Club.RequestMoreMessagesBefore

```lua
alreadyHasMessages = C_Club.RequestMoreMessagesBefore(clubId, streamId, messageId, count)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `clubId` | `ClubId` | no |  |
| 2 | `streamId` | `ClubStreamId` | no |  |
| 3 | `messageId` | `ClubMessageIdentifier` | yes |  |
| 4 | `count` | `number` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `alreadyHasMessages` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `RequiresClubsInitialized` | `true` |
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretInChatMessagingLockdown` | `true` |

Blizzard's own rendering: `C_Club.RequestMoreMessagesBefore(clubId, streamId, optional messageId, optional count)`

System: `Club` · Namespace: `C_Club`
