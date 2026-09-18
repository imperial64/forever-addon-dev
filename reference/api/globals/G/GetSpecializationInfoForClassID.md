<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# GetSpecializationInfoForClassID

```lua
id, name, description, icon, role, recommended, allowedForBoost, masterySpell1, masterySpell2 = GetSpecializationInfoForClassID(classID, index, gender)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `classID` | `number` | no |  |
| 2 | `index` | `luaIndex` | no |  |
| 3 | `gender` | `UnitSex` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `id` | `number` | no |  |
| 2 | `name` | `cstring` | no |  |
| 3 | `description` | `string` | no |  |
| 4 | `icon` | `fileID` | no |  |
| 5 | `role` | `cstring` | no |  |
| 6 | `recommended` | `bool` | no |  |
| 7 | `allowedForBoost` | `bool` | no |  |
| 8 | `masterySpell1` | `number` | yes |  |
| 9 | `masterySpell2` | `number` | yes |  |

Blizzard's own rendering: `GetSpecializationInfoForClassID(classID, index, optional gender)`

System: `SpecializationShared`
