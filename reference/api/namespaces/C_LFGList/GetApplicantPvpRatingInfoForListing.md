<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_LFGList.GetApplicantPvpRatingInfoForListing

```lua
pvpRatingInfo = C_LFGList.GetApplicantPvpRatingInfoForListing(localID, applicantIndex, activityID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `localID` | `number` | no |  |
| 2 | `applicantIndex` | `luaIndex` | no |  |
| 3 | `activityID` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `pvpRatingInfo` | `PvpRatingInfo` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_LFGList.GetApplicantPvpRatingInfoForListing(localID, applicantIndex, activityID)`

System: `LFGList` · Namespace: `C_LFGList`
