<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Garrison.GetAutoMissionTargetingInfo

```lua
targetInfo = C_Garrison.GetAutoMissionTargetingInfo(missionID, followerID, casterBoardIndex)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `missionID` | `number` | no |  |
| 2 | `followerID` | `GarrisonFollower` | no |  |
| 3 | `casterBoardIndex` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `targetInfo` | `table&lt;AutoMissionTargetingInfo&gt;` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_Garrison.GetAutoMissionTargetingInfo(missionID, followerID, casterBoardIndex)`

System: `GarrisonInfo` · Namespace: `C_Garrison`
