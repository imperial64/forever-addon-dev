<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# UnitChannelInfoResult

_Structure_

**Fields**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `name` | `cstring` | no |  |
| 2 | `displayName` | `cstring` | no |  |
| 3 | `textureID` | `fileID` | no |  |
| 4 | `startTimeMs` | `number` | no |  |
| 5 | `endTimeMs` | `number` | no |  |
| 6 | `isTradeskill` | `bool` | no |  |
| 7 | `notInterruptible` | `bool` | yes |  |
| 8 | `spellID` | `number` | no |  |
| 9 | `isEmpowered` | `bool` | no |  |
| 10 | `numEmpowerStages` | `number` | no |  |
| 11 | `castBarID` | `UnitCastBarID` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| field `isTradeskill` | `NeverSecret` | `true` |
| field `isEmpowered` | `NeverSecret` | `true` |
| field `numEmpowerStages` | `NeverSecret` | `true` |
| field `castBarID` | `NeverSecret` | `true` |

System: `Unit`
