<!-- GENERATED from Blizzard_APIDocumentation, client build unknown. Do not edit; edit the generator. -->

# TraitNodeInfo

_Structure_

**Fields**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `ID` | `number` | no |  |
| 2 | `posX` | `number` | no |  |
| 3 | `posY` | `number` | no |  |
| 4 | `flags` | `number` | no |  |
| 5 | `entryIDs` | `table&lt;number&gt;` | no |  |
| 6 | `entryIDsWithCommittedRanks` | `table&lt;number&gt;` | no |  |
| 7 | `canPurchaseRank` | `bool` | no |  |
| 8 | `canRefundRank` | `bool` | no |  |
| 9 | `isAvailable` | `bool` | no |  |
| 10 | `isVisible` | `bool` | no |  |
| 11 | `isDisplayError` | `bool` | no |  |
| 12 | `ranksPurchased` | `number` | no |  |
| 13 | `ranksIncreased` | `number` | no |  |
| 14 | `entryIDToRanksIncreased` | `LuaValueVariant` | no |  |
| 15 | `activeRank` | `number` | no |  |
| 16 | `currentRank` | `number` | no |  |
| 17 | `activeEntry` | `TraitEntryRankInfo` | yes |  |
| 18 | `nextEntry` | `TraitEntryRankInfo` | yes |  |
| 19 | `maxRanks` | `number` | no |  |
| 20 | `totalMaxRanks` | `number` | no |  |
| 21 | `type` | `TraitNodeType` | no |  |
| 22 | `visibleEdges` | `table&lt;TraitOutEdgeInfo&gt;` | no |  |
| 23 | `meetsEdgeRequirements` | `bool` | no |  |
| 24 | `groupIDs` | `table&lt;number&gt;` | no |  |
| 25 | `conditionIDs` | `table&lt;number&gt;` | no |  |
| 26 | `isCascadeRepurchasable` | `bool` | no |  |
| 27 | `cascadeRepurchaseEntryID` | `number` | yes |  |
| 28 | `subTreeID` | `number` | yes |  |
| 29 | `subTreeActive` | `bool` | yes |  |

System: `SharedTraits`
