<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_DamageMeter.GetCombatSessionFromType

```lua
session = C_DamageMeter.GetCombatSessionFromType(sessionType, type)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `sessionType` | `DamageMeterSessionType` | no |  |
| 2 | `type` | `DamageMeterType` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `session` | `DamageMeterCombatSession` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretWhenInCombat` | `true` |

Blizzard's own rendering: `C_DamageMeter.GetCombatSessionFromType(sessionType, type)`

System: `DamageMeter` · Namespace: `C_DamageMeter`
