<!-- GENERATED from Blizzard_APIDocumentation, client build unknown. Do not edit; edit the generator. -->

# C_UnitAuras.GetAuraApplicationDisplayCount

> **SECRET — measured, in combat only.** Aura reads RAISE in combat. They do not return nil.
> Measured 2026-09-18 on build 69913. Evidence: §P.18, §P.19 in [findings](../../../../docs/findings.md).
> 
> _Workaround:_ Read before the pull and hold the value, or hand a duration object to a Cooldown widget before combat starts and let it keep ticking.

```lua
count = C_UnitAuras.GetAuraApplicationDisplayCount(auraInstanceUnit, auraInstanceID, minDisplayCount, maxDisplayCount)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `auraInstanceUnit` | `UnitToken` | no |  |
| 2 | `auraInstanceID` | `number` | no |  |
| 3 | `minDisplayCount` | `number` | no | `2` |
| 4 | `maxDisplayCount` | `number` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `count` | `string` | no |  |

Blizzard's own rendering: `C_UnitAuras.GetAuraApplicationDisplayCount(auraInstanceUnit, auraInstanceID, optional minDisplayCount, optional maxDisplayCount)`

System: `UnitAuras` · Namespace: `C_UnitAuras`
