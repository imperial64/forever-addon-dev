<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# GetPlayerInfoByGUID

```lua
localizedClass, englishClass, localizedRace, englishRace, sex, name, realmName, level = GetPlayerInfoByGUID(guid)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `guid` | `WOWGUID` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `localizedClass` | `cstring` | no |  |
| 2 | `englishClass` | `cstring` | no |  |
| 3 | `localizedRace` | `cstring` | no |  |
| 4 | `englishRace` | `cstring` | no |  |
| 5 | `sex` | `number` | no |  |
| 6 | `name` | `string` | no |  |
| 7 | `realmName` | `cstring` | no |  |
| 8 | `level` | `number` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenTainted"` |

Blizzard's own rendering: `GetPlayerInfoByGUID(guid)`

System: `PlayerScript`
