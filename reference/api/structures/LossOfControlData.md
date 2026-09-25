<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# LossOfControlData

_Structure_

**Fields**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `locType` | `cstring` | no |  |
| 2 | `spellID` | `number` | no |  |
| 3 | `displayText` | `cstring` | no |  |
| 4 | `iconTexture` | `number` | no |  |
| 5 | `startTime` | `number` | yes |  |
| 6 | `timeRemaining` | `number` | yes |  |
| 7 | `duration` | `number` | yes |  |
| 8 | `lockoutSchool` | `number` | no |  |
| 9 | `priority` | `number` | no |  |
| 10 | `displayType` | `number` | no |  |
| 11 | `auraInstanceID` | `number` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| field `priority` | `NeverSecret` | `true` |
| field `displayType` | `NeverSecret` | `true` |

System: `LossOfControl`
