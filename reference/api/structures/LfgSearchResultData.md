<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# LfgSearchResultData

_Structure_

**Fields**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `searchResultID` | `number` | no |  |
| 2 | `activityIDs` | `table&lt;number&gt;` | no |  |
| 3 | `leaderName` | `string` | yes |  |
| 4 | `name` | `kstringLfgListSearch` | no |  |
| 5 | `comment` | `kstringLfgListSearch` | no |  |
| 6 | `voiceChat` | `kstringLfgListSearch` | no |  |
| 7 | `censored` | `bool` | no |  |
| 8 | `requiredItemLevel` | `number` | no |  |
| 9 | `requiredHonorLevel` | `number` | no |  |
| 10 | `hasSelf` | `bool` | no |  |
| 11 | `numMembers` | `number` | no |  |
| 12 | `numBNetFriends` | `number` | no |  |
| 13 | `numCharFriends` | `number` | no |  |
| 14 | `numGuildMates` | `number` | no |  |
| 15 | `isDelisted` | `bool` | no |  |
| 16 | `autoAccept` | `bool` | no |  |
| 17 | `isWarMode` | `bool` | no |  |
| 18 | `age` | `time_t` | no |  |
| 19 | `questID` | `number` | yes |  |
| 20 | `leaderOverallDungeonScore` | `number` | yes |  |
| 21 | `leaderDungeonScoreInfo` | `table&lt;BestDungeonScoreMapInfo&gt;` | no |  |
| 22 | `leaderBestDungeonScoreInfo` | `BestDungeonScoreMapInfo` | yes |  |
| 23 | `leaderPvpRatingInfo` | `table&lt;PvpRatingInfo&gt;` | no |  |
| 24 | `requiredDungeonScore` | `number` | yes |  |
| 25 | `requiredPvpRating` | `number` | yes |  |
| 26 | `playstyle` | `LFGEntryPlaystyle` | yes |  |
| 27 | `generalPlaystyle` | `LFGEntryGeneralPlaystyle` | yes |  |
| 28 | `crossFactionListing` | `bool` | yes |  |
| 29 | `leaderFactionGroup` | `number` | no |  |
| 30 | `newPlayerFriendly` | `bool` | yes |  |
| 31 | `partyGUID` | `WOWGUID` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| field `partyGUID` | `NeverSecret` | `true` |

System: `LFGList`
