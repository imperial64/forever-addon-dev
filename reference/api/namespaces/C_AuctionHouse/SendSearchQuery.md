<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_AuctionHouse.SendSearchQuery

```lua
C_AuctionHouse.SendSearchQuery(itemKey, sorts, separateOwnerItems, minLevelFilter, maxLevelFilter)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `itemKey` | `ItemKey` | no |  |
| 2 | `sorts` | `table&lt;AuctionHouseSortType&gt;` | no |  |
| 3 | `separateOwnerItems` | `bool` | no |  |
| 4 | `minLevelFilter` | `number` | no | `0` |
| 5 | `maxLevelFilter` | `number` | no | `0` |

**Returns**

_None._

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_AuctionHouse.SendSearchQuery(itemKey, sorts, separateOwnerItems, optional minLevelFilter, optional maxLevelFilter)`

System: `AuctionHouse` · Namespace: `C_AuctionHouse`
