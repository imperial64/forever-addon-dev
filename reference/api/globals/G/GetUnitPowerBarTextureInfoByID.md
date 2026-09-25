<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# GetUnitPowerBarTextureInfoByID

```lua
texture, colorR, colorG, colorB, colorA = GetUnitPowerBarTextureInfoByID(barID, textureIndex)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `barID` | `number` | no |  |
| 2 | `textureIndex` | `luaIndex` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `texture` | `fileID` | no |  |
| 2 | `colorR` | `number` | no |  |
| 3 | `colorG` | `number` | no |  |
| 4 | `colorB` | `number` | no |  |
| 5 | `colorA` | `number` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `GetUnitPowerBarTextureInfoByID(barID, textureIndex)`

System: `Unit`
