<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# UnitVehicleSeatInfo

```lua
controlType, occupantName, serverName, ejectable, canSwitchSeats = UnitVehicleSeatInfo(unit, virtualSeatIndex)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unit` | `UnitToken` | no |  |
| 2 | `virtualSeatIndex` | `luaIndex` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `controlType` | `cstring` | no |  |
| 2 | `occupantName` | `cstring` | no |  |
| 3 | `serverName` | `cstring` | no |  |
| 4 | `ejectable` | `bool` | no |  |
| 5 | `canSwitchSeats` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `UnitVehicleSeatInfo(unit, virtualSeatIndex)`

System: `Unit`
