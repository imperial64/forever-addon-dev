<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_ContributionCollector.GetState

```lua
contributionState, contributionPercentageComplete, timeOfNextStateChange, startTime = C_ContributionCollector.GetState(contributionID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `contributionID` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `contributionState` | `ContributionState` | no | `None` |
| 2 | `contributionPercentageComplete` | `number` | no |  |
| 3 | `timeOfNextStateChange` | `time_t` | yes |  |
| 4 | `startTime` | `time_t` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_ContributionCollector.GetState(contributionID)`

System: `ContributionCollector` · Namespace: `C_ContributionCollector`
