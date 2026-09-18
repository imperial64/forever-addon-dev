<!-- GENERATED from Blizzard_APIDocumentation, client build unknown. Do not edit; edit the generator. -->

# C_UnitAuras.SwitchAuraDataProvider

> **SECRET — measured, in combat only.** Aura reads RAISE in combat. They do not return nil.
> Measured 2026-09-18 on build 69913. Evidence: §P.18, §P.19 in [findings](../../../../docs/findings.md).
> 
> _Workaround:_ Read before the pull and hold the value, or hand a duration object to a Cooldown widget before combat starts and let it keep ticking.

```lua
C_UnitAuras.SwitchAuraDataProvider()
```

**Arguments**

_None._

**Returns**

_None._

Blizzard's own rendering: `C_UnitAuras.SwitchAuraDataProvider()`

System: `UnitAuras` · Namespace: `C_UnitAuras`
