<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_PetJournal.GetPetLoadOutInfo

```lua
petID, ability1ID, ability2ID, ability3ID, locked = C_PetJournal.GetPetLoadOutInfo(slot)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `slot` | `luaIndex` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `petID` | `WOWGUID` | yes |  |
| 2 | `ability1ID` | `number` | no |  |
| 3 | `ability2ID` | `number` | no |  |
| 4 | `ability3ID` | `number` | no |  |
| 5 | `locked` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_PetJournal.GetPetLoadOutInfo(slot)`

System: `PetJournalInfo` · Namespace: `C_PetJournal`
