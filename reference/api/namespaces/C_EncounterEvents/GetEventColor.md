<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_EncounterEvents.GetEventColor

```lua
color = C_EncounterEvents.GetEventColor(encounterEventID, trigger)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `encounterEventID` | `number` | no |  |
| 2 | `trigger` | `EncounterEventColorTrigger` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `color` | `colorRGBA (ColorMixin)` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_EncounterEvents.GetEventColor(encounterEventID, trigger)`

System: `EncounterEvents` · Namespace: `C_EncounterEvents`
