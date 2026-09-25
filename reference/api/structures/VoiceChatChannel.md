<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# VoiceChatChannel

_Structure_

**Fields**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `name` | `string` | no |  |
| 2 | `channelID` | `number` | no |  |
| 3 | `channelType` | `ChatChannelType` | no |  |
| 4 | `clubId` | `ClubId` | no |  |
| 5 | `streamId` | `ClubStreamId` | no |  |
| 6 | `volume` | `number` | no |  |
| 7 | `isActive` | `bool` | no |  |
| 8 | `isMuted` | `bool` | no |  |
| 9 | `isTransmitting` | `bool` | no |  |
| 10 | `isTranscribing` | `bool` | no |  |
| 11 | `members` | `table&lt;VoiceChatMember&gt;` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| field `channelID` | `NeverSecret` | `true` |
| field `channelType` | `NeverSecret` | `true` |
| field `clubId` | `NeverSecret` | `true` |
| field `streamId` | `NeverSecret` | `true` |
| field `volume` | `NeverSecret` | `true` |
| field `isActive` | `NeverSecret` | `true` |
| field `isMuted` | `NeverSecret` | `true` |
| field `isTransmitting` | `NeverSecret` | `true` |
| field `isTranscribing` | `NeverSecret` | `true` |

System: `VoiceChat`
