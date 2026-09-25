<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_UnitAuras.GetUnitAuraInstanceIDs

> **SECRET — measured, in combat only.** Aura reads RAISE in combat. They do not return nil.
> Measured 2026-09-20 on build 69913. Evidence: §P.18, §P.19 in [findings](../../../../research/findings.md).
> 
> _Workaround:_ Read before the pull and hold the value, or hand a duration object to a Cooldown widget before combat starts and let it keep ticking.

```lua
auraInstanceIDs = C_UnitAuras.GetUnitAuraInstanceIDs(unit, filter, maxCount, sortRule, sortDirection)
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
| 1 | `auraInstanceIDs` | `table&lt;number&gt;` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `RequiresUnitAuraAccess` | `true` |
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| argument `unit` | `NeverSecret` | `true` |

Blizzard's own rendering: `C_UnitAuras.GetUnitAuraInstanceIDs(unit, filter, optional maxCount, optional sortRule, optional sortDirection)`

System: `UnitAuras` · Namespace: `C_UnitAuras`
