<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# CraftingReagentSlotSchematic

_Structure_

**Fields**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `reagents` | `table&lt;CraftingReagent&gt;` | no |  |
| 2 | `reagentType` | `CraftingReagentType` | no |  |
| 3 | `variableQuantities` | `table&lt;CraftingVariableQuantities&gt;` | no |  |
| 4 | `quantityRequired` | `number` | no |  |
| 5 | `slotInfo` | `CraftingReagentSlotInfo` | yes |  |
| 6 | `dataSlotType` | `TradeskillSlotDataType` | no | `Reagent` |
| 7 | `dataSlotIndex` | `luaIndex` | no |  |
| 8 | `slotIndex` | `luaIndex` | no |  |
| 9 | `orderSource` | `CraftingOrderReagentSource` | yes |  |
| 10 | `required` | `bool` | no |  |
| 11 | `hiddenInCraftingForm` | `bool` | no |  |

System: none (a shared table, filed in `APIDocumentation.tables`)
