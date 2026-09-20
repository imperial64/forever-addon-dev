<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# C_UnitAuras.GetAuraDispelTypeColor

> **SECRET — measured, in combat only.** Aura reads RAISE in combat. They do not return nil.
> Measured 2026-09-20 on build 69913. Evidence: §P.18, §P.19 in [findings](../../../../research/findings.md).
> 
> _Workaround:_ Read before the pull and hold the value, or hand a duration object to a Cooldown widget before combat starts and let it keep ticking.

```lua
dispelTypeColor = C_UnitAuras.GetAuraDispelTypeColor(auraInstanceUnit, auraInstanceID, curve)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `auraInstanceUnit` | `UnitToken` | no |  |
| 2 | `auraInstanceID` | `number` | no |  |
| 3 | `curve` | `LuaColorCurveObject` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `dispelTypeColor` | `colorRGBA (ColorMixin)` | no |  |

Blizzard's own rendering: `C_UnitAuras.GetAuraDispelTypeColor(auraInstanceUnit, auraInstanceID, curve)`

System: `UnitAuras` · Namespace: `C_UnitAuras`
