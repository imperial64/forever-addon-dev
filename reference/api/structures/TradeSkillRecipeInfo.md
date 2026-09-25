<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# TradeSkillRecipeInfo

_Structure_

**Fields**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `categoryID` | `number` | no |  |
| 2 | `name` | `cstring` | no |  |
| 3 | `relativeDifficulty` | `TradeskillRelativeDifficulty` | yes |  |
| 4 | `maxTrivialLevel` | `number` | no |  |
| 5 | `itemLevel` | `number` | no |  |
| 6 | `alternateVerb` | `cstring` | yes |  |
| 7 | `numSkillUps` | `number` | no |  |
| 8 | `canSkillUp` | `bool` | no |  |
| 9 | `firstCraft` | `bool` | no |  |
| 10 | `sourceType` | `number` | yes |  |
| 11 | `learned` | `bool` | no |  |
| 12 | `disabled` | `bool` | no |  |
| 13 | `favorite` | `bool` | no |  |
| 14 | `supportsQualities` | `bool` | no |  |
| 15 | `craftable` | `bool` | no | `True` |
| 16 | `disabledReason` | `cstring` | yes |  |
| 17 | `recipeID` | `number` | no |  |
| 18 | `skillLineAbilityID` | `number` | no |  |
| 19 | `previousRecipeID` | `number` | yes |  |
| 20 | `nextRecipeID` | `number` | yes |  |
| 21 | `icon` | `number` | yes |  |
| 22 | `hyperlink` | `cstring` | yes |  |
| 23 | `currentRecipeExperience` | `number` | yes |  |
| 24 | `nextLevelRecipeExperience` | `number` | yes |  |
| 25 | `unlockedRecipeLevel` | `number` | yes |  |
| 26 | `earnedExperience` | `number` | yes |  |
| 27 | `supportsCraftingStats` | `bool` | no | `False` |
| 28 | `hasSingleItemOutput` | `bool` | no | `False` |
| 29 | `qualityItemIDs` | `table&lt;number&gt;` | yes |  |
| 30 | `qualityIlvlBonuses` | `table&lt;number&gt;` | yes |  |
| 31 | `alwaysUsesLowestQuality` | `bool` | no | `False` |
| 32 | `maxQuality` | `number` | yes |  |
| 33 | `qualityIDs` | `table&lt;number&gt;` | yes |  |
| 34 | `canCreateMultiple` | `bool` | no | `True` |
| 35 | `abilityVerb` | `cstring` | yes |  |
| 36 | `abilityAllVerb` | `cstring` | yes |  |
| 37 | `isRecraft` | `bool` | no | `False` |
| 38 | `isDummyRecipe` | `bool` | no | `False` |
| 39 | `isGatheringRecipe` | `bool` | no | `False` |
| 40 | `isEnchantingRecipe` | `bool` | no | `False` |
| 41 | `isSalvageRecipe` | `bool` | no | `False` |

System: none (a shared table, filed in `APIDocumentation.tables`)
