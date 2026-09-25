<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# UnitResistance

```lua
baseResistance, realResistance, effectiveResistance, bonusResistance = UnitResistance(unit, damageClass)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unit` | `UnitToken` | no |  |
| 2 | `damageClass` | `Damageclass` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `baseResistance` | `number` | no |  |
| 2 | `realResistance` | `number` | no |  |
| 3 | `effectiveResistance` | `number` | no |  |
| 4 | `bonusResistance` | `number` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretWhenUnitIdentityRestricted` | `true` |

Blizzard's own rendering: `UnitResistance(unit, damageClass)`

System: `Unit`
