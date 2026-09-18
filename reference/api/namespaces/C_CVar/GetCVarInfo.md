<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# C_CVar.GetCVarInfo

```lua
value, defaultValue, isStoredServerAccount, isStoredServerCharacter, isLockedFromUser, isSecure, isReadOnly = C_CVar.GetCVarInfo(name)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `name` | `cstring` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `value` | `cstring` | no |  |
| 2 | `defaultValue` | `cstring` | no |  |
| 3 | `isStoredServerAccount` | `bool` | no |  |
| 4 | `isStoredServerCharacter` | `bool` | no |  |
| 5 | `isLockedFromUser` | `bool` | no |  |
| 6 | `isSecure` | `bool` | no |  |
| 7 | `isReadOnly` | `bool` | no |  |

Blizzard's own rendering: `C_CVar.GetCVarInfo(name)`

System: `CVarScripts` · Namespace: `C_CVar`
