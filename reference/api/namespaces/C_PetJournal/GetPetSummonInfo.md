<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_PetJournal.GetPetSummonInfo

```lua
isSummonable, error, errorText = C_PetJournal.GetPetSummonInfo(battlePetGUID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `battlePetGUID` | `WOWGUID` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `isSummonable` | `bool` | no |  |
| 2 | `error` | `PetJournalError` | no |  |
| 3 | `errorText` | `cstring` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_PetJournal.GetPetSummonInfo(battlePetGUID)`

System: `PetJournalInfo` · Namespace: `C_PetJournal`
