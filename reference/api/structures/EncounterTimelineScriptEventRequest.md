<!-- GENERATED from Blizzard_APIDocumentation, client build unknown. Do not edit; edit the generator. -->

# EncounterTimelineScriptEventRequest

_Structure_

**Fields**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `spellID` | `number` | no |  |
| 2 | `iconFileID` | `fileID` | no |  |
| 3 | `duration` | `Seconds` | no |  |
| 4 | `maxQueueDuration` | `Seconds` | no | `0` |
| 5 | `overrideName` | `stringView` | no | `` |
| 6 | `icons` | `EncounterEventIconmask` | yes |  |
| 7 | `severity` | `EncounterEventSeverity` | no | `Medium` |
| 8 | `paused` | `bool` | no | `False` |

System: `EncounterTimeline`
