<!-- GENERATED from Blizzard_APIDocumentation, client build unknown. Do not edit; edit the generator. -->

# C_AuctionHouse.GetReplicateItemInfo

```lua
name, texture, count, qualityID, usable, level, levelType, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, bidderFullName, owner, ownerFullName, saleStatus, itemID, hasAllInfo = C_AuctionHouse.GetReplicateItemInfo(index)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `index` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `name` | `string` | yes |  |
| 2 | `texture` | `fileID` | yes |  |
| 3 | `count` | `number` | no |  |
| 4 | `qualityID` | `number` | no |  |
| 5 | `usable` | `bool` | yes |  |
| 6 | `level` | `number` | no |  |
| 7 | `levelType` | `string` | yes |  |
| 8 | `minBid` | `BigUInteger` | no |  |
| 9 | `minIncrement` | `BigUInteger` | no |  |
| 10 | `buyoutPrice` | `BigUInteger` | no |  |
| 11 | `bidAmount` | `BigUInteger` | no |  |
| 12 | `highBidder` | `string` | yes |  |
| 13 | `bidderFullName` | `string` | yes |  |
| 14 | `owner` | `string` | yes |  |
| 15 | `ownerFullName` | `string` | yes |  |
| 16 | `saleStatus` | `number` | no |  |
| 17 | `itemID` | `number` | no |  |
| 18 | `hasAllInfo` | `bool` | yes |  |

Blizzard's own rendering: `C_AuctionHouse.GetReplicateItemInfo(index)`

System: `AuctionHouse` · Namespace: `C_AuctionHouse`
