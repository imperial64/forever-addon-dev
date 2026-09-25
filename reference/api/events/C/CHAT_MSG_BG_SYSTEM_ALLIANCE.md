<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# CHAT_MSG_BG_SYSTEM_ALLIANCE

**Payload**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `text` | `cstring` | no |  |
| 2 | `playerName` | `cstring` | no |  |
| 3 | `languageName` | `cstring` | no |  |
| 4 | `channelName` | `cstring` | no |  |
| 5 | `playerName2` | `cstring` | no |  |
| 6 | `specialFlags` | `cstring` | no |  |
| 7 | `zoneChannelID` | `number` | no |  |
| 8 | `channelIndex` | `number` | no |  |
| 9 | `channelBaseName` | `cstring` | no |  |
| 10 | `languageID` | `number` | no |  |
| 11 | `lineID` | `number` | no |  |
| 12 | `guid` | `WOWGUID` | no |  |
| 13 | `bnSenderID` | `number` | no |  |
| 14 | `isMobile` | `bool` | no |  |
| 15 | `isSubtitle` | `bool` | no |  |
| 16 | `hideSenderInLetterbox` | `bool` | no |  |
| 17 | `suppressRaidIcons` | `bool` | no |  |
| 18 | `discordInfo` | `DiscordChatInfo` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| payload `languageName` | `NeverSecret` | `true` |
| payload `channelName` | `NeverSecret` | `true` |
| payload `specialFlags` | `NeverSecret` | `true` |
| payload `zoneChannelID` | `NeverSecret` | `true` |
| payload `channelIndex` | `NeverSecret` | `true` |
| payload `channelBaseName` | `NeverSecret` | `true` |
| payload `languageID` | `NeverSecret` | `true` |
| payload `lineID` | `NeverSecret` | `true` |
| payload `isMobile` | `NeverSecret` | `true` |
| payload `isSubtitle` | `NeverSecret` | `true` |
| payload `hideSenderInLetterbox` | `NeverSecret` | `true` |
| payload `suppressRaidIcons` | `NeverSecret` | `true` |

System: `ChatInfo`
