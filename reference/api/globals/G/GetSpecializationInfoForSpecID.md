<!-- GENERATED from Blizzard_APIDocumentation, client build unknown. Do not edit; edit the generator. -->

# GetSpecializationInfoForSpecID

```lua
id, name, description, icon, role, recommended, allowedForBoost, masterySpell1, masterySpell2 = GetSpecializationInfoForSpecID(specID, gender)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `specID` | `number` | no |  |
| 2 | `gender` | `UnitSex` | yes |  |

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

Blizzard's own rendering: `GetSpecializationInfoForSpecID(specID, optional gender)`

System: `SpecializationShared`
