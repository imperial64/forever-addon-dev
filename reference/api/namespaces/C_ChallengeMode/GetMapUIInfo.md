<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_ChallengeMode.GetMapUIInfo

```lua
name, id, timeLimit, texture, backgroundTexture, mapID = C_ChallengeMode.GetMapUIInfo(mapChallengeModeID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `mapChallengeModeID` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `name` | `cstring` | no |  |
| 2 | `id` | `number` | no |  |
| 3 | `timeLimit` | `number` | no |  |
| 4 | `texture` | `number` | yes |  |
| 5 | `backgroundTexture` | `number` | no |  |
| 6 | `mapID` | `number` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_ChallengeMode.GetMapUIInfo(mapChallengeModeID)`

System: `ChallengeModeInfo` · Namespace: `C_ChallengeMode`
