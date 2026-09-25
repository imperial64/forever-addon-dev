<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Commentator.GetMapInfo

```lua
teamSize, minLevel, maxLevel, numInstances = C_Commentator.GetMapInfo(mapIndex)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `mapIndex` | `luaIndex` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `teamSize` | `number` | no |  |
| 2 | `minLevel` | `number` | no |  |
| 3 | `maxLevel` | `number` | no |  |
| 4 | `numInstances` | `number` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `RequiresCommentator` | `true` |
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_Commentator.GetMapInfo(mapIndex)`

System: `CommentatorFrame` · Namespace: `C_Commentator`
