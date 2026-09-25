<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_ContentTracking.GetNextWaypointForTrackable

```lua
result, mapInfo = C_ContentTracking.GetNextWaypointForTrackable(trackableType, trackableID, uiMapID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `trackableType` | `ContentTrackingType` | no |  |
| 2 | `trackableID` | `number` | no |  |
| 3 | `uiMapID` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `result` | `ContentTrackingResult` | no |  |
| 2 | `mapInfo` | `ContentTrackingMapInfo` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_ContentTracking.GetNextWaypointForTrackable(trackableType, trackableID, uiMapID)`

System: `ContentTracking` · Namespace: `C_ContentTracking`
