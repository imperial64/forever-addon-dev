<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# C_ContentTracking.GetBestMapForTrackable

```lua
result, mapID = C_ContentTracking.GetBestMapForTrackable(trackableType, trackableID, ignoreWaypoint)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `trackableType` | `ContentTrackingType` | no |  |
| 2 | `trackableID` | `number` | no |  |
| 3 | `ignoreWaypoint` | `bool` | no | `False` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `result` | `ContentTrackingResult` | no |  |
| 2 | `mapID` | `number` | yes |  |

Blizzard's own rendering: `C_ContentTracking.GetBestMapForTrackable(trackableType, trackableID, optional ignoreWaypoint)`

System: `ContentTracking` · Namespace: `C_ContentTracking`
