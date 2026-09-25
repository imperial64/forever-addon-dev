<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# LfgEntryData

_Structure_

**Fields**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `activityIDs` | `table&lt;number&gt;` | no |  |
| 2 | `requiredItemLevel` | `number` | no |  |
| 3 | `requiredHonorLevel` | `number` | no |  |
| 4 | `name` | `kstringLfgListApplicant` | no |  |
| 5 | `comment` | `kstringLfgListApplicant` | no |  |
| 6 | `voiceChat` | `kstringLfgListApplicant` | no |  |
| 7 | `censored` | `bool` | no |  |
| 8 | `duration` | `time_t` | no |  |
| 9 | `autoAccept` | `bool` | no |  |
| 10 | `privateGroup` | `bool` | no |  |
| 11 | `questID` | `number` | yes |  |
| 12 | `requiredDungeonScore` | `number` | yes |  |
| 13 | `requiredPvpRating` | `number` | yes |  |
| 14 | `playstyle` | `LFGEntryPlaystyle` | yes |  |
| 15 | `generalPlaystyle` | `LFGEntryGeneralPlaystyle` | yes |  |
| 16 | `isCrossFactionListing` | `bool` | no |  |
| 17 | `newPlayerFriendly` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| field `activityIDs` | `NeverSecret` | `true` |

System: `LFGList`
