<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# UnitHealthPercent

```lua
result = UnitHealthPercent(unit, usePredicted, curve)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unit` | `UnitTokenPvPRestrictedForAddOns` | no |  |
| 2 | `usePredicted` | `bool` | no | `True` |
| 3 | `curve` | `LuaCurveObjectBase` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `result` | `LuaCurveEvaluatedResult` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretReturns` | `true` |
| this function | `SecretWhenCurveSecret` | `true` |

Blizzard's own rendering: `UnitHealthPercent(unit, optional usePredicted, optional curve)`

System: `Unit`
