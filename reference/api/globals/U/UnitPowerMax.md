<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# UnitPowerMax

> **SECRET — measured, at all times.** Another unit's max health and max power are secret at ALL times; the player's own are never secret.
> Measured 2026-09-20 on build 69913. Evidence: §P.25, §P.28 in [findings](../../../../research/findings.md).

```lua
maxPower = UnitPowerMax(unitToken, powerType, unmodified)
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
| 1 | `maxPower` | `number` | no |  |

Blizzard's own rendering: `UnitPowerMax(unitToken, optional powerType, optional unmodified)`

System: `Unit`
