<!-- GENERATED from Blizzard_APIDocumentation, client build unknown. Do not edit; edit the generator. -->

# C_UnitAuras.GetAuraSlots

```lua
outContinuationToken, slots = C_UnitAuras.GetAuraSlots(unit, filter, maxSlots, continuationToken)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unit` | `UnitTokenRestrictedForAddOns` | no |  |
| 2 | `filter` | `AuraFilters` | yes |  |
| 3 | `maxSlots` | `number` | yes |  |
| 4 | `continuationToken` | `number` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `outContinuationToken` | `number` | yes |  |
| 2 | `slots` | `number` | no |  |

Blizzard's own rendering: `C_UnitAuras.GetAuraSlots(unit, optional filter, optional maxSlots, optional continuationToken)`

System: `UnitAuras` · Namespace: `C_UnitAuras`
