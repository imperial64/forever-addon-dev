<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Commentator.GetPlayerItemCooldownInfo

```lua
startTime, duration, enable = C_Commentator.GetPlayerItemCooldownInfo(teamIndex, playerIndex, itemID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `teamIndex` | `luaIndex` | no |  |
| 2 | `playerIndex` | `luaIndex` | no |  |
| 3 | `itemID` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `startTime` | `number` | no |  |
| 2 | `duration` | `number` | no |  |
| 3 | `enable` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `RequiresActiveCommentator` | `true` |
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_Commentator.GetPlayerItemCooldownInfo(teamIndex, playerIndex, itemID)`

System: `CommentatorFrame` · Namespace: `C_Commentator`
