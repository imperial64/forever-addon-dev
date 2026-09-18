# Building an Auction House addon

Forever ships the **full modern `C_AuctionHouse`** — 85 functions, commodities included —
and none of the Classic-era auction API. An economy addon here is a Retail port, not a
Classic one. `reference/api/ALIASES.md` maps the old names.

The design advice below is measured on a beta realm with 14,389 auctions. The *shape*
generalises; the timings may not. Re-measure at launch.

## Browse is the data source, not `ReplicateItems`

This is the single most important decision, and it is the opposite of what Retail experience
suggests.

**Measured:** one `SendBrowseQuery` with empty filters, plus one
`RequestMoreBrowseResults`, returned the **complete item-key market in 3.0 seconds** — 680
item keys covering 14,389 auctions — with the client setting `HasFullBrowseResults()` true.
Page size is 500. **No throttle.** Repeat it as often as you like.

```lua
C_AuctionHouse.SendBrowseQuery({
    searchString = "", sorts = {}, filters = {}, itemClassFilters = {},
})
-- then on AUCTION_HOUSE_BROWSE_RESULTS_UPDATED / _ADDED:
local results = C_AuctionHouse.GetBrowseResults()
if not C_AuctionHouse.HasFullBrowseResults() then
    C_AuctionHouse.RequestMoreBrowseResults()
end
```

Each browse result carries the item key, the lowest price and the total quantity behind it
— which is exactly what a price-tracking addon needs.

On Retail, browse is inadequate and addons are pushed onto the throttled full scan; that is
the reason TradeSkillMaster is half a desktop application. **That reasoning does not hold
here.** An economy addon on Forever can plausibly be just an addon.

## `ReplicateItems` is the optional deep read, and it lies when throttled

Use it when you need *per-listing* detail rather than per-item-key summaries. Measured:
14,389 auctions in 3.0 seconds, delivered in a **single** update event, with no client
stall.

**The throttle is real and silent.** Measured at more than 162 seconds and at most 1047
(Retail documents 900). When it bites:

- the call returns `true`
- **no** `REPLICATE_ITEM_LIST_UPDATE` fires
- `GetNumReplicateItems()` stays at `0`

That is indistinguishable from an auction house with nothing on it. `IsThrottledMessage
SystemReady()` describes the *message* system, not this throttle, and reads true throughout.

**So track your own last-scan time and refuse to call inside your own window.** The client
will not tell you, and a naive addon writes "the market is empty" over its price history.

## The replicate tuple

Retail's 18-value shape exactly:

```
name, texture, count, qualityID, usable, level, levelType,
minBid, minIncrement, buyoutPrice, bidAmount,
highBidder, bidderFullName, owner, ownerFullName,
saleStatus, itemID, hasAllInfo
```

**Owner names are `nil`** — 0 of 500 sampled rows carried one. Forever inherited Retail's
9.0.2 anonymisation, so you cannot attribute a listing to a seller or track individual
competitors. Plan around it; the fields exist but are always empty.

## Two differences from Retail

- **Three time-left bands, not four.** `GetTimeLeftBandInfo` answers for 1, 2 and 3 —
  1800s, 7200s, 43200s (30 minutes, 2 hours, 12 hours) — and errors on 4. Retail has a
  fourth at 48 hours. Any "about to expire" logic has a shorter ladder here.
- `NUM_AUCTION_ITEMS_PER_PAGE` is still defined as 50, a legacy constant with no legacy API
  left to page.

## Posting and buying

All seven of Retail's restricted functions are present and carry `HasRestrictions`:
`PostItem`, `PostCommodity`, `ConfirmPostItem`, `ConfirmPostCommodity`, `PlaceBid`,
`StartCommoditiesPurchase`, `CancelAuction`.

They are gated on a hardware event: you can compute everything in advance, but a human has
to click once per action. Design the UI around one click per post, not a batch button.

## Events you can rely on

All measured as permitted: `AUCTION_HOUSE_SHOW`, `AUCTION_HOUSE_CLOSED`,
`AUCTION_HOUSE_BROWSE_RESULTS_UPDATED`, `AUCTION_HOUSE_BROWSE_RESULTS_ADDED`,
`AUCTION_HOUSE_BROWSE_FAILURE`, `AUCTION_HOUSE_THROTTLED_SYSTEM_READY`,
`COMMODITY_SEARCH_RESULTS_UPDATED`, `ITEM_SEARCH_RESULTS_UPDATED`.

Nothing in the restriction surface touches the Auction House.
