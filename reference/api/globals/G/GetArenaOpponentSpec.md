<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# GetArenaOpponentSpec

```lua
specializationID, gender = GetArenaOpponentSpec(index)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `index` | `luaIndex` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `specializationID` | `number` | no |  |
| 2 | `gender` | `number` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretReturns` | `true` |

Blizzard's own rendering: `C_PvP.GetArenaOpponentSpec(index)`

System: `PvpInfo` · Global (function-level `Namespace`; the system's is `C_PvP`)
