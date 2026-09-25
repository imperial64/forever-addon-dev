<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

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

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_AuctionHouse.ConfirmPostItem(item, duration, quantity, optional bid, optional buyout)`

System: `AuctionHouse` · Namespace: `C_AuctionHouse`
