<!-- GENERATED from Blizzard_APIDocumentation, client build unknown. Do not edit; edit the generator. -->

# UnitPower

> **SECRET — measured, at all times.** Unit power is secret at ALL times, including out of combat.
> Measured 2026-09-18 on build 69913. Evidence: §P.3, §P.10, §P.18 in [findings](../../../../docs/findings.md).

```lua
power = UnitPower(unitToken, powerType, unmodified)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unitToken` | `UnitTokenPvPRestrictedForAddOns` | no |  |
| 2 | `powerType` | `PowerType` | yes |  |
| 3 | `unmodified` | `bool` | no | `False` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `power` | `number` | no |  |

Blizzard's own rendering: `UnitPower(unitToken, optional powerType, optional unmodified)`

System: `Unit`
