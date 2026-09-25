<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Map.GetMapInfoAtPosition

```lua
info = C_Map.GetMapInfoAtPosition(uiMapID, x, y, ignoreZoneMapPositionData)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `uiMapID` | `number` | no |  |
| 2 | `x` | `number` | no |  |
| 3 | `y` | `number` | no |  |
| 4 | `ignoreZoneMapPositionData` | `bool` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `info` | `UiMapDetails` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_Map.GetMapInfoAtPosition(uiMapID, x, y, optional ignoreZoneMapPositionData)`

System: `MapUI` · Namespace: `C_Map`
