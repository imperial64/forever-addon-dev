<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# LuaDurationObjectAPI:EvaluateElapsedDuration

```lua
result = LuaDurationObjectAPI:EvaluateElapsedDuration(curve, modifier)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `curve` | `LuaCurveObjectBase` | no |  |
| 2 | `modifier` | `DurationTimeModifier` | no | `RealTime` |

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

Blizzard's own rendering: `EvaluateElapsedDuration(curve, optional modifier)`

System: `LuaDurationObjectAPI` · Widget methods
