<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# ClubInfo

_Structure_

**Fields**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `clubId` | `ClubId` | no |  |
| 2 | `name` | `string` | no |  |
| 3 | `shortName` | `string` | yes |  |
| 4 | `description` | `string` | no |  |
| 5 | `broadcast` | `string` | no |  |
| 6 | `clubType` | `ClubType` | no |  |
| 7 | `avatarId` | `number` | no |  |
| 8 | `memberCount` | `number` | yes |  |
| 9 | `favoriteTimeStamp` | `BigUInteger` | yes |  |
| 10 | `joinTime` | `BigUInteger` | yes |  |
| 11 | `socialQueueingEnabled` | `bool` | yes |  |
| 12 | `crossFaction` | `bool` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| field `clubId` | `NeverSecret` | `true` |
| field `clubType` | `NeverSecret` | `true` |
| field `memberCount` | `NeverSecret` | `true` |

System: `Club`
