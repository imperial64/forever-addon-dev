<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# EncounterTimelineEventInfo

_Structure_

**Fields**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `id` | `EncounterTimelineEventID` | no |  |
| 2 | `source` | `EncounterTimelineEventSource` | no |  |
| 3 | `spellName` | `string` | no |  |
| 4 | `spellID` | `number` | no |  |
| 5 | `iconFileID` | `fileID` | no |  |
| 6 | `duration` | `Seconds` | no |  |
| 7 | `maxQueueDuration` | `Seconds` | no |  |
| 8 | `icons` | `EncounterEventIconmask` | no |  |
| 9 | `severity` | `EncounterEventSeverity` | no |  |
| 10 | `isApproximate` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| field `id` | `NeverSecret` | `true` |
| field `source` | `NeverSecret` | `true` |
| field `duration` | `NeverSecret` | `true` |
| field `maxQueueDuration` | `NeverSecret` | `true` |

System: `EncounterTimeline`
