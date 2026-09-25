<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# LfgApplicantData

_Structure_

**Fields**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `applicantID` | `number` | no |  |
| 2 | `applicationStatus` | `cstring` | no |  |
| 3 | `pendingApplicationStatus` | `cstring` | yes |  |
| 4 | `numMembers` | `number` | no |  |
| 5 | `isNew` | `bool` | no |  |
| 6 | `comment` | `kstringLfgListApplicant` | no |  |
| 7 | `displayOrderID` | `number` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| field `applicationStatus` | `NeverSecret` | `true` |
| field `pendingApplicationStatus` | `NeverSecret` | `true` |
| field `numMembers` | `NeverSecret` | `true` |

System: `LFGList`
