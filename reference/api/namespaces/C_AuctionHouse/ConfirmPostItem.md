<!-- GENERATED from Blizzard_APIDocumentation, client build unknown. Do not edit; edit the generator. -->

# C_AuctionHouse.ConfirmPostItem

> **RESTRICTED — Blizzard flag.** This function carries `HasRestrictions` in the client's own documentation, meaning it is gated on a hardware event or refuses to run from a script.

```lua
C_AuctionHouse.ConfirmPostItem(item, duration, quantity, bid, buyout)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `item` | `ItemLocation (ItemLocationMixin)` | no |  |
| 2 | `duration` | `luaIndex` | no |  |
| 3 | `quantity` | `number` | no |  |
| 4 | `bid` | `BigUInteger` | yes |  |
| 5 | `buyout` | `BigUInteger` | yes |  |

**Returns**

_None._

Blizzard's own rendering: `C_AuctionHouse.ConfirmPostItem(item, duration, quantity, optional bid, optional buyout)`

System: `AuctionHouse` · Namespace: `C_AuctionHouse`
