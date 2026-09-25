<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Item.GetItemUniquenessByID

```lua
isUnique, limitCategoryName, limitCategoryCount, limitCategoryID = C_Item.GetItemUniquenessByID(itemInfo)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `itemInfo` | `ItemInfo` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `isUnique` | `bool` | no |  |
| 2 | `limitCategoryName` | `cstring` | yes |  |
| 3 | `limitCategoryCount` | `number` | yes |  |
| 4 | `limitCategoryID` | `number` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_Item.GetItemUniquenessByID(itemInfo)`

System: `Item` · Namespace: `C_Item`
