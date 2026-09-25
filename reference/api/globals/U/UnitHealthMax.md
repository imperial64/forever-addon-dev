<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# UnitHealthMax

> **SECRET — measured, at all times.** Another unit's max health and max power are secret at ALL times; the player's own are never secret.
> Measured 2026-09-20 on build 69913. Evidence: §P.25, §P.28 in [findings](../../../../research/findings.md).

```lua
result = UnitHealthMax(unit)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unit` | `UnitTokenPvPRestrictedForAddOns` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `result` | `number` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretWhenUnitHealthMaxRestricted` | `true` |

Blizzard's own rendering: `UnitHealthMax(unit)`

System: `Unit`
