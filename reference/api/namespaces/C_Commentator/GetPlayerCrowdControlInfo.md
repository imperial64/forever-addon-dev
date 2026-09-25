<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Commentator.GetPlayerCrowdControlInfo

```lua
spellID, expiration, duration = C_Commentator.GetPlayerCrowdControlInfo(teamIndex, playerIndex)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `teamIndex` | `luaIndex` | no |  |
| 2 | `playerIndex` | `luaIndex` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `spellID` | `number` | no |  |
| 2 | `expiration` | `number` | no |  |
| 3 | `duration` | `number` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `RequiresActiveCommentator` | `true` |
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_Commentator.GetPlayerCrowdControlInfo(teamIndex, playerIndex)`

System: `CommentatorFrame` · Namespace: `C_Commentator`
