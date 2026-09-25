<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# GetUnitSpeed

```lua
currentSpeed, runSpeed, flightSpeed, swimSpeed = GetUnitSpeed(unit)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unit` | `UnitToken` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `currentSpeed` | `number` | no |  |
| 2 | `runSpeed` | `number` | no |  |
| 3 | `flightSpeed` | `number` | no |  |
| 4 | `swimSpeed` | `number` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretWhenUnitStatsRestricted` | `true` |

Blizzard's own rendering: `GetUnitSpeed(unit)`

System: `Unit`
