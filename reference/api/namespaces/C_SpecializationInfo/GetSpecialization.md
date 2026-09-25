<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_SpecializationInfo.GetSpecialization

```lua
specializationIndex = C_SpecializationInfo.GetSpecialization(isInspect, isPet, specGroupIndex)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `isInspect` | `bool` | yes |  |
| 2 | `isPet` | `bool` | yes |  |
| 3 | `specGroupIndex` | `luaIndex` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `specializationIndex` | `luaIndex` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_SpecializationInfo.GetSpecialization(optional isInspect, optional isPet, optional specGroupIndex)`

System: `SpecializationInfo` · Namespace: `C_SpecializationInfo`
