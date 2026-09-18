<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

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

Blizzard's own rendering: `UnitPowerPercent(unitToken, optional powerType, optional unmodified, optional curve)`

System: `Unit`
