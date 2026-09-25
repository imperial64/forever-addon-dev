<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_DamageMeter.GetCombatSessionSourceFromType

```lua
sessionSource = C_DamageMeter.GetCombatSessionSourceFromType(sessionType, type, sourceGUID, sourceCreatureID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `sessionType` | `DamageMeterSessionType` | no |  |
| 2 | `type` | `DamageMeterType` | no |  |
| 3 | `sourceGUID` | `WOWGUID` | yes |  |
| 4 | `sourceCreatureID` | `number` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `sessionSource` | `DamageMeterCombatSessionSource` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretWhenInCombat` | `true` |

Blizzard's own rendering: `C_DamageMeter.GetCombatSessionSourceFromType(sessionType, type, optional sourceGUID, optional sourceCreatureID)`

System: `DamageMeter` · Namespace: `C_DamageMeter`
