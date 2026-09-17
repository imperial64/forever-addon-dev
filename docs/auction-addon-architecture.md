# How auction addons actually work

Research pass 2026-09-17. Purpose: know what the economy / TradeSkillMaster-style plan
would have to be built out of, before the Forever client exists to probe.

Everything here is about **retail and existing Classic titles**. None of it is evidence
about Forever. It is the design space Forever will land somewhere inside of.

Confidence labels match `findings.md`: **[PRIMARY]** fetched and read directly ·
**[REPORTED]** credible secondary source, fetched · **[UNVERIFIED]** surfaced in search,
not independently confirmed · **[EXCLUDED]** checked and found false or unreliable.

---

## 1. Bottom line

Four things decide whether an economy addon is possible, and they are independent:

| Question | Where the answer lives |
|---|---|
| Which AH API ships? | `C_AuctionHouse` vs legacy `QueryAuctionItems` |
| Can you bulk-read the market? | `ReplicateItems` / `getAll`, both throttled to 15 min |
| Can you act on it automatically? | `#hwevent` / `#noscript` restrictions — you cannot |
| Can data cross the process boundary? | SavedVariables out, a generated `.lua` file in |

The last one is the important discovery for this project. **Every serious auction addon is
half an out-of-game program**, and the in-game half receives its data through a mechanism
that has nothing to do with the Auction House at all. That mechanism is also exactly what
the Claude Code notification bridge needs. See §5.

---

## 2. Two auction APIs exist, and which one you get is per-title

**[PRIMARY]** [warcraft.wiki.gg, API:C_AuctionHouse.SendBrowseQuery](https://warcraft.wiki.gg/wiki/API:C_AuctionHouse.SendBrowseQuery)
— "Game Types: mainline + 8.3.0 · mop classic + 4.4.2". Patch note: "Patch 8.3.0
(2020-01-14): Added, replacing QueryAuctionItems()."

**[PRIMARY]** [warcraft.wiki.gg, API:QueryAuctionItems](https://warcraft.wiki.gg/wiki/API:QueryAuctionItems)
— "Game Types: mainline + 1.0.0 − 8.3.0 · mop classic + 1.13.2 · bcc anniversary + 1.13.2
· classic era + 1.13.2".

So as of now:

| Title | AH API |
|---|---|
| Retail (Mainline) | `C_AuctionHouse` since 8.3.0 |
| MoP Classic / Cata Classic | `C_AuctionHouse` since **4.4.2**, legacy also still present |
| Classic Era, SoD, BCC Anniversary | legacy `QueryAuctionItems` only |

The load-bearing point for us: **Blizzard already backported the modern commodity auction
house into a Classic title.** A Classic-flavoured game is not automatically a legacy-API
game. Forever could ship either, and the probe has to tell us which.

### Legacy API shape

**[PRIMARY]** same page. `QueryAuctionItems(text, minLevel, maxLevel, page, usable, rarity,
getAll, exactMatch, filterData)`. Page-based, results read back with
`GetNumAuctionItems` / `GetAuctionItemInfo` after `AUCTION_ITEM_LIST_UPDATE`.

**[PRIMARY]** [warcraft.wiki.gg, API:CanSendAuctionQuery](https://warcraft.wiki.gg/wiki/API:CanSendAuctionQuery)
— returns `canQuery, canQueryAll`. "There is always a short delay (usually less than a
second) after each query before another query can take place. Full ("getall") queries are
only allowed once every ~15 minutes."

**[PRIMARY]** `QueryAuctionItems` page, Details: queries "throttled at 0.3 seconds
normally, or 15 minutes with getAll mode"; `getAll` "might disconnect players with low
bandwidth"; and "In 4.0.1, getAll mode only fetches up to 42554 items."

### Modern API shape

**[PRIMARY]** [Blizzard's own generated API documentation](https://raw.githubusercontent.com/Gethe/wow-ui-source/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/AuctionHouseDocumentation.lua),
read directly. The namespace splits reads three ways:

- **Browse** — `SendBrowseQuery`, `RequestMoreBrowseResults`: the search-results list.
- **Per-item** — `SendSearchQuery` / `SendSellSearchQuery`, then
  `GetNumItemSearchResults` / `GetItemSearchResultInfo` for non-fungible gear, or
  `GetNumCommoditySearchResults` / `GetCommoditySearchResultInfo` for stackable goods.
- **Bulk** — `ReplicateItems`, `GetNumReplicateItems`, `GetReplicateItemInfo`.

Plus `IsThrottledMessageSystemReady` and a family of `AUCTION_HOUSE_THROTTLED_MESSAGE_*`
events for pacing your own requests.

The commodity/item split is the structural change from legacy: stackable goods have no
individual listings, only a price ladder by unit price.

---

## 3. The full scan is effectively dead in both APIs

**[PRIMARY]** [warcraft.wiki.gg, API:C_AuctionHouse.ReplicateItems](https://warcraft.wiki.gg/wiki/API:C_AuctionHouse.ReplicateItems):

- "There's a 15 min account-wide throttle between each successful
  `C_AuctionHouse.ReplicateItems()` call".
- "This disconnected clients on busy servers with more than 80k auctions, even with
  throttling. But was hotfixed during patch 9.0.2 to not include player names anymore."
- "As of 2022-12-10, there seems to be a limit on how many `REPLICATE_ITEM_LIST_UPDATE`
  fire per frame, about 2000."

So the bulk read exists, returns anonymised data, costs a client stall, and gives you at
most four snapshots an hour. Legacy `getAll` is the same 15-minute cadence with a
42 554-item ceiling and a disconnect risk.

**Consequence:** you cannot build a live market view from in-game scanning. Every addon
that appears to have one is getting the data from outside the game.

---

## 4. How the real addons solve it

### TradeSkillMaster — the "half of it is a desktop app" answer

**[REPORTED]** [TSM support, "Why is my scan failing or lagging in Classic?"](https://support.tradeskillmaster.com/en_US/addon/why-is-my-scan-failing-or-lagging-in-classic)
— TSM does not rely on in-game full scans for market pricing; market-wide data is collected
out of game from Blizzard's Game Data API on roughly an hourly cadence, and in-game
scanning is reserved for local, targeted work (sniping, post/cancel checks).

**[REPORTED]** Price sources are computed on TSM's servers, not the client: `DBMarket` is a
decay-weighted ~14-day average with outlier trimming, `DBRegionMarketAvg` averages it
across the region, `DBRegionSaleAvg` comes from **crowdsourced** Accounting data uploaded
by users' desktop apps. Source:
[TSM support, custom strings](https://support.tradeskillmaster.com/en_US/custom-strings/how-is-auctiondb-market-value-calculated).

**[REPORTED]** Two-tier config model worth stealing: **Groups** (a hierarchy of items,
rooted at an unremovable Base Group) × **Operations** (reusable behaviour profiles —
Auctioning, Shopping, Sniper, Crafting, Mailing, Vendoring, Warehousing). Items carry no
logic; operations carry no item list. Source:
[TSM support, managing operations](https://support.tradeskillmaster.com/en_US/tsm-addon-documentation/tsm-addon-manging-operations).

**[REPORTED]** TSM4 collapsed the old multi-addon layout into one addon plus
`TradeSkillMaster_AppHelper`, on an OO core (`LibTSMClass`) and an in-memory relational DB
with reactive redraws. The support libraries are public and verified to exist:
[github.com/TradeSkillMaster](https://github.com/TradeSkillMaster) — `LibTSMClass`,
`LibTSMDatabase`, `LibTSMReactive`, `LibTSMUtil`, `LibTSMCore`. The addon itself is not
open source.

### Auctionator, Auctioneer, Aux, RECrystallize

**[REPORTED]** The non-TSM addons stay inside the game and accept worse data:

- **Auctionator** (Classic builds): full scans behind the 15-minute gate, or paginated
  50-item incremental scans; price = most recent minimum buyout, stored per realm/faction
  in a plain uncompressed SavedVariables table, kept from exploding by age-based pruning.
- **Aux** (Classic): a coroutine state machine that yields on `CanSendAuctionQuery()`,
  stores history as compact delimiter-separated string tuples rather than Lua tables, and
  values items with a decay-weighted median rather than an average.
- **Auctioneer / Auc-Advanced**: modular statistics engines (moving average, histogram,
  standard deviation, realised-sale tracking) over uncompressed multi-file
  SavedVariables — historically enormous files and logout stalls.
- **RECrystallize**: `ReplicateItems` on a self-imposed 20-minute cooldown, lowest unit
  buyout, age-based cleanup.

Treat the per-file and per-line details of these as [UNVERIFIED] — they came from a search
pass, and the citations to `Auctionator/Auctionator` did not resolve (see §8). The
*patterns* are consistent across all four and are what matters:

1. Price from lowest current buyout is cheap and wrong at the tails; price from a
   decay-weighted median or trimmed mean is what survives manipulation.
2. Raw Lua tables in SavedVariables do not scale. Either serialize to compact strings
   (Aux), prune aggressively by age (Auctionator, RECrystallize), or compress with
   LibSerialize + LibDeflate.
3. Incremental targeted scans beat full scans in practice, because the full scan is gated.

---

## 5. The bridge mechanism — the most reusable finding here

**[PRIMARY]**, read directly from a public mirror of the shipped addon:
[hippuli/TradeSkillMaster_AppHelper](https://github.com/hippuli/TradeSkillMaster_AppHelper).

The addon is four files. Its `.toc`:

```
## Title: |cff00ff00TradeSkillMaster_AppHelper|r
## Notes: Acts as a connection between the TSM addon and app.
## SavedVariables: TradeSkillMaster_AppHelperDB
## Dependency: TradeSkillMaster

TradeSkillMaster_AppHelper.lua
AppData.lua
```

`AppData.lua` is **empty in the repository**. It is a placeholder that the desktop
application overwrites on disk with generated Lua. `TradeSkillMaster_AppHelper.lua` is the
receiver:

```lua
local _, TSM = ...
local private = { data = {} }

function TSM.LoadData(tag, ...)
	private.data[tag] = private.data[tag] or {}
	tinsert(private.data[tag], {...})
end

function TSMAPI.AppHelper:FetchData(tag)
	local data = private.data[tag]
	private.data[tag] = nil
	return data
end
```

That is the whole trick. The external program writes a `.lua` file full of
`TSM.LoadData("<tag>", ...)` calls into the addon folder; the client executes it as addon
code at load; the addon reads it back out of memory.

**Properties of this channel:**

- **Inbound only at load time.** The file is executed when the addon loads, so new data
  requires `/reload` or a relog. There is no polling and no push.
- **Outbound is SavedVariables**, flushed only on logout or `/reload`.
- It works because the file is *addon code*, not data being read — the Lua sandbox has no
  `io`, no `os`, no sockets, so nothing else is available.

**[REPORTED]** The sandbox restriction itself:
[warcraft.wiki.gg, Lua environment](https://warcraft.wiki.gg/wiki/Lua_environment) — the
client Lua environment has no `io`, `os`, or network access.

**This is directly reusable for the Claude Code notification bridge**, which currently sits
in the plan as "no known IPC channel". There is a known channel; it is this one, and its
cost is the reload. Worth adding to the probe: confirm Forever still executes addon-folder
`.lua` files listed in the `.toc`, and measure what a `/reload` costs there.

---

## 6. What you are never allowed to automate

**[PRIMARY]**, read from Blizzard's own generated documentation file. Exactly seven
functions in the `C_AuctionHouse` namespace carry `HasRestrictions = true`:

```
CancelAuction
ConfirmPostCommodity
ConfirmPostItem
PlaceBid
PostCommodity
PostItem
StartCommoditiesPurchase
```

**[PRIMARY]** [warcraft.wiki.gg, API:C_AuctionHouse.PostItem](https://warcraft.wiki.gg/wiki/API:C_AuctionHouse.PostItem)
spells out what the flag means: "Predicates: AllowedWhenUntainted, HasRestrictions" and
"#hwevent — This requires a hardware event i.e. keyboard/mouse input. #noscript — This
cannot be called directly from /run and /script (RunScript) and loadstring".

Note also **[PRIMARY]** that `SendBrowseQuery` — a pure *read* — is itself marked
restricted with `#noscript`, "Otherwise it will brick the AH."

So the shape of a legal auctioning addon is fixed: it may compute the entire posting plan
in advance, but a human has to click once per action. Mass posting and mass cancelling are
one-keypress-per-auction, always. This is settled in retail and is not a Forever-specific
risk — it long predates the disarmament doctrine, and it is an *execute-side* rule, not a
read-side one.

---

## 7. The out-of-game data source does not exist for Classic

**[PRIMARY]** Blizzard's Game Data API exposes
`/data/wow/connected-realm/{id}/auctions` and `/data/wow/auctions/commodities` on an hourly
snapshot cadence — [develop.battle.net game data APIs](https://develop.battle.net/documentation/world-of-warcraft/game-data-apis)
(reachable, 200).

**[PRIMARY]** But for Classic namespaces it is broken, and has been for over a year:
[Blizzard API forum, "404 for all Classic Era namespace auction house endpoints"](https://us.forums.blizzard.com/en/blizzard/t/404-for-all-classic-era-namespace-auction-house-endpoints/54307)
(2025-03-07) — "Since late 2024 the AH hourly data has been unavailable for any of the
`dynamic-classic1x-{region}` namespaces". Blizzard staff reply: "This issue has been
surfaced and is on the radar. No ETA on resolution."

**[REPORTED]** Corroborated on a second, independent domain:
[AzerothAuctionAssassin issue #7](https://github.com/ff14-advanced-market-search/AzerothAuctionAssassin/issues/7)
— "querying the api for auctions does give a 404, so I guess not possible for now" against
`namespace=dynamic-classic1x-us`.

**Consequence for our plan.** TSM's architecture — the thing that makes TSM *work* —
depends on an hourly out-of-game data feed that Blizzard has not provided for any Classic
title since late 2024. If Forever gets no Game Data API auction endpoint, then:

- The TSM model is unavailable, whatever the in-game API turns out to be.
- What remains is the Classic-TSM model: **crowdsourced in-game scans** pooled through a
  desktop app and a server you run. That is a service, not an addon.
- Or the honest single-player scope: your own scans, your own realm, 15-minute cadence,
  decay-weighted valuation, and an addon that is good at *deciding what to post* rather
  than at knowing the market.

Whether Forever gets an API endpoint is now an open question worth watching in the news
task alongside the addon questions.

---

## 8. Rejected and unverified

**[EXCLUDED]** A "per-minute action budget" server throttle on AH actions, sourced to two
Blizzard blue posts from June 2020. One URL 404s; the other
(`.../auction-house-delays-and-throttling/558231`) resolves to an unrelated 2020 thread
about instance locks. Fabricated citation. The claim may still be true — retail AH actions
are visibly rate-limited — but there is no source for it and it is not being carried.

**[EXCLUDED]** "Auctionator PR #928 abandoned in-game full scans in favour of Blizzard's
Web Game Data API." The repository `Auctionator/Auctionator` returns 404 and the PR cannot
be checked. The `Auctionator` GitHub org does exist and does contain
`Auctionator/PreserveAuctionatorAHScan` (last pushed 2025-05-20), a "utility addon to save
an Auctionator AH scan's unprocessed data for use on another login" — suggestive of scan
data being awkward to keep, but not evidence of what was claimed.

**[UNVERIFIED]** All per-file and per-line detail about Auctionator, Auctioneer, Aux and
RECrystallize internals in §4. Repository paths were not confirmed. The behavioural
patterns are corroborated across sources; the code references are not.

**[UNVERIFIED]** TSM's exact `DBMarket` algorithm (30th-percentile cap, 1.5σ prune,
~2-day half-life). Single-source, from TSM's own support site.

**[UNVERIFIED]** Gethe's `wow-ui-source` mirror carries a full `C_AuctionHouse`
documentation file on both its `classic` and `classic_era` branches, byte-identical
(41 028 bytes). If `classic_era` really tracks Classic Era, that contradicts the wiki's
version table. More likely the branch is stale or mistargeted. The wiki version table is
the better source and is what §2 uses.

---

## 9. What this changes for the probe

`/fprobe` currently answers "is `C_AuctionHouse` present". That is no longer enough. It
should also record:

1. Which of the seven restricted functions exist, and whether their presence matches
   retail's `HasRestrictions` set.
2. Whether `ReplicateItems` / `GetNumReplicateItems` exist, and what the throttle is.
3. Whether legacy `QueryAuctionItems` / `CanSendAuctionQuery` coexist, as they do in MoP
   Classic.
4. Whether `GetReplicateItemInfo` returns owner names, or `nil` as retail does since 9.0.2.
5. Whether commodities exist at all — `GetItemCommodityStatus`,
   `GetNumCommoditySearchResults`. A Classic+ game may have no commodity split.
6. Confirmation that an addon-folder `.lua` file written by an external process is executed
   at load (the §5 bridge), and whether SavedVariables still flush on `/reload`.

Items 1–5 are all out-of-combat reads. Nothing in the disarmament doctrine touches them;
per §6, the auction restrictions that do exist are execute-side and predate it by years.
