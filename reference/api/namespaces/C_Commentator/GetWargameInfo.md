<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Commentator.GetWargameInfo

```lua
name, minPlayers, maxPlayers, isArena = C_Commentator.GetWargameInfo(listID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `listID` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `name` | `string` | no |  |
| 2 | `minPlayers` | `number` | no |  |
| 3 | `maxPlayers` | `number` | no |  |
| 4 | `isArena` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `RequiresCommentator` | `true` |
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_Commentator.GetWargameInfo(listID)`

System: `CommentatorFrame` · Namespace: `C_Commentator`
