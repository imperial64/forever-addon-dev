<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Item.GetItemInfo

```lua
itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType, expansionID, setID, isCraftingReagent, itemDescription = C_Item.GetItemInfo(itemInfo)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `itemInfo` | `ItemInfo` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `itemName` | `cstring` | no |  |
| 2 | `itemLink` | `cstring` | no |  |
| 3 | `itemQuality` | `ItemQuality` | no |  |
| 4 | `itemLevel` | `number` | no |  |
| 5 | `itemMinLevel` | `number` | no |  |
| 6 | `itemType` | `cstring` | no |  |
| 7 | `itemSubType` | `cstring` | no |  |
| 8 | `itemStackCount` | `number` | no |  |
| 9 | `itemEquipLoc` | `cstring` | no |  |
| 10 | `itemTexture` | `fileID` | no |  |
| 11 | `sellPrice` | `number` | no |  |
| 12 | `classID` | `number` | no |  |
| 13 | `subclassID` | `number` | no |  |
| 14 | `bindType` | `number` | no |  |
| 15 | `expansionID` | `number` | no |  |
| 16 | `setID` | `number` | yes |  |
| 17 | `isCraftingReagent` | `bool` | no |  |
| 18 | `itemDescription` | `cstring` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_Item.GetItemInfo(itemInfo)`

System: `Item` · Namespace: `C_Item`
