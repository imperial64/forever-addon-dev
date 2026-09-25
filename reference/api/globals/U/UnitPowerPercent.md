<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# UnitPowerPercent

```lua
result = UnitPowerPercent(unitToken, powerType, unmodified, curve)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unitToken` | `UnitTokenPvPRestrictedForAddOns` | no |  |
| 2 | `powerType` | `PowerType` | yes |  |
| 3 | `unmodified` | `bool` | no | `False` |
| 4 | `curve` | `LuaCurveObjectBase` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `result` | `LuaCurveEvaluatedResult` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretWhenCurveSecret` | `true` |
| this function | `SecretWhenUnitPowerRestricted` | `true` |

Blizzard's own rendering: `UnitPowerPercent(unitToken, optional powerType, optional unmodified, optional curve)`

System: `Unit`
