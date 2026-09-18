<!-- GENERATED from Blizzard_APIDocumentation, client build unknown. Do not edit; edit the generator. -->

# C_UnitAuras.GetUnitAuras

> **SECRET — measured, in combat only.** Aura reads RAISE in combat. They do not return nil.
> Measured 2026-09-18 on build 69913. Evidence: §P.18, §P.19 in [findings](../../../../docs/findings.md).
> 
> _Workaround:_ Read before the pull and hold the value, or hand a duration object to a Cooldown widget before combat starts and let it keep ticking.

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
