<!-- GENERATED from Blizzard_APIDocumentation, client build unknown. Do not edit; edit the generator. -->

# C_UnitAuras.GetUnitAuras

```lua
auras = C_UnitAuras.GetUnitAuras(unit, filter, maxCount, sortRule, sortDirection)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unit` | `UnitTokenRestrictedForAddOns` | no |  |
| 2 | `filter` | `AuraFilters` | no |  |
| 3 | `maxCount` | `number` | yes |  |
| 4 | `sortRule` | `UnitAuraSortRule` | no | `Unsorted` |
| 5 | `sortDirection` | `UnitAuraSortDirection` | no | `Normal` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `auras` | `table&lt;AuraData&gt;` | no |  |

Blizzard's own rendering: `C_UnitAuras.GetUnitAuras(unit, filter, optional maxCount, optional sortRule, optional sortDirection)`

System: `UnitAuras` · Namespace: `C_UnitAuras`
