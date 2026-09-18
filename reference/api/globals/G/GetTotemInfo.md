<!-- GENERATED from Blizzard_APIDocumentation, client build unknown. Do not edit; edit the generator. -->

# GetTotemInfo

```lua
haveTotem, totemName, startTime, duration, icon, modRate, spellID = GetTotemInfo(slot)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `slot` | `luaIndex` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `haveTotem` | `bool` | no |  |
| 2 | `totemName` | `cstring` | no |  |
| 3 | `startTime` | `number` | no |  |
| 4 | `duration` | `number` | no |  |
| 5 | `icon` | `fileID` | no |  |
| 6 | `modRate` | `number` | no |  |
| 7 | `spellID` | `number` | no |  |

Blizzard's own rendering: `GetTotemInfo(slot)`

System: `Totem`
