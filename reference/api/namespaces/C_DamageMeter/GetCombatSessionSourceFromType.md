<!-- GENERATED from Blizzard_APIDocumentation, client build unknown. Do not edit; edit the generator. -->

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

Blizzard's own rendering: `C_DamageMeter.GetCombatSessionSourceFromType(sessionType, type, optional sourceGUID, optional sourceCreatureID)`

System: `DamageMeter` · Namespace: `C_DamageMeter`
