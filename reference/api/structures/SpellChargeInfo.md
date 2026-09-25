<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# SpellChargeInfo

_Structure_

**Fields**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `currentCharges` | `number` | no |  |
| 2 | `maxCharges` | `number` | no |  |
| 3 | `cooldownStartTime` | `number` | no |  |
| 4 | `cooldownDuration` | `number` | no |  |
| 5 | `chargeModRate` | `number` | no |  |
| 6 | `isActive` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| field `maxCharges` | `NeverSecret` | `true` |
| field `isActive` | `NeverSecret` | `true` |

System: none (a shared table, filed in `APIDocumentation.tables`)
