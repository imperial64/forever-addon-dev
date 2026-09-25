<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_BattleNet.GetFriendAccountInfo

```lua
accountInfo = C_BattleNet.GetFriendAccountInfo(friendIndex, wowAccountGUID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `friendIndex` | `luaIndex` | no |  |
| 2 | `wowAccountGUID` | `WOWGUID` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `accountInfo` | `BNetAccountInfo` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_BattleNet.GetFriendAccountInfo(friendIndex, optional wowAccountGUID)`

System: `BattleNet` · Namespace: `C_BattleNet`
