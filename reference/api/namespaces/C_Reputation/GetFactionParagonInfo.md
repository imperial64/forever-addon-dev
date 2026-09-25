<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Reputation.GetFactionParagonInfo

```lua
currentValue, threshold, rewardQuestID, hasRewardPending, tooLowLevelForParagon, paragonStorageLevel = C_Reputation.GetFactionParagonInfo(factionID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `factionID` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `currentValue` | `number` | no |  |
| 2 | `threshold` | `number` | no |  |
| 3 | `rewardQuestID` | `number` | no |  |
| 4 | `hasRewardPending` | `bool` | no |  |
| 5 | `tooLowLevelForParagon` | `bool` | no |  |
| 6 | `paragonStorageLevel` | `number` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_Reputation.GetFactionParagonInfo(factionID)`

System: `ReputationInfo` · Namespace: `C_Reputation`
