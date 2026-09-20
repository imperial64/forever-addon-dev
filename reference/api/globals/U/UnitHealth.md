<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# UnitHealth

> **SECRET — measured, at all times.** Unit health is secret at ALL times, including out of combat.
> Measured 2026-09-20 on build 69913. Evidence: §P.25, §P.28 in [findings](../../../../research/findings.md).
> 
> _Workaround:_ None for the number. The player's own UnitHealthMax is readable, so a denominator is available while the numerator is not; for any other unit neither is. Hand values to Blizzard's own widgets rather than reading them.

```lua
result = UnitHealth(unit, usePredicted)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unit` | `UnitTokenPvPRestrictedForAddOns` | no |  |
| 2 | `usePredicted` | `bool` | no | `True` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `result` | `number` | no |  |

Blizzard's own rendering: `UnitHealth(unit, optional usePredicted)`

System: `Unit`
