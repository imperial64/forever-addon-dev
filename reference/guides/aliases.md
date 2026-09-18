# Aliases: what you reached for, and what replaced it

This is a guide, not a capture. It records what people *type* — which no scan of the
client can tell you — so it is maintained by hand and lives here rather than under the
generated `reference/api/` tree.

Forever runs Retail's API. The Classic-era globals are **gone**, and they are the ones
most people type first — either from memory of Classic, or from copying a Classic addon.

If a lookup fails, check here before concluding the function does not exist.

## Auction House

The whole Classic auction API is absent. Auction House code for this client is a **Retail
port**, not a Classic one.

| You typed | Use instead |
|---|---|
| `QueryAuctionItems` | `C_AuctionHouse.SendBrowseQuery` |
| `CanSendAuctionQuery` | `C_AuctionHouse.IsThrottledMessageSystemReady` (different meaning — see below) |
| `GetNumAuctionItems` | `C_AuctionHouse.GetNumBrowseResults` / `GetNumReplicateItems` |
| `GetAuctionItemInfo` | `C_AuctionHouse.GetBrowseResults` / `GetReplicateItemInfo` |
| `GetAuctionItemLink` | `C_AuctionHouse.GetReplicateItemLink` |
| `GetAuctionSellItemInfo` | `C_AuctionHouse.GetItemKeyFromItem` + `GetItemKeyInfo` |
| `SortAuctionItems` | sorts are part of the `AuctionHouseBrowseQuery` you pass |
| `StartAuction` | `C_AuctionHouse.PostItem` / `PostCommodity` |
| `PlaceAuctionBid` | `C_AuctionHouse.PlaceBid` / `StartCommoditiesPurchase` |
| `GetAuctionItemTimeLeft` | `C_AuctionHouse.GetReplicateItemTimeLeft` |

`IsThrottledMessageSystemReady` is **not** the Classic `CanSendAuctionQuery`. It describes
the message system, not the `ReplicateItems` throttle, and reads `true` while a full scan
is still throttled. See the restrictions skill.

Two differences from Retail worth knowing: there are **three** time-left bands here, not
four (30m / 2h / 12h), and `NUM_AUCTION_ITEMS_PER_PAGE` is still defined as 50 with no
legacy API left to page.

## Auras

| You typed | Use instead |
|---|---|
| `UnitAura` | `C_UnitAuras.GetAuraDataByIndex` |
| `UnitBuff` | `C_UnitAuras.GetBuffDataByIndex` |
| `UnitDebuff` | `C_UnitAuras.GetDebuffDataByIndex` |
| `AuraUtil.FindAuraByName` | `C_UnitAuras.GetAuraDataBySpellName` |

All of these **throw** in combat rather than returning nil. See the restrictions skill.

## Spells and items

| You typed | Use instead |
|---|---|
| `GetSpellInfo` | `C_Spell.GetSpellInfo` (returns a table, not a tuple) |
| `GetSpellCooldown` | `C_Spell.GetSpellCooldown` (returns a table) |
| `GetSpellCharges` | `C_Spell.GetSpellCharges` |
| `IsUsableSpell` | `C_Spell.IsSpellUsable` |
| `IsSpellInRange` | `C_Spell.IsSpellInRange` |
| `GetItemInfo` | `C_Item.GetItemInfo` |
| `GetItemCooldown` | `C_Item.GetItemCooldown` |

## Talents and specialisation

| You typed | Use instead |
|---|---|
| `GetTalentInfo` | `C_Traits` — Forever uses Retail's trait system |
| `GetSpecialization` | absent; spec IDs are new and differ from Retail's |

The Legacy talent panel is `ToggleLegacySystemUI`.

## Combat log

| You typed | Use instead |
|---|---|
| `CombatLogGetCurrentEventInfo` | **nothing.** Absent from the client |
| `COMBAT_LOG_EVENT_UNFILTERED` | **nothing.** Addons may not subscribe |

Blizzard ships `C_DamageMeter` for damage numbers. This is the one gap with no addon-side
replacement.

## Map and position

| You typed | Use instead |
|---|---|
| `GetPlayerMapPosition` | `C_Map.GetPlayerMapPosition` (returns an object, not `x, y`) |
| `GetCurrentMapAreaID`, `SetMapToCurrentZone` | `C_Map.GetBestMapForUnit` |

The return is the difference that bites: `C_Map.GetPlayerMapPosition` hands back a position
object and you call `:GetXY()` on it, so a Classic-style `local x, y = ...` silently gets
the object and nil. It also allocates 1864 bytes per call — see `guides/performance.md`
before polling it.

## Addons and files

| You typed | Use instead |
|---|---|
| `GetNumAddOns`, `GetAddOnInfo`, `IsAddOnLoaded`, `LoadAddOn` | `C_AddOns.*` |
| `io`, `os`, `loadfile`, `dofile` | absent. The sandbox is intact |
| `loadstring` | present |
| `loadstring_untainted` | absent, which is a beta bug that breaks every secure snippet |

For encoding and transport, `C_EncodingUtil` has JSON and CBOR both ways, base64, hex and
string compression.
