<!-- GENERATED from Blizzard_APIDocumentation, client build unknown. Do not edit; edit the generator. -->

# CooldownViewerCooldown

_Structure_

**Fields**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `cooldownID` | `number` | no |  |
| 2 | `spellID` | `number` | yes |  |
| 3 | `spellCategoryID` | `number` | yes |  |
| 4 | `overrideSpellID` | `number` | yes |  |
| 5 | `overrideTooltipSpellID` | `number` | yes |  |
| 6 | `equipSlot` | `luaIndex` | yes |  |
| 7 | `buffSlot` | `luaIndex` | yes |  |
| 8 | `linkedSpellIDs` | `table&lt;number&gt;` | no |  |
| 9 | `selfAura` | `bool` | no |  |
| 10 | `hasAura` | `bool` | no |  |
| 11 | `charges` | `bool` | no |  |
| 12 | `isKnown` | `bool` | no |  |
| 13 | `isInvisible` | `bool` | no |  |
| 14 | `flags` | `CooldownSetSpellFlags` | no |  |
| 15 | `category` | `CooldownViewerCategory` | no |  |

System: `CooldownViewer`
