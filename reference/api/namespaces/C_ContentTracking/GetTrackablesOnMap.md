<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_ContentTracking.GetTrackablesOnMap

```lua
result, trackableMapInfos = C_ContentTracking.GetTrackablesOnMap(trackableType, uiMapID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `trackableType` | `ContentTrackingType` | no |  |
| 2 | `uiMapID` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `result` | `ContentTrackingResult` | no |  |
| 2 | `trackableMapInfos` | `table&lt;ContentTrackingMapInfo&gt;` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_ContentTracking.GetTrackablesOnMap(trackableType, uiMapID)`

System: `ContentTracking` · Namespace: `C_ContentTracking`
