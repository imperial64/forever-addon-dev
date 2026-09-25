<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# DamageMeterCombatSpellUnitDetails

_Structure_

**Fields**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unitName` | `cstring` | no |  |
| 2 | `unitClassFilename` | `cstring` | no |  |
| 3 | `classification` | `cstring` | no |  |
| 4 | `isPet` | `bool` | no |  |
| 5 | `isMob` | `bool` | no |  |
| 6 | `amount` | `number` | no |  |
| 7 | `specIconID` | `fileID` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| field `unitClassFilename` | `NeverSecret` | `true` |
| field `classification` | `NeverSecret` | `true` |
| field `specIconID` | `NeverSecret` | `true` |

System: `DamageMeter`
