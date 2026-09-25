<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Garrison.GetFollowerAutoCombatSpells

```lua
autoCombatSpells, autoCombatAutoAttack = C_Garrison.GetFollowerAutoCombatSpells(garrFollowerID, followerLevel)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `garrFollowerID` | `GarrisonFollower` | no |  |
| 2 | `followerLevel` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `autoCombatSpells` | `table&lt;AutoCombatSpellInfo&gt;` | no |  |
| 2 | `autoCombatAutoAttack` | `AutoCombatSpellInfo` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_Garrison.GetFollowerAutoCombatSpells(garrFollowerID, followerLevel)`

System: `GarrisonInfo` · Namespace: `C_Garrison`
