<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# NewCraftingOrderInfo

_Structure_

**Fields**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `skillLineAbilityID` | `number` | no |  |
| 2 | `orderType` | `CraftingOrderType` | no |  |
| 3 | `orderDuration` | `CraftingOrderDuration` | no |  |
| 4 | `tipAmount` | `WOWMONEY` | no |  |
| 5 | `customerNotes` | `string` | no |  |
| 6 | `reagentInfos` | `table&lt;RegularReagentInfo&gt;` | no |  |
| 7 | `craftingReagentItems` | `table&lt;CraftingReagentInfo&gt;` | no |  |
| 8 | `minCraftingQualityID` | `number` | yes |  |
| 9 | `orderTarget` | `string` | yes |  |
| 10 | `recraftItem` | `WOWGUID` | yes |  |

System: none (a shared table, filed in `APIDocumentation.tables`)
