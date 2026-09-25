<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# GetInstanceLockTimeRemainingEncounter

```lua
encounterName, texture, isKilled, ineligible = GetInstanceLockTimeRemainingEncounter(encounterIndex)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `encounterIndex` | `luaIndex` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `encounterName` | `cstring` | no |  |
| 2 | `texture` | `cstring` | no |  |
| 3 | `isKilled` | `bool` | no |  |
| 4 | `ineligible` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `GetInstanceLockTimeRemainingEncounter(encounterIndex)`

System: `Instance`
