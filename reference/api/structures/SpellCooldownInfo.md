<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# SpellCooldownInfo

_Structure_

**Fields**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `startTime` | `number` | no |  |
| 2 | `duration` | `number` | no |  |
| 3 | `isEnabled` | `bool` | no |  |
| 4 | `isActive` | `bool` | no |  |
| 5 | `modRate` | `number` | no |  |
| 6 | `activeCategory` | `number` | yes |  |
| 7 | `timeUntilEndOfStartRecovery` | `number` | yes |  |
| 8 | `isOnGCD` | `bool` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| field `isEnabled` | `NeverSecret` | `true` |
| field `isActive` | `NeverSecret` | `true` |
| field `isOnGCD` | `NeverSecret` | `true` |

System: none (a shared table, filed in `APIDocumentation.tables`)
