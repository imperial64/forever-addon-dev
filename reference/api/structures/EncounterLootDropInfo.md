<!-- GENERATED from Blizzard_APIDocumentation, client build unknown. Do not edit; edit the generator. -->

# EncounterLootDropInfo

_Structure_

**Fields**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `lootListKey` | `number` | no |  |
| 2 | `itemHyperlink` | `string` | no |  |
| 3 | `playerRollState` | `EncounterLootDropRollState` | no |  |
| 4 | `currentLeader` | `EncounterLootDropRollInfo` | yes |  |
| 5 | `isTied` | `bool` | no | `False` |
| 6 | `winner` | `EncounterLootDropRollInfo` | yes |  |
| 7 | `allPassed` | `bool` | no | `False` |
| 8 | `rollInfos` | `table&lt;EncounterLootDropRollInfo&gt;` | no |  |
| 9 | `startTime` | `number` | no |  |
| 10 | `duration` | `number` | no |  |

System: `LootHistory`
