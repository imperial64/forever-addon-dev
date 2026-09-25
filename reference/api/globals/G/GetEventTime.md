<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

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

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `GetEventTime(eventProfileIndex)`

System: `FrameScript`
