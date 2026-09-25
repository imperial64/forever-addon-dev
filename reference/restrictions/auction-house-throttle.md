# The auction scan throttle

Nothing about the Auction House appears in any restriction surface — no secrecy gate, no
forbidden call. But `C_AuctionHouse.ReplicateItems` has a throttle, and it is the most
operationally dangerous restriction on the client, because **it does not tell you**.

## What a throttled scan looks like

- the call returns `true`
- **no** `REPLICATE_ITEM_LIST_UPDATE` fires
- `GetNumReplicateItems()` stays at `0`

That is byte-for-byte what an auction house with nothing listed on it looks like. An addon
that treats the result as data will overwrite its price history with an empty market.

## The window

Measured: **more than 162 seconds, at most 1047**. Retail documents 900 account-wide, which
sits inside that bracket.

Three scans, each stamped: one at 15:25:20 succeeded with 14,389 auctions; one at 15:42:47
succeeded after a 1047-second gap; one at 15:45:29, 162 seconds later, returned nothing.

The bracket was deliberately not narrowed further, because browse is unthrottled and no
design decision depends on the exact figure.

## `IsThrottledMessageSystemReady` does not measure this

It describes the *message* system, not the replicate throttle, and read `true` throughout —
including 64 seconds after a successful scan. `AUCTION_HOUSE_THROTTLED_SYSTEM_READY` fired
three times during measurement, once **twenty seconds before** the scan it supposedly
related to, off a browse query.

Neither is a usable signal for "may I scan yet".

## What to do

**Track your own last-scan time and refuse to call inside your own window.** There is no
API that will answer this for you.

```lua
local WINDOW = 900  -- conservative: the measured bracket allows anything up to 1047
local lastScan = 0

local function mayScan()
    return (time() - lastScan) >= WINDOW
end
```

Keep `lastScan` in SavedVariables, bound on `ADDON_LOADED`. On build 70009 it survives a
`/reload` and a relaunch (`research/findings.md` §P.30). On 69913 and earlier nothing was
read back, so there the first scan after a reload has to be treated as unknown-risk.

## Prefer browse

`SendBrowseQuery` returned the complete item-key market in three seconds, unthrottled and
repeatable. Use `ReplicateItems` only when you need per-listing detail, and treat it as an
occasional deep read rather than a refresh mechanism. The numbers are in
`research/findings.md` P.15.

## Evidence

Measured 2026-09-18 on client 1.60.1 build 69913. `research/findings.md` P.15 (the numbers)
and P.17 (the throttle and its failure mode).
