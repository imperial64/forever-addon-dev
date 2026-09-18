<!-- GENERATED from Blizzard_APIDocumentation, client build unknown. Do not edit; edit the generator. -->

# C_UnitAuras.GetBuffDataByIndex

> **SECRET — measured, in combat only.** Aura reads RAISE in combat. They do not return nil.
> Measured 2026-09-18 on build 69913. Evidence: §P.18, §P.19 in [findings](../../../../docs/findings.md).
> 
> _Workaround:_ Read before the pull and hold the value, or hand a duration object to a Cooldown widget before combat starts and let it keep ticking.

```lua
aura = C_UnitAuras.GetBuffDataByIndex(unit, index, filter)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unit` | `UnitTokenRestrictedForAddOns` | no |  |
| 2 | `index` | `luaIndex` | no |  |
| 3 | `filter` | `AuraFilters` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `aura` | `AuraData` | yes |  |

Blizzard's own rendering: `C_UnitAuras.GetBuffDataByIndex(unit, index, optional filter)`

System: `UnitAuras` · Namespace: `C_UnitAuras`
