<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# UnitThreatSituation

```lua
result = UnitThreatSituation(unit, mobGUID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unit` | `UnitToken` | no |  |
| 2 | `mobGUID` | `UnitToken` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `result` | `number` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretWhenUnitThreatStateRestricted` | `true` |

Blizzard's own rendering: `UnitThreatSituation(unit, optional mobGUID)`

System: `Unit`
