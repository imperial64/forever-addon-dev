<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# C_EncounterTimeline.GetSortedEventList

```lua
events = C_EncounterTimeline.GetSortedEventList(maxEventCount, maxEventDuration, excludeTerminalStates, excludeHiddenEvents)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `maxEventCount` | `number` | yes |  |
| 2 | `maxEventDuration` | `Seconds` | yes |  |
| 3 | `excludeTerminalStates` | `bool` | no | `True` |
| 4 | `excludeHiddenEvents` | `bool` | no | `True` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `events` | `table&lt;EncounterTimelineEventID&gt;` | no |  |

Blizzard's own rendering: `C_EncounterTimeline.GetSortedEventList(optional maxEventCount, optional maxEventDuration, optional excludeTerminalStates, optional excludeHiddenEvents)`

System: `EncounterTimeline` · Namespace: `C_EncounterTimeline`
