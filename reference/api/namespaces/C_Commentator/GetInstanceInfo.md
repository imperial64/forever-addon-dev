<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Commentator.GetInstanceInfo

```lua
mapID, mapName, status, instanceIDLow, instanceIDHigh = C_Commentator.GetInstanceInfo(mapIndex, instanceIndex)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `mapIndex` | `luaIndex` | no |  |
| 2 | `instanceIndex` | `luaIndex` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `mapID` | `number` | no |  |
| 2 | `mapName` | `string` | yes |  |
| 3 | `status` | `number` | no |  |
| 4 | `instanceIDLow` | `number` | no |  |
| 5 | `instanceIDHigh` | `number` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `RequiresCommentator` | `true` |
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_Commentator.GetInstanceInfo(mapIndex, instanceIndex)`

System: `CommentatorFrame` · Namespace: `C_Commentator`
