<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_MythicPlus.GetWeeklyBestForMap

```lua
durationSec, level, completionDate, affixIDs, members, dungeonScore = C_MythicPlus.GetWeeklyBestForMap(mapChallengeModeID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `mapChallengeModeID` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `durationSec` | `number` | no |  |
| 2 | `level` | `number` | no |  |
| 3 | `completionDate` | `CalendarTime` | no |  |
| 4 | `affixIDs` | `table&lt;number&gt;` | no |  |
| 5 | `members` | `table&lt;MythicPlusMember&gt;` | no |  |
| 6 | `dungeonScore` | `number` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_MythicPlus.GetWeeklyBestForMap(mapChallengeModeID)`

System: `MythicPlusInfo` · Namespace: `C_MythicPlus`
