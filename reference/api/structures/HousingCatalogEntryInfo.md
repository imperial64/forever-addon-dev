<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# HousingCatalogEntryInfo

_Structure_

**Fields**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `recordID` | `number` | no |  |
| 2 | `entryType` | `HousingCatalogEntryType` | no |  |
| 3 | `itemID` | `number` | yes |  |
| 4 | `name` | `cstring` | no |  |
| 5 | `asset` | `ModelAsset` | yes |  |
| 6 | `iconTexture` | `FileAsset` | yes |  |
| 7 | `iconAtlas` | `textureAtlas` | yes |  |
| 8 | `uiModelSceneID` | `number` | yes |  |
| 9 | `categoryIDs` | `table&lt;number&gt;` | no |  |
| 10 | `subcategoryIDs` | `table&lt;number&gt;` | no |  |
| 11 | `dataTagsByID` | `LuaValueVariant` | no |  |
| 12 | `size` | `HousingCatalogEntrySize` | no |  |
| 13 | `placementCost` | `number` | no |  |
| 14 | `totalNumStored` | `number` | no |  |
| 15 | `remainingRedeemable` | `number` | no |  |
| 16 | `totalNumPlaced` | `number` | no |  |
| 17 | `destroyableInstanceCount` | `number` | no |  |
| 18 | `isUniqueTrophy` | `bool` | no |  |
| 19 | `isAllowedOutdoors` | `bool` | no |  |
| 20 | `isAllowedIndoors` | `bool` | no |  |
| 21 | `canCustomize` | `bool` | no |  |
| 22 | `isPrefab` | `bool` | no |  |
| 23 | `quality` | `ItemQuality` | yes |  |
| 24 | `firstAcquisitionBonus` | `number` | no |  |
| 25 | `sourceText` | `cstring` | no |  |

System: `HousingCatalogUI`
