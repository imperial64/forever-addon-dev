<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# C_AuctionHouse.ReplicateItems

> **FAILS SILENTLY — measured, at all times.** A throttled full scan returns an EMPTY MARKET, not an error.
> Measured 2026-09-18 on build 69913. Evidence: §P.15, §P.17 in [findings](../../../../research/findings.md).
> 
> _Workaround:_ Track your own last-scan time and refuse to call inside your own window. The client will not tell you. A naive addon writes "the market is empty" over its price history. Browse is unthrottled and returns the complete item-key market in about three seconds, so prefer it as the data source.

```lua
C_AuctionHouse.ReplicateItems()
```

**Arguments**

_None._

**Returns**

_None._

Blizzard's own rendering: `C_AuctionHouse.ReplicateItems()`

System: `AuctionHouse` · Namespace: `C_AuctionHouse`
