<!-- GENERATED from Blizzard_APIDocumentation, client build unknown. Do not edit; edit the generator. -->

# GetEventTime

```lua
totalElapsedTime, numExecutedHandlers, slowestHandlerName, slowestHandlerTime = GetEventTime(eventProfileIndex)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `eventProfileIndex` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `totalElapsedTime` | `number` | no |  |
| 2 | `numExecutedHandlers` | `number` | no |  |
| 3 | `slowestHandlerName` | `cstring` | no |  |
| 4 | `slowestHandlerTime` | `number` | no |  |

Blizzard's own rendering: `GetEventTime(eventProfileIndex)`

System: `FrameScript`
