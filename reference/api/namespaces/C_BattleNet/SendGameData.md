<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_BattleNet.SendGameData

```lua
result = C_BattleNet.SendGameData(gameAccountID, prefix, data)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `gameAccountID` | `number` | no |  |
| 2 | `prefix` | `stringView` | no |  |
| 3 | `data` | `stringView` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `result` | `SendAddonMessageResult` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_BattleNet.SendGameData(gameAccountID, prefix, data)`

System: `BattleNet` · Namespace: `C_BattleNet`
