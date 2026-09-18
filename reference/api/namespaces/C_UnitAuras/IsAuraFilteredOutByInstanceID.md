<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# C_UnitAuras.IsAuraFilteredOutByInstanceID

> **SECRET — measured, in combat only.** Aura reads RAISE in combat. They do not return nil.
> Measured 2026-09-18 on build 69913. Evidence: §P.18, §P.19 in [findings](../../../../research/findings.md).
> 
> _Workaround:_ Read before the pull and hold the value, or hand a duration object to a Cooldown widget before combat starts and let it keep ticking.

```lua
isFiltered = C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, auraInstanceID, filter)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unit` | `UnitTokenRestrictedForAddOns` | no |  |
| 2 | `auraInstanceID` | `number` | no |  |
| 3 | `filter` | `AuraFilters` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `isFiltered` | `bool` | no |  |

Blizzard's own rendering: `C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, auraInstanceID, filter)`

System: `UnitAuras` · Namespace: `C_UnitAuras`
