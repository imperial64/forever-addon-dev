<!-- GENERATED from Blizzard_APIDocumentation, client build unknown. Do not edit; edit the generator. -->

# GetMirrorTimerInfo

```lua
name, startValue, maxValue, scale, paused, label, spellID = GetMirrorTimerInfo(timerIndex)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `timerIndex` | `luaIndex` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `name` | `cstring` | no |  |
| 2 | `startValue` | `number` | no |  |
| 3 | `maxValue` | `number` | no |  |
| 4 | `scale` | `number` | no |  |
| 5 | `paused` | `number` | no |  |
| 6 | `label` | `cstring` | no |  |
| 7 | `spellID` | `number` | no |  |

Blizzard's own rendering: `GetMirrorTimerInfo(timerIndex)`

System: `MirrorTimer`
