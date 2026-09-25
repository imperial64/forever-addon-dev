<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_SpecializationInfo.GetSpecializationMasterySpells

```lua
spellIDs = C_SpecializationInfo.GetSpecializationMasterySpells(specializationIndex, isInspect, isPet)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `specializationIndex` | `luaIndex` | no |  |
| 2 | `isInspect` | `bool` | yes |  |
| 3 | `isPet` | `bool` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `spellIDs` | `table&lt;number&gt;` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_SpecializationInfo.GetSpecializationMasterySpells(specializationIndex, optional isInspect, optional isPet)`

System: `SpecializationInfo` · Namespace: `C_SpecializationInfo`
