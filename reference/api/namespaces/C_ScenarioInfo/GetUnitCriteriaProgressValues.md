<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_ScenarioInfo.GetUnitCriteriaProgressValues

```lua
actualValue, percentValue, percentValueString = C_ScenarioInfo.GetUnitCriteriaProgressValues(unit)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unit` | `UnitToken` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `actualValue` | `number` | no |  |
| 2 | `percentValue` | `number` | no |  |
| 3 | `percentValueString` | `string` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretWhenUnitIdentityRestricted` | `true` |

Blizzard's own rendering: `C_ScenarioInfo.GetUnitCriteriaProgressValues(unit)`

System: `ScenarioInfo` · Namespace: `C_ScenarioInfo`
