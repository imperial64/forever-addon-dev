<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_TooltipInfo.GetRecipeResultItem

```lua
data = C_TooltipInfo.GetRecipeResultItem(recipeID, reagentInfos, recraftItemGUID, recipeLevel, overrideQualityID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `recipeID` | `number` | no |  |
| 2 | `reagentInfos` | `table&lt;CraftingReagentInfo&gt;` | yes |  |
| 3 | `recraftItemGUID` | `WOWGUID` | yes |  |
| 4 | `recipeLevel` | `luaIndex` | yes |  |
| 5 | `overrideQualityID` | `number` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `data` | `TooltipData` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_TooltipInfo.GetRecipeResultItem(recipeID, optional reagentInfos, optional recraftItemGUID, optional recipeLevel, optional overrideQualityID)`

System: `TooltipInfo` · Namespace: `C_TooltipInfo`
