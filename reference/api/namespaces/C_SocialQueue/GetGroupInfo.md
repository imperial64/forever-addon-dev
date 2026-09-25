<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_SocialQueue.GetGroupInfo

```lua
canJoin, numQueues, needTank, needHealer, needDamage, isSoloQueueParty, questSessionActive, leaderGUID = C_SocialQueue.GetGroupInfo(groupGUID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `groupGUID` | `WOWGUID` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `canJoin` | `bool` | no |  |
| 2 | `numQueues` | `number` | no |  |
| 3 | `needTank` | `bool` | no |  |
| 4 | `needHealer` | `bool` | no |  |
| 5 | `needDamage` | `bool` | no |  |
| 6 | `isSoloQueueParty` | `bool` | no |  |
| 7 | `questSessionActive` | `bool` | no |  |
| 8 | `leaderGUID` | `WOWGUID` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_SocialQueue.GetGroupInfo(groupGUID)`

System: `SocialQueue` · Namespace: `C_SocialQueue`
