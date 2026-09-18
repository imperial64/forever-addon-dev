<!-- GENERATED from Blizzard_APIDocumentation, client build unknown. Do not edit; edit the generator. -->

# C_SpecializationInfo.GetSpecializationInfo

```lua
specId, name, description, icon, role, primaryStat, pointsSpent, background, previewPointsSpent, isUnlocked = C_SpecializationInfo.GetSpecializationInfo(specializationIndex, isInspect, isPet, inspectTarget, sex, groupIndex, classID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `specializationIndex` | `luaIndex` | no |  |
| 2 | `isInspect` | `bool` | no | `False` |
| 3 | `isPet` | `bool` | no | `False` |
| 4 | `inspectTarget` | `string` | yes |  |
| 5 | `sex` | `number` | yes |  |
| 6 | `groupIndex` | `luaIndex` | yes |  |
| 7 | `classID` | `number` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `specId` | `number` | no | `0` |
| 2 | `name` | `string` | yes |  |
| 3 | `description` | `string` | yes |  |
| 4 | `icon` | `fileID` | yes |  |
| 5 | `role` | `string` | yes |  |
| 6 | `primaryStat` | `luaIndex` | yes |  |
| 7 | `pointsSpent` | `number` | no | `0` |
| 8 | `background` | `string` | yes |  |
| 9 | `previewPointsSpent` | `number` | no | `0` |
| 10 | `isUnlocked` | `bool` | no | `True` |

Blizzard's own rendering: `C_SpecializationInfo.GetSpecializationInfo(specializationIndex, optional isInspect, optional isPet, optional inspectTarget, optional sex, optional groupIndex, optional classID)`

System: `SpecializationInfo` · Namespace: `C_SpecializationInfo`
