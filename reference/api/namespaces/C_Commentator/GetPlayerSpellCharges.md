<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Commentator.GetPlayerSpellCharges

```lua
charges, maxCharges, startTime, duration = C_Commentator.GetPlayerSpellCharges(teamIndex, playerIndex, spellID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `teamIndex` | `luaIndex` | no |  |
| 2 | `playerIndex` | `luaIndex` | no |  |
| 3 | `spellID` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `charges` | `number` | no |  |
| 2 | `maxCharges` | `number` | no |  |
| 3 | `startTime` | `number` | no |  |
| 4 | `duration` | `number` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `RequiresActiveCommentator` | `true` |
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_Commentator.GetPlayerSpellCharges(teamIndex, playerIndex, spellID)`

System: `CommentatorFrame` · Namespace: `C_Commentator`
