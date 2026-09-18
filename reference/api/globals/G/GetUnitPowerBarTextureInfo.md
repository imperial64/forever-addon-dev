<!-- GENERATED from Blizzard_APIDocumentation, client build unknown. Do not edit; edit the generator. -->

# GetUnitPowerBarTextureInfo

```lua
texture, colorR, colorG, colorB, colorA = GetUnitPowerBarTextureInfo(unitToken, textureIndex, timerIndex)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unitToken` | `UnitToken` | no |  |
| 2 | `textureIndex` | `luaIndex` | no |  |
| 3 | `timerIndex` | `luaIndex` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `texture` | `fileID` | no |  |
| 2 | `colorR` | `number` | no |  |
| 3 | `colorG` | `number` | no |  |
| 4 | `colorB` | `number` | no |  |
| 5 | `colorA` | `number` | no |  |

Blizzard's own rendering: `GetUnitPowerBarTextureInfo(unitToken, textureIndex, optional timerIndex)`

System: `Unit`
