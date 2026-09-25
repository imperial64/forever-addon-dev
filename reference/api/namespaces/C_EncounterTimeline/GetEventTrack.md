<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_EncounterTimeline.GetEventTrack

```lua
track, trackSortIndex = C_EncounterTimeline.GetEventTrack(eventID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `eventID` | `EncounterTimelineEventID` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `track` | `EncounterTimelineTrack` | no |  |
| 2 | `trackSortIndex` | `luaIndex` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `RequiresValidTimelineEvent` | `true` |
| this function | `SecretArguments` | `"NotAllowed"` |

Blizzard's own rendering: `C_EncounterTimeline.GetEventTrack(eventID)`

System: `EncounterTimeline` · Namespace: `C_EncounterTimeline`
