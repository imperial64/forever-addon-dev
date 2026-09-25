<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_PvP.GetBattlefieldFlagPosition

```lua
uiPosx, uiPosy, flagTexture = C_PvP.GetBattlefieldFlagPosition(flagIndex, uiMapId)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `flagIndex` | `luaIndex` | no |  |
| 2 | `uiMapId` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `uiPosx` | `number` | yes |  |
| 2 | `uiPosy` | `number` | yes |  |
| 3 | `flagTexture` | `number` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_PvP.GetBattlefieldFlagPosition(flagIndex, uiMapId)`

System: `PvpInfo` · Namespace: `C_PvP`
