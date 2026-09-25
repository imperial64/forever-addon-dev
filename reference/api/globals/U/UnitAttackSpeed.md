<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# UnitAttackSpeed

```lua
attackSpeed, offhandAttackSpeed, rangedAttackSpeed = UnitAttackSpeed(unit)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unit` | `UnitToken` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `attackSpeed` | `number` | no |  |
| 2 | `offhandAttackSpeed` | `number` | yes |  |
| 3 | `rangedAttackSpeed` | `number` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretWhenUnitStatsRestricted` | `true` |

Blizzard's own rendering: `UnitAttackSpeed(unit)`

System: `Unit`
