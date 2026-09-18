<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# GetGameMessageInfo

```lua
errorName, soundKitID, voiceID = GetGameMessageInfo(gameErrorIndex)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `gameErrorIndex` | `luaIndex` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `errorName` | `cstring` | no |  |
| 2 | `soundKitID` | `number` | yes |  |
| 3 | `voiceID` | `number` | yes |  |

Blizzard's own rendering: `GetGameMessageInfo(gameErrorIndex)`

System: `GameError`
