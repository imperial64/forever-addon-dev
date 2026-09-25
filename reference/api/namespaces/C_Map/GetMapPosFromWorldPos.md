<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Map.GetMapPosFromWorldPos

```lua
uiMapID, mapPosition = C_Map.GetMapPosFromWorldPos(continentID, worldPosition, overrideUiMapID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `continentID` | `number` | no |  |
| 2 | `worldPosition` | `vector2 (Vector2DMixin)` | no |  |
| 3 | `overrideUiMapID` | `number` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `uiMapID` | `number` | no |  |
| 2 | `mapPosition` | `vector2 (Vector2DMixin)` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_Map.GetMapPosFromWorldPos(continentID, worldPosition, optional overrideUiMapID)`

System: `MapUI` · Namespace: `C_Map`
