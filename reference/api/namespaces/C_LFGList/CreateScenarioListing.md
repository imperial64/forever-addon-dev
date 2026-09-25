<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_LFGList.CreateScenarioListing

```lua
canCreate = C_LFGList.CreateScenarioListing(activityID, itemLevel, autoAccept, privateGroup, scenarioID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `activityID` | `number` | no |  |
| 2 | `itemLevel` | `number` | no |  |
| 3 | `autoAccept` | `bool` | no |  |
| 4 | `privateGroup` | `bool` | no |  |
| 5 | `scenarioID` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `canCreate` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_LFGList.CreateScenarioListing(activityID, itemLevel, autoAccept, privateGroup, scenarioID)`

System: `LFGList` · Namespace: `C_LFGList`
