<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# ClubStreamInfo

_Structure_

**Fields**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `streamId` | `ClubStreamId` | no |  |
| 2 | `name` | `string` | no |  |
| 3 | `subject` | `string` | no |  |
| 4 | `leadersAndModeratorsOnly` | `bool` | no |  |
| 5 | `streamType` | `ClubStreamType` | no |  |
| 6 | `creationTime` | `BigUInteger` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| field `streamType` | `NeverSecret` | `true` |

System: `Club`
