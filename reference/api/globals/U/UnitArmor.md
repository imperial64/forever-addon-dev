<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# UnitArmor

```lua
base, effective, real, bonus = UnitArmor(unit)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unit` | `UnitToken` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `base` | `number` | no |  |
| 2 | `effective` | `number` | no |  |
| 3 | `real` | `number` | no |  |
| 4 | `bonus` | `number` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretWhenUnitStatsRestricted` | `true` |

Blizzard's own rendering: `UnitArmor(unit)`

System: `Unit`
