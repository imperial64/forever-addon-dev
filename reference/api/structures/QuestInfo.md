<!-- GENERATED from Blizzard_APIDocumentation, client build unknown. Do not edit; edit the generator. -->

# QuestInfo

_Structure_

**Fields**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `title` | `string` | no |  |
| 2 | `questLogIndex` | `luaIndex` | no |  |
| 3 | `questID` | `number` | no |  |
| 4 | `campaignID` | `number` | yes |  |
| 5 | `level` | `number` | no |  |
| 6 | `difficultyLevel` | `number` | no |  |
| 7 | `suggestedGroup` | `number` | no |  |
| 8 | `frequency` | `QuestFrequency` | yes |  |
| 9 | `isHeader` | `bool` | no |  |
| 10 | `useMinimalHeader` | `bool` | no |  |
| 11 | `sortAsNormalQuest` | `bool` | no |  |
| 12 | `isCollapsed` | `bool` | no |  |
| 13 | `startEvent` | `bool` | no |  |
| 14 | `isTask` | `bool` | no |  |
| 15 | `isBounty` | `bool` | no |  |
| 16 | `isStory` | `bool` | no |  |
| 17 | `isScaling` | `bool` | no |  |
| 18 | `isOnMap` | `bool` | no |  |
| 19 | `hasLocalPOI` | `bool` | no |  |
| 20 | `isHidden` | `bool` | no |  |
| 21 | `isAutoComplete` | `bool` | no |  |
| 22 | `overridesSortOrder` | `bool` | no |  |
| 23 | `readyForTranslation` | `bool` | no | `True` |
| 24 | `isInternalOnly` | `bool` | no |  |
| 25 | `isAbandonOnDisable` | `bool` | no |  |
| 26 | `headerSortKey` | `number` | yes |  |
| 27 | `questClassification` | `QuestClassification` | no |  |

System: `QuestLog`
