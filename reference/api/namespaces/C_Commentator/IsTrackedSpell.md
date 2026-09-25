<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Commentator.IsTrackedSpell

```lua
isTracked = C_Commentator.IsTrackedSpell(teamIndex, playerIndex, spellID, category)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `teamIndex` | `luaIndex` | no |  |
| 2 | `playerIndex` | `luaIndex` | no |  |
| 3 | `spellID` | `number` | no |  |
| 4 | `category` | `TrackedSpellCategory` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `isTracked` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `RequiresActiveCommentator` | `true` |
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_Commentator.IsTrackedSpell(teamIndex, playerIndex, spellID, category)`

System: `CommentatorFrame` · Namespace: `C_Commentator`
