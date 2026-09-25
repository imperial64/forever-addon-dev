<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# GetNextAvailableRaidTargetMarkerIndex

```lua
nextAvailableRaidTargetMarkerIndex = GetNextAvailableRaidTargetMarkerIndex(startIndex, reverseSearch, wrapSearch, treatDeadNonFriendlyAsAvailable)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `startIndex` | `luaIndex` | no |  |
| 2 | `reverseSearch` | `bool` | no | `False` |
| 3 | `wrapSearch` | `bool` | no | `False` |
| 4 | `treatDeadNonFriendlyAsAvailable` | `bool` | no | `False` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `nextAvailableRaidTargetMarkerIndex` | `luaIndex` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretInChatMessagingLockdown` | `true` |

Blizzard's own rendering: `GetNextAvailableRaidTargetMarkerIndex(startIndex, optional reverseSearch, optional wrapSearch, optional treatDeadNonFriendlyAsAvailable)`

System: `RaidMarkers`
