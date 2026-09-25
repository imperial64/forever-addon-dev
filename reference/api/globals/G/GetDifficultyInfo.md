<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# GetDifficultyInfo

```lua
name, instanceType, isHeroic, isChallengeMode, displayHeroic, displayMythic, toggleDifficultyID, isLFR, minPlayers, maxPlayers, isUserSelectable = GetDifficultyInfo(difficultyID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `difficultyID` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `name` | `cstring` | no |  |
| 2 | `instanceType` | `cstring` | no |  |
| 3 | `isHeroic` | `bool` | no |  |
| 4 | `isChallengeMode` | `bool` | no |  |
| 5 | `displayHeroic` | `bool` | no |  |
| 6 | `displayMythic` | `bool` | no |  |
| 7 | `toggleDifficultyID` | `number` | yes |  |
| 8 | `isLFR` | `bool` | no |  |
| 9 | `minPlayers` | `number` | yes |  |
| 10 | `maxPlayers` | `number` | yes |  |
| 11 | `isUserSelectable` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `GetDifficultyInfo(difficultyID)`

System: `Instance`
