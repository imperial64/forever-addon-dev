<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# UnitPowerBarTimerInfo

```lua
duration, expiration, barID, auraID = UnitPowerBarTimerInfo(unit, index)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unit` | `UnitToken` | no |  |
| 2 | `index` | `luaIndex` | no | `0` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `duration` | `number` | no |  |
| 2 | `expiration` | `number` | no |  |
| 3 | `barID` | `number` | no |  |
| 4 | `auraID` | `number` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretReturns` | `true` |

Blizzard's own rendering: `UnitPowerBarTimerInfo(unit, optional index)`

System: `Unit`
