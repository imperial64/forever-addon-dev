<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Garrison.AddFollowerToMission

```lua
followerAdded = C_Garrison.AddFollowerToMission(missionID, followerID, boardIndex)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `missionID` | `number` | no |  |
| 2 | `followerID` | `GarrisonFollower` | no |  |
| 3 | `boardIndex` | `number` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `followerAdded` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_Garrison.AddFollowerToMission(missionID, followerID, optional boardIndex)`

System: `GarrisonInfo` · Namespace: `C_Garrison`
