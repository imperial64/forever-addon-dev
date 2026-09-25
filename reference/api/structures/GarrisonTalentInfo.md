<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# GarrisonTalentInfo

_Structure_

**Fields**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `id` | `number` | no |  |
| 2 | `ability` | `GarrisonFollowerAbilityInfo` | no |  |
| 3 | `name` | `string` | no |  |
| 4 | `icon` | `number` | no |  |
| 5 | `tier` | `number` | no |  |
| 6 | `uiOrder` | `number` | no |  |
| 7 | `type` | `number` | no |  |
| 8 | `prerequisiteTalentID` | `number` | yes |  |
| 9 | `selected` | `bool` | no |  |
| 10 | `researched` | `bool` | no |  |
| 11 | `ignoreTalent` | `bool` | no |  |
| 12 | `researchDuration` | `time_t` | no |  |
| 13 | `startTime` | `time_t` | no |  |
| 14 | `timeRemaining` | `time_t` | no |  |
| 15 | `researchGoldCost` | `number` | no |  |
| 16 | `researchCurrencyCosts` | `table&lt;GarrisonTalentCurrencyCostInfo&gt;` | no |  |
| 17 | `talentAvailability` | `GarrisonTalentAvailability` | no |  |
| 18 | `talentRank` | `number` | no |  |
| 19 | `talentMaxRank` | `number` | no |  |
| 20 | `isBeingResearched` | `bool` | no |  |
| 21 | `description` | `string` | no |  |
| 22 | `perkSpellID` | `number` | no |  |
| 23 | `researchDescription` | `string` | yes |  |
| 24 | `playerConditionReason` | `string` | yes |  |
| 25 | `socketInfo` | `GarrisonTalentSocketInfo` | no |  |
| 26 | `treeID` | `number` | no |  |

System: none (a shared table, filed in `APIDocumentation.tables`)
