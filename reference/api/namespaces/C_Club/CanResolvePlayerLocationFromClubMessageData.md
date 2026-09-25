<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Club.CanResolvePlayerLocationFromClubMessageData

```lua
canResolve = C_Club.CanResolvePlayerLocationFromClubMessageData(clubId, streamId, epoch, position)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `clubId` | `ClubId` | no |  |
| 2 | `streamId` | `ClubStreamId` | no |  |
| 3 | `epoch` | `BigUInteger` | no |  |
| 4 | `position` | `BigUInteger` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `canResolve` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `RequiresClubsInitialized` | `true` |
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_Club.CanResolvePlayerLocationFromClubMessageData(clubId, streamId, epoch, position)`

System: `Club` · Namespace: `C_Club`
