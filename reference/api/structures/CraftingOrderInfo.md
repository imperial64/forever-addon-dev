<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# CraftingOrderInfo

_Structure_

**Fields**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `orderID` | `BigUInteger` | no |  |
| 2 | `itemID` | `number` | no |  |
| 3 | `spellID` | `number` | no |  |
| 4 | `skillLineAbilityID` | `number` | no |  |
| 5 | `orderType` | `CraftingOrderType` | no |  |
| 6 | `orderState` | `CraftingOrderState` | no |  |
| 7 | `expirationTime` | `time_t` | no |  |
| 8 | `claimEndTime` | `time_t` | no |  |
| 9 | `minQuality` | `number` | no |  |
| 10 | `tipAmount` | `WOWMONEY` | no |  |
| 11 | `consortiumCut` | `WOWMONEY` | no |  |
| 12 | `isRecraft` | `bool` | no |  |
| 13 | `isFulfillable` | `bool` | no |  |
| 14 | `reagentState` | `CraftingOrderReagentsType` | no |  |
| 15 | `customerGuid` | `WOWGUID` | yes |  |
| 16 | `customerName` | `string` | yes |  |
| 17 | `crafterGuid` | `WOWGUID` | yes |  |
| 18 | `crafterName` | `string` | yes |  |
| 19 | `npcCustomerCreatureID` | `number` | yes |  |
| 20 | `customerNotes` | `string` | no |  |
| 21 | `reagents` | `table&lt;CraftingOrderReagentInfo&gt;` | no |  |
| 22 | `outputItemHyperlink` | `string` | yes |  |
| 23 | `outputItemGUID` | `WOWGUID` | yes |  |
| 24 | `recraftItemHyperlink` | `string` | yes |  |
| 25 | `npcOrderRewards` | `table&lt;CraftingOrderRewardInfo&gt;` | no |  |
| 26 | `npcCraftingOrderSetID` | `number` | no |  |
| 27 | `npcTreasureID` | `number` | no |  |

System: none (a shared table, filed in `APIDocumentation.tables`)
