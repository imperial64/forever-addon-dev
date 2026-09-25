<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# SimpleStatusBarAPI:SetMinMaxValues

```lua
SimpleStatusBarAPI:SetMinMaxValues(minValue, maxValue, interpolation)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `minValue` | `number` | no |  |
| 2 | `maxValue` | `number` | no |  |
| 3 | `interpolation` | `StatusBarInterpolation` | no | `Immediate` |

**Returns**

_None._

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenTainted"` |
| this function | `SecretArgumentsAddAspect` | `{ 16384 }` |
| argument `interpolation` | `NeverSecret` | `true` |

Blizzard's own rendering: `SetMinMaxValues(minValue, maxValue, optional interpolation)`

System: `SimpleStatusBarAPI` · Widget methods
