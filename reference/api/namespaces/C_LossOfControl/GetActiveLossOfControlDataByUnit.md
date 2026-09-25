<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_LossOfControl.GetActiveLossOfControlDataByUnit

```lua
event = C_LossOfControl.GetActiveLossOfControlDataByUnit(unitToken, index)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unitToken` | `UnitToken` | no |  |
| 2 | `index` | `luaIndex` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `event` | `LossOfControlData` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretWhenLossOfControlInfoRestricted` | `true` |

Blizzard's own rendering: `C_LossOfControl.GetActiveLossOfControlDataByUnit(unitToken, index)`

System: `LossOfControl` · Namespace: `C_LossOfControl`
