<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_EncounterTimeline.GetEventColor

```lua
color = C_EncounterTimeline.GetEventColor(eventID, overrideTrigger)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `eventID` | `EncounterTimelineEventID` | no |  |
| 2 | `overrideTrigger` | `EncounterEventColorTrigger` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `color` | `colorRGBA (ColorMixin)` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `RequiresValidTimelineEvent` | `true` |
| this function | `SecretArguments` | `"NotAllowed"` |
| this function | `SecretWhenEncounterEvent` | `true` |

Blizzard's own rendering: `C_EncounterTimeline.GetEventColor(eventID, optional overrideTrigger)`

System: `EncounterTimeline` · Namespace: `C_EncounterTimeline`
