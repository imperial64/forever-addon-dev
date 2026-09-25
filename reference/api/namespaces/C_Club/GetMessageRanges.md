<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Club.GetMessageRanges

```lua
ranges = C_Club.GetMessageRanges(clubId, streamId)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `clubId` | `ClubId` | no |  |
| 2 | `streamId` | `ClubStreamId` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `ranges` | `table&lt;ClubMessageRange&gt;` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `RequiresClubsInitialized` | `true` |
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretInChatMessagingLockdown` | `true` |

Blizzard's own rendering: `C_Club.GetMessageRanges(clubId, streamId)`

System: `Club` · Namespace: `C_Club`
