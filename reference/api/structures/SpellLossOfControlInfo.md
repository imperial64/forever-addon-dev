<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# SpellLossOfControlInfo

_Structure_

**Fields**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `startTime` | `number` | no |  |
| 2 | `duration` | `number` | no |  |
| 3 | `modRate` | `number` | no |  |
| 4 | `isActive` | `bool` | no |  |
| 5 | `shouldReplaceNormalCooldown` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| field `isActive` | `NeverSecret` | `true` |
| field `shouldReplaceNormalCooldown` | `NeverSecret` | `true` |

System: none (a shared table, filed in `APIDocumentation.tables`)
