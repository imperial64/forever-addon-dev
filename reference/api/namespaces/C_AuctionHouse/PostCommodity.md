<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# C_AuctionHouse.PostCommodity

> **RESTRICTED — Blizzard flag.** This function carries `HasRestrictions` in the client's own documentation, meaning it is gated on a hardware event or refuses to run from a script.

```lua
needsConfirmation = C_AuctionHouse.PostCommodity(item, duration, quantity, unitPrice)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `item` | `ItemLocation (ItemLocationMixin)` | no |  |
| 2 | `duration` | `luaIndex` | no |  |
| 3 | `quantity` | `number` | no |  |
| 4 | `unitPrice` | `BigUInteger` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `needsConfirmation` | `bool` | no |  |

Blizzard's own rendering: `C_AuctionHouse.PostCommodity(item, duration, quantity, unitPrice)`

System: `AuctionHouse` · Namespace: `C_AuctionHouse`
