<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_PlayerInfo.GetClass

```lua
className, classFilename, classID = C_PlayerInfo.GetClass(playerLocation)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `playerLocation` | `PlayerLocation (PlayerLocationMixin)` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `className` | `cstring` | yes |  |
| 2 | `classFilename` | `cstring` | yes |  |
| 3 | `classID` | `number` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_PlayerInfo.GetClass(playerLocation)`

System: `PlayerLocationInfo` · Namespace: `C_PlayerInfo`
