# Findings — WoW Forever addon capabilities

Last updated 2026-09-20. This is the evidence base behind the restriction data this plugin
ships. §P is a probe run on the beta client, and outranks everything. §0 is a third-party
capture of the same build, fetched and queried here, which outranks every press source
below it. The numbered sections are press and developer statements, kept for context and
ranked below both.

`research/restrictions.yaml` cites the sections below by number, so section IDs are stable:
they are never renumbered, only added to.

Confidence labels, strongest first: **[PROBE]** measured by ForeverProbe on a live
client · **[MEASURED]** read off someone else's capture of the running client ·
**[PRIMARY]** fetched and read directly · **[REPORTED]** credible secondary source,
fetched · **[UNVERIFIED]** surfaced in search, not independently confirmed ·
**[EXCLUDED]** checked and found irrelevant or unreliable.

---

## P. Measured on a live client (2026-09-18, extended 2026-09-20)

**[PROBE — ForeverProbe, beta build 1.60.1.69913, character in Elwynn Forest, out of
combat]** This outranks everything below it, including §0: it is behaviour observed on a
running client rather than someone else's capture or someone's reporting. Note the build:
69913, one ahead of the capture §0 describes.

### P.1 An addon may not register `COMBAT_LOG_EVENT_UNFILTERED` at all

At load, before any command was typed, the client raised the forbidden-action dialog
("ForeverProbe has been blocked from an action only available to the Blizzard UI") and
fired:

```
ADDON_ACTION_FORBIDDEN func=UNKNOWN() during: RegisterEvent:COMBAT_LOG_EVENT_UNFILTERED
```

**This answers open question 4, and not in the shape anyone expected.** The doctrine (§3)
says addons "cannot parse combat events in real time", which everybody — this document
included — read as the event firing with fields stripped or masked. It is stronger than
that: the addon is refused the *subscription*. There is nothing to parse because there is
nothing to receive.

The restriction holds at two independent levels. `CombatLogGetCurrentEventInfo` is also
absent from this build entirely (§0.5), so even an addon that somehow held a subscription
would have no reader for it.

**Three things worth being precise about:**

1. **This fired out of combat.** At load, standing in Elwynn Forest, with no target and no
   combat anywhere near. So this particular restriction is **always-on, not combat-scoped**
   — which is a genuine correction to how §0.3 framed the question. "Is the black box
   combat-scoped?" is now two questions: the *event subscription* is unconditionally
   forbidden, while the `C_Secrets` *value* gates may still turn on and off with combat.
   Different mechanisms, measured separately. `/fprobe report` still has to answer the
   second.
2. **Nothing was raised.** `RegisterEvent` returned normally and the frame simply never
   received the event. A `pcall` around it reports success. This is exactly the trap
   `CLAUDE.md` warns about, found in a place we had not thought to look — not a masked
   return value, but a refusal at the subscription level.
3. **`func=UNKNOWN()`** — the client did not name the function in the event payload. The
   attribution comes from the probe tagging each registration, not from the client.

### P.2 Secret values are contagious, and `tostring()` does not launder them

`/fprobe` crashed mid-run on its first live pass:

```
ForeverProbe.lua:1234: attempt to index field '?' (a secret string value,
while execution tainted by 'ForeverProbe')
  locals: name="playerPower"  ok=true  v=<secret string>
```

Note `ok=true`. The read was wrapped in a `pcall`, the `pcall` succeeded, and the value it
handed back detonated one line later in the print. **`tostring()` on a secret value returns
a secret string.** The taint survives the conversion, so "convert it inside a pcall" —
which this document previously recommended, in §0.3 — is not protection at all. The
operation that throws is the next *index* of the result, which is somewhere else entirely
by then.

The client ships the correct tools and this build has the whole family: `issecretvalue`,
`issecrettable`, `hasanysecretvalues`, `scrub`, `scrubsecretvalues`, `canaccesssecrets`,
`secretwrap`, `dropsecretaccess`. Anything reading game state must test with
`issecretvalue` **before and after** conversion, and must do so before storing, because a
secret string written into SavedVariables would take the whole flush down — and the flush
is the entire output of this addon.

### P.3 `UnitPower("player")` is secret **out of combat**

The value that crashed it was player power, read standing in Elwynn Forest with no target
and no combat. That is a direct contradiction of the doctrine (§3), which says class
secondary resources "remain fully non-secret", and it is a second strike against the
combat-scoped reading of the black box.

Measured in the same out-of-combat pass:

| Gate | Value |
|---|---|
| `HasSecretRestrictions()` | **true** |
| `ShouldAurasBeSecret()` | false |
| `ShouldCooldownsBeSecret()` | false |
| `UnitPower("player")` | **returns a secret value** |
| `C_CombatLog.IsCombatLogRestricted()` | **true** |
| `C_ChatInfo.AreOutgoingAddonChatMessagesRestricted()` | **true** |
| `C_ChatInfo.InChatMessagingLockdown()` | false |

So out of combat, some things are secret and some are not, and which is which does not
follow the doctrine's own description. Auras and cooldowns — the two things §3 names as
removed — read as *not* secret out of combat, while power, which §3 explicitly protects,
is secret.

**Caveat on the gates.** Several `C_Secrets` functions take arguments (a unit token, an
action slot, a spell id) and threw on the first run because they were called with none.
"Threw because I called it wrong" is indistinguishable from "threw because it is
restricted", and recording the first as the second would have been a false finding. The
probe now tries each gate against several argument sets and records which one answered, so
the next run gives a clean table.

### P.4 Actions: `UseAction` is forbidden out of combat

Out of combat, on our own client:

| Call | Result |
|---|---|
| `CastSpellByName` | allowed |
| `UseAction(1)` | **BLOCKED** — `ADDON_ACTION_FORBIDDEN:UseAction()` |
| `EditMacro` | allowed |
| `SetOverrideBindingClick` | allowed |
| `SecureBtn:SetAttribute` | allowed |

`UseAction` is forbidden outright rather than merely protected in combat.

### P.5 Which auction API ships, and which data channels are open

Corroboration of §0, measured on a live client rather than read off someone else's capture.

**Auction House** — `/fprobe` scored every section full: modern 12/12, commodity 5/5,
replicate 3/3, restricted 7/7, legacy 0/8, legacy actions 0/4. The verdict line reads
"modern `C_AuctionHouse` only — retail AH code largely ports". The restricted set matches
retail's seven exactly. §0.1 is confirmed: this client ships the modern API and none of the
legacy one.

**Data channels across the client boundary** — `io=false os=false load=true addonMsg=true
cvar=true json=true clipboard=true reloadUI=true`, and the inbound file channel works:
`ExternalData.lua` loaded and reported "shipped default only", which is the probe's way of
saying the file was executed as addon code and the receiver ran. The channel is live; it
has simply not been written to from outside yet. `scripts/write-external-data.ps1` then
`/reload` closes that loop.

The one new constraint is `AreOutgoingAddonChatMessagesRestricted() = true`, which removes
the addon-message sideband that §0.2 listed as a candidate for moving data out.

### P.6 Odds and ends

- **The client is build 69913**, not the 69893 the §0 capture describes. Forever is
  patching the beta daily; §0 is already one build behind, which is an argument for
  trusting the probe over the capture wherever they disagree.
- `C_AssistedCombat` is present but **inert**: `IsAvailable()` returns false and
  `GetRotationSpells()` returns 0 entries. The API Blizzard shipped is not currently doing
  anything for a player on this build (§0.4).
- Global dump: 5,958 functions and 269 `C_` namespaces, against the capture's 6,045 and
  269. Same shape, slightly different surface — consistent with the build difference.
- Surface scores: read 32/48, execute 16/18, secure 14/15, channel 26/31.

---

### P.9 Moving data out of the client: outbound works, the round trip does not

Measured 2026-09-18 on a live client. This is the constraint on any addon that needs to
exchange data with a process outside the game — importing prices or settings, exporting
logs or a database.

**Outbound works.** `WTF/Account/<account>/SavedVariables/ForeverProbe.lua` exists on
disk, 303 KB, written on logout. Everything the probe recorded — the full global dump, the
namespace map, the secrecy gates, the auction surface — came back out of the client in a
file an external process can read. That is the entire outbound requirement.

**The in-client round trip does not.** `external.loads` reads 1 in every session, and
`tokenFromPreviousSession` is `nil` after a `/reload` that definitely happened. The client
writes the file and never reads it back, exactly as §0.2 reported from someone else's
testing, now confirmed here.

**The inbound channel works.** `external.inboxEntries = 1` with `untouched = true`: the
shipped `ExternalData.lua` was executed as addon code and its receiver ran. The mechanism is
live — it has simply never been written to by an external process yet.
`scripts/write-external-data.ps1` then `/reload` is what closes that loop.

**So a two-way channel is buildable in exactly the shape §0.2 predicted**, and the
SavedVariables bug costs it nothing, because it never needed the client to read its own
saves. An external process writes a `.lua` file the `.toc` lists; the player types
`/reload`; the addon answers into SavedVariables; the external process reads that. The
`/reload` is the price, and `ReloadUI()` being protected is what keeps it manual.

### P.10 The secrecy gates, read properly

With the argument arity fixed, the gates answer cleanly. Out of combat, standing in a
field:

| Gate | Value |
|---|---|
| `HasSecretRestrictions()` | **true** |
| `ShouldUnitPowerBeSecret("player")` | **true** |
| `ShouldAurasBeSecret()` | false |
| `ShouldCooldownsBeSecret()` | false |
| `ShouldActionCooldownBeSecret(1)` | false |
| `ShouldUnitIdentityBeSecret("player")` | false |
| `ShouldUnitHealthMaxBeSecret("player")` | false |
| `ShouldUnitStatsBeSecret()` | false |
| `C_CombatLog.IsCombatLogRestricted()` | **true** |
| `C_RestrictedActions.GetAddOnRestrictionState()` | 0 |
| `C_ChatInfo.AreOutgoingAddonChatMessagesRestricted()` | **true** |
| `C_ChatInfo.InChatMessagingLockdown()` | false |

Blizzard's own gate agrees with the crash in §P.2: `ShouldUnitPowerBeSecret("player")` is
**true out of combat**, and the matching read returns `<SECRET>`. Meanwhile the reads §3
says are gone are available — `playerAura1` returned "Seal of Righteousness" by name.

So the doctrine's published description and this client disagree in both directions at
once. Auras and cooldowns, named as removed, are readable out of combat. Class resources,
explicitly promised as "fully non-secret", are not. Whatever rule is actually implemented,
§3 is not a reliable guide to it, and neither is any press summary of §3.

`GetAddOnRestrictionState()` returning 0 with `IsAddOnRestrictionActive()` false, while
`HasSecretRestrictions()` is true, suggests the two systems are independent: a general
addon-restriction state that is currently off, and per-category secrecy that is already on.

### P.11 Our surface matches the capture exactly

The probe's own global dump was diffed against §0's third-party capture. Every namespace
this project cares about is **identical**: `C_AuctionHouse` 85 functions, `C_Secrets` 27,
`C_ChatInfo` 45, `C_EncodingUtil` 10, `C_CVar` 12, `C_AssistedCombat` 4, `C_CombatLog` 11,
`C_RestrictedActions` 3. All 269 namespaces present on both sides, none missing either way.

The only difference is 88 global functions the capture has and we do not, and they are that
author's own addons leaking into their dump — `_EBS_InCombat`, `_ECL_ApplyCombatOnlyEvents`,
`_EUF_ReloadFrames`, `Addon_GetBankType`. Worth knowing as a methodological caveat: the
capture's *namespace* lists are clean, its *global function* list is polluted by whatever
was loaded at the time. Ours has one global the capture lacks, for the same reason.

§0 is therefore confirmed rather than merely trusted, on a build one patch newer.

---

### P.12 The rule is the combat log, not combat information

`/fprobe events` walked the neighbourhood of §P.1's refusal, registering each event and
attributing every refusal. The answer is clean:

**Refused — both forms, nothing else:**

```
COMBAT_LOG_EVENT
COMBAT_LOG_EVENT_UNFILTERED
```

**Allowed:** `AUCTION_HOUSE_SHOW`, `AUCTION_HOUSE_THROTTLED_SYSTEM_READY`, `BAG_UPDATE`,
`CHAT_MSG_ADDON`, `PLAYER_MONEY`, `PLAYER_REGEN_DISABLED`, `PLAYER_REGEN_ENABLED`,
`UNIT_AURA`, `UNIT_COMBAT`, and the remaining unit events. **Not on this client:** none —
every event tried exists.

**This settles the shape of the rule.** It is not "addons may not know about combat". An
addon may still subscribe to `UNIT_AURA`, to `UNIT_COMBAT`, and to both combat-state
events. What it may not have is the combat log itself, in either form. The restriction is
narrow and specific, and it lines up with the three separate mechanisms now visible on this
client:

1. **The combat log** — refused at subscription, and no reader function exists (§P.1).
2. **Per-category secrecy** — `C_Secrets` gates on values, some already on out of combat,
   and not matching the published doctrine in either direction (§P.10).
3. **Protected actions** — `UseAction` forbidden, `ADDON_ACTION_FORBIDDEN` on call (§P.4).

Three systems, three different rules. Any summary that treats "addon disarmament" as one
switch — including §3, and every press piece derived from it — is wrong about this client.

**No collateral refusals.** The ordinary addon events all registered cleanly:
`AUCTION_HOUSE_SHOW`, `AUCTION_HOUSE_THROTTLED_SYSTEM_READY`, `CHAT_MSG_ADDON`,
`PLAYER_MONEY`, `BAG_UPDATE`. The refusal really is confined to the two combat-log events.

`PLAYER_REGEN_DISABLED`/`ENABLED` being allowed is worth keeping: an addon can still know
whether it is in combat, which is what lets it defer work to a safe moment rather than
discovering a restriction mid-operation.

The full allowed list is in `db.eventProbe` in the SavedVariables; the in-game print
truncates it.

---

### P.15 The Auction House numbers, measured

Run at an auction house on 2026-09-18, build 69913. These are the numbers that decide how
an addon should read the market on this client.

**Browse — the free, repeatable read:**

| Round | At | Results | Gained | `HasFullBrowseResults` |
|---|---|---|---|---|
| 1 (`updated`) | 0.26s | 500 | +500 | false |
| 2 (`requested`) | 1.50s | 500 | +0 | false |
| 3 (`added`) | 1.73s | **680** | +180 | **true** |

One `SendBrowseQuery` with empty filters, one `RequestMoreBrowseResults`, and **the entire
browsable market arrived in 3.0 seconds** — 680 item keys, flagged complete. The page size
is 500. No throttle was involved and the query can be repeated at will.

**Replicate — the expensive full read:**

- **14,389 auctions**, first and last update event both at **3.0s**
- **one** `REPLICATE_ITEM_LIST_UPDATE` event for the entire list — peak of 1 event per 0.1s
  bucket, against retail's documented ~2000 per frame. No event storm, no client stall
- **owner names are `nil`**: 0 of 500 sampled rows carried one, at retail's tuple index
  14/15. Forever inherited retail's 9.0.2 anonymisation. Listings cannot be attributed to
  a seller, so per-seller tracking is not available to an addon here
- the tuple is **retail's 18-field shape exactly**:

```
1=Worn Mace  2=133478(texture)  3=1(count)  4=1(quality)  5=true(usable)
6=1(level)   7=REQ_LEVEL_ABBR(levelType)   8=0(minBid)   9=0(minIncrement)
10=1000100(buyout)  11=0(bidAmount)  12/13=highBidder(nil)  14/15=owner(nil)
16=0(saleTime)  17=36(itemID)  18=true(hasAllInfo)
```

**Two differences from retail worth knowing:**

- **Three time-left bands, not four.** `GetTimeLeftBandInfo` answers for 1, 2 and 3 —
  1800s, 7200s, 43200s (30 minutes, 2 hours, 12 hours) — and errors on 4. Retail has a
  fourth at 48 hours. Any "about to expire" logic has a shorter ladder to work with here.
- `NUM_AUCTION_ITEMS_PER_PAGE` is still defined and still 50, a legacy constant with no
  legacy API left to page.

All seven restricted post/bid/cancel functions are present, matching retail's
`HasRestrictions` set exactly. None were called.

**The throttle is still not measured, and the event does not measure it.**
`AUCTION_HOUSE_THROTTLED_SYSTEM_READY` fired three times, and in the capture it fired
*twenty seconds before the scan was requested* — off the browse query. `IsThrottledMessage
SystemReady` read true 64 seconds after a successful scan. Both describe the message
system, not the 15-minute `ReplicateItems` throttle. The only honest test is to call
`ReplicateItems` a second time and see whether data comes back, which the probe now does
and stamps with absolute time.

### P.16 Browse is the data source, not `ReplicateItems`

On retail, the received wisdom is that you cannot build a live market view from in-game
scanning, which is why the market addons that appear to have one get their data from
outside the game. **That does not hold on this client.**

A browse query returned the complete item-key market — every item on the auction house,
with its cheapest price and total quantity — in **three seconds, in three rounds, with no
throttle**. It can be run again immediately. The expensive throttled path,
`ReplicateItems`, is what retail addons were forced onto because browse was inadequate
there; here browse alone supports a live view, and `ReplicateItems` becomes the optional
deep read for per-listing detail.

The practical consequence: an addon reading this client's market needs no out-of-game
component to get its data in. The external channel (§P.9) becomes a convenience for getting
history *out*, not a necessity.

**Caveats, because this is a beta realm.** 14,389 auctions and 680 item keys is a small
market; a launch realm will be an order of magnitude larger, and both the 500-result page
size and the three-second completion may scale badly. What generalises is the *shape*: an
unthrottled, paginated, completion-flagged browse that reports when it has everything. What
does not yet generalise is the timing. Re-measure at launch.

---

### P.17 The `ReplicateItems` throttle: real, bracketed, and silent

Three scans, each stamped with absolute time, because this build cannot remember anything
across a `/reload`:

| Scan | Time | Gap since previous | Result |
|---|---|---|---|
| 1 | 15:25:20 | — | 14,389 auctions in 3.0s |
| 2 | 15:42:47 | 1047s | 14,323 auctions in 2.7s |
| 3 | 15:45:29 | **162s** | **0 items, 0 events** |

**The throttle exists: greater than 162 seconds, at most 1047 seconds.** Retail's
documented 900 sits inside that bracket and is the obvious candidate, but 900 is not
measured here — only the bracket is.

Scan 2 is worth calling out as a near-miss. It succeeded, which looked at first like
evidence the throttle was gone; it was not. The gap was 1047 seconds, *outside* retail's
window, so a 900-second throttle predicts exactly that success. Scan 3, fired deliberately
inside the window, is the one that carries the information.

Narrowing the bracket further would take a scan roughly every fifteen minutes for an hour,
and **it would not change a single design decision**, because the browse path (§P.15) is
unthrottled and returns the complete item-key market in three seconds. `ReplicateItems` is
the optional deep read, not the data source. Left bracketed deliberately.

**The failure mode is the actionable part.** A throttled `ReplicateItems`:

- returns `true` from the call — `callOk = true`
- fires **no** `REPLICATE_ITEM_LIST_UPDATE` at all
- leaves `GetNumReplicateItems()` at 0

In other words a throttled scan is **indistinguishable from an empty auction house**.
There is no error, no event, and no API that reports the throttle —
`IsThrottledMessageSystemReady` describes the message system and read `true` throughout
(§P.15). Any addon using this path **must track its own last-scan time and refuse to call
inside its own window**, because the client will not tell it. Hitting the throttle silently
returns "the market is empty", which a naive addon would happily write over its price
history.

The 66-auction drop between scans 1 and 2 — 14,389 to 14,323 over seventeen minutes — is
incidental but useful: it is the live turnover rate on a beta realm, and a first hint at
how quickly a cached snapshot goes stale.

---

### P.18 The combat delta: the gates really do flip, except one

**[PROBE — `/fprobe combat`, run in combat on build 69913, 2026-09-18]**

`C_Secrets` gates, out of combat versus in combat:

| Gate | Out of combat | In combat |
|---|---|---|
| `ShouldAurasBeSecret()` | false | **true** |
| `ShouldCooldownsBeSecret()` | false | **true** |
| `ShouldActionCooldownBeSecret(1)` | false | **true** |
| `ShouldUnitStatsBeSecret()` | false | **true** |
| `ShouldUnitPowerBeSecret("player")` | **true** | **true** |
| `ShouldUnitThreatValuesBeSecret()` | _not captured_ | **true** |
| `ShouldUnitIdentityBeSecret("player")` | false | false |
| `ShouldUnitHealthMaxBeSecret("player")` | false | false |
| `ShouldUnitSpellCastBeSecret()` | _not captured_ | **false** |
| `ShouldUnitThreatStateBeSecret()` | _not captured_ | **false** |
| `CanCompareUnitTokens()` | true | true |
| `HasSecretRestrictions()` | true | true |
| `C_RestrictedActions.GetAddOnRestrictionState()` | 0 | **2** |
| `C_RestrictedActions.IsAddOnRestrictionActive()` | false | **true** |
| `C_CombatLog.IsCombatLogRestricted()` | true | true |
| `AreOutgoingAddonChatMessagesRestricted()` | true | true |

**So the black box is genuinely combat-scoped.** Auras, cooldowns, action cooldowns and
unit stats are all readable while nothing is happening and become secret the moment combat
starts. That is the answer §0.3 predicted and §P.3 cast doubt on, and both were partly
right: the mechanism is a combat-scoped gate, and one category ignores the gate entirely.

**The exception is `UnitPower`, which is secret in both states.** It is the one thing
Blizzard's published doctrine explicitly promises stays readable — "all class secondary
resources remain fully non-secret" — and it is the one thing that is never readable here.
Either the doctrine does not describe this client, or this is a beta bug. It has now been
measured twice, in both combat states, by gate and by value.

**The gating is finer-grained than "combat data is secret".** Three gates read *false* in
combat, and what they permit is specific:

- **Cast bars still work.** `ShouldUnitSpellCastBeSecret()` is false in combat, so an addon
  can read what a unit is casting. (`UnitCastingInfo("target")` returned `nil` in the same
  pass, but with no target — the gate is what matters.)
- **Threat state yes, threat values no.** `ShouldUnitThreatStateBeSecret()` is false while
  `ShouldUnitThreatValuesBeSecret()` is true. An addon may know *whether* it has aggro and
  not *by how much*. That is a deliberate-looking line: it kills the numeric threat meter
  while leaving the "you are about to pull" warning intact.
- **Unit identity and max health stay readable**, in both states.

So the honest summary is not "addons cannot see combat". It is that a specific list of
categories becomes secret in combat, and the list was drawn with some care.

**A fourth restriction mechanism, and this one is queryable.**
`C_RestrictedActions.GetAddOnRestrictionState()` moves 0 → 2 and
`IsAddOnRestrictionActive()` moves false → true on entering combat. That is a global
switch distinct from the per-category `C_Secrets` gates, and unlike the combat log it can
be *asked*. An addon can check whether it is currently restricted before attempting work,
rather than discovering it through a masked value.

### P.19 What the reads actually do when the gate is closed

| Read | Out of combat | In combat |
|---|---|---|
| `playerAura1` | `Seal of Righteousness` | **throws** |
| `targetAura1` | — | **throws** |
| `playerPower` | `<SECRET>` | `<SECRET>` |
| `targetHealth` | — | `<SECRET>` |
| `targetCasting` | — | `nil` |
| `spellCooldownStart` | `nil` | `nil` |

Auras do not return a secret value — they **raise**, and the error names the mechanism:

```
GetAuraDataByIndex(): Auras cannot be accessed when secret while tainted by 'ForeverProbe'
```

"while tainted by" is the important half. The restriction is scoped to *tainted execution*,
not to the data: Blizzard's own UI reads the same auras in the same combat. An addon is
refused because the call stack is the addon's.

Three different refusal shapes now, and an addon has to handle all of them: a **throw**
(auras), a **secret value** that survives `tostring()` and detonates later (power, health),
and a plain **`nil`** (cast info, cooldown start). Only the first is visible without care.

### P.20 Actions: three of five are combat-scoped

| Action | Out of combat | In combat |
|---|---|---|
| `CastSpellByName` | allowed | allowed |
| `UseAction(1)` | **FORBIDDEN** | **FORBIDDEN** |
| `EditMacro` | allowed | **BLOCKED** |
| `SetOverrideBindingClick` | allowed | **BLOCKED** |
| `SecureBtn:SetAttribute` | allowed | **allowed** |

`EditMacro` and `SetOverrideBindingClick` are blocked only in combat, which is retail's
long-standing behaviour and unremarkable. `UseAction` is forbidden in both states, which is
not.

`SecureActionButton:SetAttribute` succeeding **in combat** is the surprising one — retail
protects exactly that, and it is the mechanism every action-bar addon depends on. Recorded
as measured: the call raised no error and fired no block event. Worth re-testing before
anything is built on it, because "no error and no block event" is weaker evidence than
"the attribute took effect", and this client has already shown that a refusal can be
silent.

### P.21 A workflow constraint worth writing down

**Superseded in part by §P.27** — a per-character saved variable *does* survive a
`/reload`, so this constraint is liftable by moving the probe's DB to
`## SavedVariablesPerCharacter`. Not yet done; recorded as written.

`/fprobe report` needs both runs, and this build never reads SavedVariables back, so the
out-of-combat run does not survive a `/reload`. **Both passes have to happen in one
session**: `/fprobe`, then pull something, then `/fprobe combat`, then `/fprobe report`.
The delta above was reconstructed across captures by hand instead —
`data/ForeverProbe_2026-09-18_165528_combat-delta.lua` holds the in-combat half, and three
gates in it (`UnitSpellCast`, `UnitThreatState`, `UnitThreatValues`) have no out-of-combat
counterpart recorded because the in-game print truncated that line.

### P.22 Display brightness and contrast are addon-writable, live, at frame rate

Measured 2026-09-18 with `/fprobe video` and `/fprobe video ramp`, capture
`ForeverProbe_2026-09-18_205312.lua`. Four questions, all four answered.

**The retail CVar names are gone.** `gxBrightness`, `gxContrast` and `gxGamma` are all
**absent** on this client. Assuming them would have produced an addon that silently did
nothing — the write path returns success on a name the client does not have. The real
names came out of `ConsoleGetAllCommands()`, which returned 1902 commands, 8 of them
matching bright/contrast/gamma:

| CVar | Value | Default | Scale | Lock flags |
|---|---|---|---|---|
| `Brightness` | 50.000000 | 50.000000 | 0–100 | none |
| `Contrast` | 50.000000 | 50.000000 | 0–100 | none |
| `Gamma` | 1.000000 | 1.000000 | ~1.0 centred | none |
| `HDRBrightness` | 203 | 203 | nits | none |
| `HDRPeakBrightness` | 400 | 400 | nits | none |
| `useHDRBrightness` | 0 | 0 | bool | none |
| `useHDRPeakBrightness` | 0 | 0 | bool | none |
| `questTextContrast` | 4 | 0 | UI text, unrelated | none |

`C_CVar.GetCVarInfo` reports `isLockedFromUser`, `isSecure` and `isReadOnly` all **false**
on every one of them. The 0–100 scale is worth noting: community advice phrased as
"contrast 60, brightness 40" maps onto these CVars directly, with no conversion.

**Writes land, through both setters.** Every CVar above was nudged and read back, via the
documented `C_CVar.SetCVar` and the undocumented global `SetCVar` separately. All sixteen
writes took effect and read back exactly — `Brightness` 50 → 45 → readback 45.0000, and so
on. No `ADDON_ACTION_BLOCKED`, no `ADDON_ACTION_FORBIDDEN`, no error. Both setters behave
identically here; there is no protection difference between them.

**A write is a cheap live post-process, not a device restart.** This is the finding that
matters, because it is what makes a smooth ease possible rather than a slideshow.
`/fprobe video ramp` swept `Brightness` 50 → 30 → 50 over four seconds, writing from
`OnUpdate` every frame:

```
443 frames in 4.01s (111/s), 442 writes, 0 failures
frame gap min 8.0 ms, max 31.0 ms
```

442 CVar writes cost nothing measurable. The frame rate stayed at 111/s throughout and the
worst single gap was 31 ms — normal frame variance, not a hitch. The screen changed
visibly and smoothly (confirmed by eye; no Lua read reports what the monitor is doing, so
that half stays a human observation).

**Windowed mode is fine.** Measured at `gxMaximize=1`, `gxWindow=nil`,
`gxWindowedResolution=auto`, window size 1920x1080 — maximized windowed, not exclusive
fullscreen. The old "gamma is fullscreen-only" limitation does not apply to `Brightness`
and `Contrast` here. Exclusive fullscreen is untested, but the restrictive case is the one
that was in doubt and it passed.

**Not yet measured: combat.** `/fprobe video` in combat is a single command and has not
been run. Given `SetCVar` is not a protected function and none of these carry lock flags,
a block is unlikely, but P.20 has already shown this client's action gating does not always
match retail. Until it is run, an addon should freeze on `PLAYER_REGEN_DISABLED` rather
than assume.

So an addon may drive display brightness and contrast smoothly, at frame rate, from Lua.

---

### P.23 SavedVariables: the account-wide path restores nothing, and the addon-side theory is wrong

**[PROBE — 2026-09-20, build 1.60.1.69913, capture
`research/captures/ForeverProbe_2026-09-20_121944_post-sv-port-secrets.lua`]** This
settles §12 explanation C. Read it together with **§P.27**, which was measured forty
minutes later and narrows explanation A to the account-wide path only — two of the
statements below are corrected there, in place.

`addons/ForeverProbe/SavedVars.lua` watched four saved globals bound four different ways,
recording each table's address at four phases. The addresses are the measurement:

| Global | Binding idiom | file scope | ADDON_LOADED | PLAYER_LOGIN | ENTERING_WORLD |
|---|---|---|---|---|---|
| `ForeverProbeDB` | `X = X or {}` at file scope | **nil** | `…513870`, 0 keys | `…513870` | `…513870` |
| `ForeverProbeBind` | bound only on `ADDON_LOADED` | **nil** | **nil** before bind | `…51ADE0` | `…51ADE0` |
| `ForeverProbeClobber` | reassigned at file scope | **nil** | `…448BBB0`, 1 key | `…448BBB0` | `…448BBB0` |
| `ForeverProbeChar` | per-character, on `ADDON_LOADED` | **nil** | **nil** before bind | `…51AE30` | `…51AE30` |

Both files had been written by the previous session and were on disk when this one started
— the account-wide one at 13.2 KB, the per-character one at 0.1 KB.

**Explanation A is confirmed: the client restores nothing.** Every global is `nil` at file
scope, which is the earliest moment addon code can look, and `ForeverProbeDB` is a table
with **zero keys** by `ADDON_LOADED`. A table with zero keys is one this addon just created
with `or {}`, not one the client filled.

**Explanation C is refuted.** `ForeverProbeBind` is the exact idiom the
forever-quest-markers PR prescribes — never assigned at file scope, bound and mutated only
inside `ADDON_LOADED`. It was `nil` when that handler looked. Binding on `ADDON_LOADED`
does not recover anything, because there is nothing there to recover. The clobber control
behaved no differently from the safe idioms, which is what you would expect when the
restore never happens in the first place.

**§11 item 2 is wrong for this build.** Saved variables are *not* restored before addon
Lua executes; at file scope there is nothing. And no address changes between any two
phases, so the client never swapped a global out from under the addon at any point either.

**That clears §P.9's method.** The worry recorded in §12 — that the probe's own file-scope
`local db` might have been pointing at an orphan and manufacturing the whole result — is
answered: the address is stable from `ADDON_LOADED` to logout, so the table the probe wrote
into is the table the client serialised. §P.9 stands as measured.

**Per-character looked dead too — that was wrong, see §P.27.** This run recorded
`ForeverProbeChar` as `nil` at every phase and concluded it behaved like the rest. The
conclusion did not survive: `## SavedVariablesPerCharacter` had been added to the `.toc` in
the same edit as the probe code, so **no per-character file existed on disk when this
session loaded**. The first session after declaring a new saved variable can never show
restoration, and this one was read as if it could. §P.27 is the same test run once a file
was actually there, and it comes out the other way.

**Explanation B is not just open, it is the answer** — see §P.27, which was not known
when this section was written. `ForeverProbeSeed` — the
global this addon never writes — came back `nil`, because `scripts/seed-savedvars.ps1` had
not been run. That is the remaining experiment: seed all four candidate WTF paths, restart,
`/fprobe sv`.

A note on the counter in this capture: `session` reads 3 on every writable global. That is
a bug in the probe, not three sessions — `stamp()` ran once per phase and incremented each
time. The addresses and the zero key count are the evidence; the counter is not. Fixed for
the next run.

### P.27 Per-character SavedVariables survive a `/reload` but not a restart

**[PROBE — 2026-09-20 12:43 and 13:20, build 1.60.1.69913, captures
`ForeverProbe_2026-09-20_124301_sv-restored*.lua` and `…_132303_coldstart*.lua`]**

**Read the second half of this section before acting on the first.** The 12:43 run was
taken across `/reload`s inside one client run and looked like a straightforward answer to
§12 explanation B. The 13:20 run was taken across a full client restart and does not
agree. The honest result is narrower than the first half alone suggests, and the first
write-up of this section over-claimed it.

One addon, one session, one load. Two saved globals, **bound by identical code** — both
untouched at file scope, both `X = X or {}` inside the same `ADDON_LOADED` handler. The
only difference between them is which `.toc` directive declares them, and therefore which
file on disk they live in.

`ForeverProbeChar`, declared with `## SavedVariablesPerCharacter`:

```lua
["restoredToken"]   = "124043-3623",   -- written by this addon at 12:40:43, three minutes earlier
["restoredSession"] = 33,
["session"]         = 34,
["boundAt"]         = "ADDON_LOADED",
```

`ForeverProbeBind`, declared with `## SavedVariables`, in the same addon, in the same
session:

```lua
["restoredSession"] = 0,
["session"]         = 1,
```

`restoredToken` is captured once, before this session writes anything, so a value in it can
only have come off disk. It holds a token from an earlier session, and the session counter
has accumulated to 34 across previous runs. **The per-character file is read back. The
account-wide file is not.**

**So the binding idiom was never the variable, and neither was the load order.** §P.23
controlled for the idiom and found nothing restored; this controls for it again and finds
one of two restored. What changed is the file. The bug is scoped to
`WTF\Account\<account>\SavedVariables\`, and `WTF\Account\<account>\<realm>\<character>\SavedVariables\`
works.

#### And then the cold start, which does not agree

Run again at 13:20 after the client was **fully exited and restarted**, same addon, same
character, with the previous session's file sitting on disk carrying token `124301-3338`:

```lua
ForeverProbeChar = {
    ["restoredSession"] = 0,
    ["session"]         = 1,          -- no restoredToken at all
}
```

**Nothing was restored, per-character included.** Every global is `nil` at file scope and
at `ADDON_LOADED-before-bind`, exactly as in §P.23.

So the two runs together say:

| Across | account-wide | per-character |
|---|---|---|
| `/reload`, inside one client run | not restored | **restored** |
| full client restart | not restored | **not restored** |

**What this means for an addon today.** Not what the first half of this section said. Settings
do **not** survive logging out, on either directive, so there is still no persistence story
for user configuration. What per-character buys is narrower and worth knowing anyway:
**state survives a `/reload` within a session.**

**That is not nothing — it lifts §P.21.** The two-pass probe workflow is constrained to a
single session precisely because `/reload` discards the first pass. A per-character saved
variable survives a `/reload`, so the out-of-combat and in-combat passes could be written
to one and reconciled after, instead of being reconstructed by hand across captures. That
is worth doing.

**Why the two differ is not established, and the obvious guess is wrong.** "The client
keeps globals in memory across a `/reload`" would explain the per-character result, but it
predicts that `ForeverProbeBind` survives too, in the same Lua state — and it does not. So
something is reading the per-character file on a reload and not on a cold start, or
caching it per character in a way it does not for the account file. A plausible mechanism
is that the character is not yet known at the point saved variables load on a cold start,
but that is a guess and is labelled as one.

**This also vindicates the write-once fix.** The counter and token in §P.23 were stamped
once per phase, which overwrote `previousToken` with the current session's value and
destroyed exactly this evidence. Had that bug still been in place, this run would have
printed the same ambiguous `session = 3` and the finding would have been missed again.

**§12 explanation B is answered: no.** The 13:20 cold start was the clean version of that
test — seeds were sitting at `WTF\Account\SavedVariables\` and `WTF\SavedVariables\`
and nowhere else, planted before the client started. `ForeverProbeSeed` came back `nil`,
and both seed files are still on disk untouched afterwards. The client neither reads nor
writes those two paths. There is no exotic WTF folder that works.

### P.24 The porting checks, measured

**[PROBE — same run.]** `/fprobe port`, on Abla-Imperial, realm "Classic Beta PvE" (id
4618), build 69913, interface 16001.

**The interface formula holds.** `GetBuildInfo()` gives version `1.60.1` and interface
`16001`; `%d%02d%02d` of the triple computes `16001`; `interfaceFormulaHolds` is **true**.
§9 confirmed on the client.

**There is no Forever `WOW_PROJECT_*` constant, exactly as §10 reported.** The global table
holds precisely three:

| Constant | Value |
|---|---|
| `WOW_PROJECT_ID` | **1** |
| `WOW_PROJECT_MAINLINE` | 1 |
| `WOW_PROJECT_CLASSIC` | 2 |

So `WOW_PROJECT_ID == WOW_PROJECT_MAINLINE` is **true** on this client and
`== WOW_PROJECT_CLASSIC` is **false**, on a client that is on the Classic progression
line. There is nothing to detect Forever with. `project-id-detection` is the right lint.

**`camelot` is visible in the client's own global table.** Scanning `_G` for game-type
shaped names returned `C_GameRules`, `GameRulesUtil`, the four `WarGameType` functions —
and **`CamelotBankPanelItemButtonMixin`**. That is first-party confirmation of the codename
from inside the running client, not from a branch reading. Note it is a *mixin in the UI
code*, not a game-type accessor: nothing in `_G` reports the game type as a value, which
is consistent with §10's "Blizzard gates on the `.toc` directive instead".

**`GetCurrentRegionName()` returns an empty string.** §11 item 3 confirmed. `GetCurrentRegion()`
returns **90**, which is not a retail region id (retail uses 1–5). Both are worth a wide
berth.

**`GetNamePlateForUnit()` raises on target-of-target, deliberately.** §11 item 4 confirmed,
and the error message shows it is a designed refusal rather than an accident:

> `bad argument #1 to '?' (Target-of-target unit tokens are not allowed for this call. -
> Usage: local nameplate = C_NamePlate.GetNamePlateForUnit(unitToken [, includeForbidden]))`

`target` returned a frame; `focus`, `mouseover` and `nameplate1` returned `nil` cleanly.
So the raise is specific to the token, not to the call.

**Realm identity: not settled, and one anomaly.** `GetRealmName()` is "Classic Beta PvE",
`GetNormalizedRealmName()` is "ClassicBetaPvE", `GetRealmID()` is 4618, and the player GUID
is `Player-4618-00C20142` — all stable-looking within one session, so §11 item 5 is not
reproduced here and cannot be from a single read. But two things are odd and want another
look:

- `UnitName("player")` returned **"Abla Imperial"**, with a space, where the character's
  WTF folder is `Abla-Imperial`. The port diary that reported realm-name instability gave
  `"Per Ro - PvP"` as their broken key — a name with the same inserted space. That is a
  shape, not a conclusion.
- The WTF path uses `…\<account>\70\Abla-Imperial\…`: the realm directory is **`70`**, not
  any form of the realm name. So the on-disk realm identity and the Lua-visible realm name
  genuinely do not match, which is at least adjacent to what was reported.

Re-run 13:20 with both return values captured: `UnitFullName("player")` gives
**`Abla Imperial` / `ClassicBetaPvE`**. So the realm half is normal and stable, and the
space is genuinely in the *character name* rather than being a realm string leaking into
it — this client appears to allow a two-part name, which is itself worth knowing for
anything that parses `name-realm`. `GetRealmName`, `GetNormalizedRealmName`, `GetRealmID`
and the GUID all agree with each other across sessions.

**§11 item 5 is not reproduced.** Realm identity looks stable here. Their AceDB key
`"Per Ro - PvP"` now reads like the same two-part-name effect rather than realm
instability: a name with a space, split by a key builder that assumed one word.

### P.25 Unit health IS secret, out of combat — and `type()` does not reveal it

**[PROBE — same run, `/fprobe secrets` out of combat and again in combat.]** This is a
correction to this document, and it means §14 was substantially right on the point it made.

Out of combat, with no target; in combat, with a target:

| Read | player, out of combat | player, in combat | target, in combat |
|---|---|---|---|
| `UnitHealth` | **secret** | **secret** | **secret** |
| `UnitHealthMax` | plain | plain | **secret** |
| `UnitPower` | **secret** | **secret** | **secret** |
| `UnitPowerMax` | plain | plain | **secret** |
| `UnitLevel` | plain | plain | plain |
| `UnitName`, `UnitGUID`, `UnitClass` | plain | plain | plain |

Three findings, in order of how much they change.

**1. `UnitHealth("player")` is secret out of combat.** This document did not have that.
§P.3 measured `UnitPower` secret at all times and framed the doctrine as backwards for
power specifically; health was never separately measured in both states. It behaves exactly
like power. The always-on health gate reported in §14 is **confirmed for `UnitHealth`**.

**2. `type()` reports "number" on a secret, and every numeric operation throws.** For every
secret read above, `type(value)` is `"number"`, and each of these throws in its own `pcall`:

```lua
value > 0      -- throws
value + 1      -- throws
value == value -- throws
```

Equality throwing is the nasty one, because `if value == nil then` is the guard people
write by reflex and it is not safe. **`type()` is not a secrecy check and neither is a
comparison against nil — only `issecretvalue()` is.** This is the fourth failure shape,
and §14's description of it — "typed as a number" but not comparable — turns out to be
precisely accurate.

`tostring()` succeeded on every secret and returned a **secret string** every time
(`tostringSecret` true), which re-confirms §P.2 on a second class of read.

**3. The gate is per unit, not only per category and combat state.** The player's own
`UnitHealthMax` and `UnitPowerMax` stay plain in both combat states, while the target's are
secret. So a health *fraction* is impossible for a target and half-possible for the player:
the numerator is secret either way, and only the player's denominator is readable.

**This corrects `research/restrictions.yaml`.** The `unit-power-secrecy` entry listed
`UnitPowerMax` alongside `UnitPower` as secret at all times. On the player it is not
secret in either state. The entry has been split accordingly.

**One confound, stated plainly.** The out-of-combat pass had no target, so there are no
out-of-combat target rows. Every target reading here was taken in combat, which means
"secret because in combat" and "secret because it is another unit" are **not separated**
by this run. Repeating `/fprobe secrets` out of combat with a target selected costs one
command and would separate them.

### P.26 The restriction surface is a documented taxonomy, and it is generable

**[PROBE — same run, `/fprobe docs secrets`.]** §13's claim reproduces in substance, and
the shape is more useful than the number.

**29,416 documented entries walked, 5,145 of them carry a Secret-shaped key**, spread over
**38 distinct key names**. The reported figure of 4,025 does not reproduce exactly; the
closest bucket is the 4,076 *functions* that carry one. Different build or different
counting — the discrepancy is not worth chasing, because the taxonomy is the finding.

Discovering the key name rather than assuming it was load-bearing. There is no plain
`Secret` field: the most common keys are `SecretArguments` (3,929 entries) and
`NeverSecret` (942). Guessing `Secret` would have counted 12 and read as "the report is
wrong".

By kind: Function 4,076 · Payload 832 · Event 93 · Field 74 · Argument 50 · Return 20.

The conditional keys are the interesting part, because they are the restriction model
written down by Blizzard rather than inferred by us:

| Key | Entries |
|---|---|
| `SecretInChatMessagingLockdown` | 99 |
| `SecretReturnsForAspect` | 92 |
| `SecretWhenUnitStatsRestricted` | 58 |
| `SecretArgumentsAddAspect` | 55 |
| `ConstSecretAccessor` | 46 |
| `SecretWhenUnitIdentityRestricted` | 34 |
| `SecretWhenAnchoringSecret` | 23 |
| `SecretWhenUnitAuraRestricted` | 22 |
| `SecretWhenUnitSpellCastRestricted` | 21 |
| `ConditionalSecret` | 19 |
| `SecretReturns` | 18 |
| `ReturnsNeverSecret` | 16 |
| `SecretWhenCooldownsRestricted` | 15 |
| `SecretValue` | 12 |
| `SecretWhenCurveSecret` | 8 |
| `SecretWhenUnitPowerRestricted`, `SecretPayloads` | 7 each |
| **`SecretWhenInCombat`** | **4** |
| `SecretWhenNumericFormatterSecret`, `RequiresNonSecretAura`, `SecretWhenLuaTableHasSecretKeys`, `SecretWhenEncounterEvent`, `SecretWhenLossOfControlInfoRestricted` | 3 each |
| `SecretWhenUnitThreatValuesRestricted`, `SecretWhenUnitThreatStateRestricted`, `SecretInActivePvPMatch`, `NeverSecretContents`, `SecretWhenUnitPossessionRestricted`, `SecretWhenTotemSlotSecret` | 2 each |
| `SecretWhenUnitHealthMaxRestricted`, `SecretWhenUnitComparisonRestricted`, `SecretWhenAurasRestricted`, `SecretWhenUnitNameIdentityRestricted`, `SecretWhenUnitPowerMaxRestricted`, `ConditionalSecretContents` | 1 each |

Three things follow.

**The per-category gating model this repo measured is Blizzard's own model.** There is a
distinct condition per category — power, power max, aura, auras, cooldowns, stats,
identity, name identity, spell cast, threat state, threat values, health max, possession,
loss of control, totem slot. §P.10 and §P.18 inferred that shape from the outside; here it
is, named.

**`SecretWhenInCombat` applies to only four entries.** Combat is a minor axis in this
system, not the organising one — which is the same conclusion §P.3 and §P.25 reached by
measurement, and the opposite of how the restriction is usually described in press
coverage.

**`SecretWhenUnitHealthMaxRestricted` exists as its own condition**, separate from anything
for health itself. That is exactly the split §P.25 measured: health and health-max are
gated independently.

**Consequence for this repo.** The machine-readable half of `research/restrictions.yaml`
can be *generated* from a documentation dump rather than hand-maintained one probe at a
time, with the hand-written verdicts and prose layered on top. `/fprobe docs dump` already
captures the projection, and `projectField`/`projectFunction` now carry a `Secret` field —
which, given this taxonomy, should be widened to carry every key matching the pattern. Not
done yet; recorded here as the design that the measurement now supports.

### P.28 The secrecy axis is the unit, not combat

**[PROBE — 2026-09-20 13:20, `/fprobe secrets` out of combat with a target selected, run
twice: once on a friendly NPC and once on a hostile one.]** This closes the confound
§P.25 left open, and it moves the answer.

§P.25 could not separate "secret because in combat" from "secret because it is another
unit", because the out-of-combat pass had no target. With a target selected and **no
combat at all**:

| Read | player | target (friendly NPC) | target (hostile) |
|---|---|---|---|
| `UnitHealth` | **secret** | **secret** | **secret** |
| `UnitHealthMax` | plain (58) | **secret** | **secret** |
| `UnitPower` | **secret** | **secret** | **secret** |
| `UnitPowerMax` | plain (110) | **secret** | **secret** |
| `UnitLevel` | plain | plain (5) | plain (1) |
| `UnitName`, `UnitGUID`, `UnitClass` | plain | plain | plain |

**Combat is not the axis. The unit is.** A target's max health and max power are secret
standing in Elwynn Forest with nothing happening, and hostility makes no difference either
— a friendly quest NPC and a wolf give identical results. §P.25 recorded these as
`in-combat` only because that was the only state in which a target existed.

`research/restrictions.yaml`'s `other-unit-max-values` entry has been moved from
`in-combat` to `always` on the strength of this.

**What an addon can actually read about another unit:** its level, name, GUID and class.
Nothing numeric about its health or power, in any combat state. A target health bar is not
buildable; a target *nameplate* with name, level and class is.

**And the player keeps its own denominators.** `UnitHealthMax` and `UnitPowerMax` are plain
on the player in every state measured, while `UnitHealth` and `UnitPower` are secret in
every state. So even for yourself the fraction is unavailable — you can read the maximum
and never the current value.

#### Concatenation does not throw, which is how the taint spreads

The per-operation flags are worth reading carefully. For every secret value, across both
runs:

```
S . . . c        S = issecretvalue    > = comparison   + = arithmetic
                 = = equality         c = concatenation
                 . = that operation threw
```

Comparison, arithmetic **and equality** all throw. Concatenation does **not** — `"" .. value`
succeeds and hands back a secret string, which is §P.2's contagion arriving through a
second door. Together with `tostring()`, that is two silent conversions and three loud
ones, and the silent pair are the ones an addon writes by accident in a `print` or a
`format`.

This is also a correction to how the probe measured it. Until this run the concat test was
`"" .. tostring(value)`, which tests the `tostring` trap rather than concatenation; raw
concatenation had never actually been tried.

### P.13 Consequences of P.1

- **Addons that do not read the combat log are unaffected.** Auction data, money, bags and
  addon messages are all still available; the refusal is scoped to the combat log itself.
- **Any addon built on combat-log parsing is dead on this client** — damage meters, parse
  trackers, log uploaders. Not degraded: it cannot receive the event at all.
- **`CleanCombatLog` (§5) is answered.** That developer is testing whether Forever permits
  `COMBAT_LOG_EVENT_UNFILTERED`. It does not permit even listening. No need to keep
  watching the repo for this.
- **Blizzard's own damage meter is the only route to combat data**, which is consistent
  with Jones saying they are shipping one (§1) and with `C_DamageMeter` being present
  (§0.3).

### P.14 How the scope of P.1 was established

`/fprobe events` walks the neighbourhood of the refusal and attributes each result, which
is what settles whether the rule is "no combat log" or "no combat information": it tries
`COMBAT_LOG_EVENT` as well as the unfiltered form, combat state events, the unit events
the doctrine names, and a spread of ordinary addon events
(`AUCTION_HOUSE_SHOW`, `AUCTION_HOUSE_THROTTLED_SYSTEM_READY`,
`CHAT_MSG_ADDON`, `PLAYER_MONEY`, `BAG_UPDATE`) to check for collateral refusals. The
result is §P.12.

The probe no longer registers the combat log at load. The answer is in, and repeating it
every login only trains the player to dismiss a dialog that is a result.

---

## 0. The client itself, measured (2026-09-18)

**[MEASURED — a third-party capture of the live beta client, fetched and queried directly
here; not probe output]**
[Thunderz96/forever-addon-kit](https://github.com/Thunderz96/forever-addon-kit), day-one
findings against the Forever beta. The README and `data/forever_api.json` (765 KB) were
both downloaded on 2026-09-18 and the JSON queried locally, so the surface counts below
are read off the capture rather than taken from their prose.

The capture's own header: version `1.60.1`, build `69893`, interface **`16001`**,
`project = 1` (`WOW_PROJECT_MAINLINE`), locale enUS. It contains 6,045 global functions,
11,417 named frames and 269 `C_*` namespaces.

**Standing of this evidence.** One developer's capture method, not independently
reproduced. It is corroborated on the "Retail API on interface 16001" point by two
unrelated porting efforts (guildos issues #7 and #9) and on the missing
`loadstring_untainted` by GSE issue #2110. It is a *static name* capture: it proves a
function exists, not that calling it is permitted, not what it returns, and not what is
gated at runtime. It also describes a day-one beta build with acknowledged bugs. It ranks
above all press reporting in this document and below §P, which is probe output from a
client running one build later.

### 0.1 The Auction House API this client ships

`C_AuctionHouse` is present with **85 functions**: the full modern model, including the
bulk-read path (`ReplicateItems`, `GetNumReplicateItems`, `GetReplicateItemInfo`,
`GetReplicateItemLink`, `GetReplicateItemTimeLeft`), search (`SendBrowseQuery`,
`SendSearchQuery`, `RequestMoreBrowseResults`, `HasFullBrowseResults`), the
commodity/item split (`GetCommoditySearchResultInfo`, `GetItemSearchResultInfo`,
`GetItemCommodityStatus`, `PostCommodity`, `PostItem`), item keys (`GetItemKeyFromItem`,
`MakeItemKey`, `SearchForItemKeys`), and the throttle probe
`IsThrottledMessageSystemReady`.

The Classic-era API is **gone**: `QueryAuctionItems`, `CanSendAuctionQuery`,
`GetNumAuctionItems`, `GetAuctionItemInfo`, `GetAuctionSellItemInfo`, `StartAuction` and
`PlaceAuctionBid` are all absent.

**Consequence.** Auction House code for this client is a **Retail port, not a Classic
one** — the modern namespace with commodities. No Auction House function appears in any
restriction surface (§0.3). What this capture cannot supply is any *number*: scan throttle,
result caps, whether `ReplicateItems` returns owner names. Only the probe answers those,
and it does in §P.15 and §P.17.

### 0.2 The client boundary: what can cross it

| Channel | State |
|---|---|
| `io`, `os`, `dofile`, `loadfile`, `load` | **absent** — the sandbox is intact, no direct file access |
| `loadstring` | present (`loadstring_untainted` absent, which is a separate beta bug) |
| `C_EncodingUtil` | **present, 10 functions** — JSON and CBOR both ways, base64, hex, string compress/decompress |
| `C_CVar` | present, 12 functions incl. `RegisterCVar`, `SetTempCVar`, `GetCVarBitfield`; `GetCVar`/`SetCVar` also global |
| `C_ChatInfo` | present, 45 functions incl. `SendAddonMessage`, `SendAddonMessageLogged`, `RegisterAddonMessagePrefix`, plus new restriction probes `AreOutgoingAddonChatMessagesRestricted` and `InChatMessagingLockdown` |
| `CopyToClipboard` | present |
| `C_FileSystem`, `C_Clipboard` | absent |
| `C_System` | one function, `GetFrameStack` |

`C_EncodingUtil` is the find. It changes the shape of any out-of-game data channel: the
inbound generated `.lua` file and the outbound SavedVariables blob stop being hand-rolled
Lua literals and become a real wire format, with compression, that both sides can agree on.
The same goes for an addon-message sideband, which was previously unattractive largely
because of payload encoding.

**Two blockers, both reported as beta bugs rather than policy:**

1. **SavedVariables are written but never read back.** Proven by the kit with a pre-seeded
   file: the global was `nil` from main chunk to logout, in every candidate WTF folder.
   The normal write-now / read-next-launch loop is dead in this build. Note the asymmetry
   — this breaks the *in-client* round trip, not the outbound half that an external reader
   cares about, and those are worth telling apart. The probe now does.
2. **`ReloadUI()` is protected.** An addon cannot reload itself; a human must type
   `/reload`. That is what stops a fully unattended in-client loop, and it is the binding
   constraint on any out-of-game channel — not the sandbox.

The working inbound pattern is unchanged and now has a second independent implementation:
an external process writes Lua into the AddOns folder and the client executes it as addon
code at load (the kit's `ForeverCompat` `seeds/` plus its own watcher scripts). That is the
same mechanism `ExternalData.lua` tests here, independently arrived at.

### 0.3 The restriction surface

`C_Secrets` is present with **27 functions**, and every one of them is unit-, spell- or
combat-scoped: `ShouldAurasBeSecret`, `ShouldCooldownsBeSecret`, `ShouldUnitPowerBeSecret`,
`ShouldUnitThreatValuesBeSecret`, `ShouldUnitIdentityBeSecret`, `HasSecretRestrictions`
and so on. **Nothing in the secrecy surface touches the Auction House, CVars, addon
messages or encoding.** `C_RestrictedActions` (3 functions), `C_CombatLog` with
`IsCombatLogRestricted`, and a first-party `C_DamageMeter` (8 functions) are all present.

Crucially the restriction is a *gate*, not a removal: per the kit, while
`C_Secrets.ShouldAurasBeSecret()` is true, every aura read from addon code throws. A gate
that can be asked its own state is a much cheaper answer to combat-only-vs-always-on than
diffing masked values — the probe calls all of them in both combat states and prints the
delta.

**§P.3 has since made the expected answer wrong.** Out of combat on a live client,
`HasSecretRestrictions()` is already true and `UnitPower("player")` already returns a
secret, while auras and cooldowns do not. The gates are not a single combat-scoped switch,
and this section's "if the gates read false out of combat" framing should not be relied
on.

One practical consequence for the probe, also corrected by measurement: a secret value does
**not** reliably throw on `tostring()` — it returns a secret *string*, and the throw
happens later, wherever that string is next indexed. See §P.2.

### 0.4 `C_AssistedCombat` is present

`C_AssistedCombat` exists on this build with four functions: `IsAvailable`,
`GetRotationSpells`, `GetNextCastSpell`, `GetActionSpell` — Blizzard's own rotation-assist
API, which reports what to cast next without the addon reading combat state at all.

It is **inert on this build**: §P.6 measured `IsAvailable()` returning false and
`GetRotationSpells()` returning 0 entries. The probe calls its two no-argument functions
and records what they return. Recorded because the record should be accurate; nothing about
what it might permit an addon to do has been measured, because it currently does nothing.

### 0.5 The Classic globals are gone

`UnitAura`, `GetSpellCooldown`, `GetSpellInfo`, `GetItemInfo`, `GetSpecialization`,
`GetTalentInfo`, `GetMerchantItemInfo` and `CombatLogGetCurrentEventInfo` are all absent;
their `C_*` equivalents (`C_UnitAuras`, `C_Spell`, `C_Item`, `C_Traits`) are present.
`CombatLogGetCurrentEventInfo` being absent matters on its own: the combat-log event can
fire with nothing on the other side able to read it, and "never fires" and "fires but is
unreadable" are different failure modes. §P.1 settles which one this client has: the
registration itself is refused.

Two more facts that shape any addon written here, both from the kit and both about
developer experience rather than policy: registering an event this client does not know
**throws and aborts the rest of the file**, and after 100 Lua errors in a session the
client stops delivering errors to any handler. The probe now wraps every registration in
`pcall` for the first reason.

---

## 1. Blizzard has now said on camera that the restriction is on the *read* side

**[PRIMARY — transcript supplied to this document; video title fetched, channel and
publish date not independently verified]**
[YouTube, "World of Warcraft: Forever Devs Answer Our Biggest Questions at BlizzCon"](https://www.youtube.com/watch?v=3KFiHfNIBE8),
0:15:47–0:17:05. Speakers: Tim Jones (lead Classic designer) and Nora Mills.

Jones: addons *are* supported in Forever; there will be "parity between certain
restrictions that add-ons [have] **in terms of the information that add-ons have access
to**"; "we'll probably have a lot of parity between how mainline handles add-ons"; players
keep "full access to customized UI".

Jones, same answer: Blizzard is "investing in players having the ability to have a damage
meter supported by us, a cooldown manager within World of Warcraft: Forever".

Mills: the goal is to stop addons having "too much power and control over a player's
experience" such that they "can be weaponized" or trivialize what players engage with.

**Why this is decisive.** It closes the joint everything else hung on. Until now the
Midnight doctrine (§3) was a *retail* document that *press* said Forever inherits (§6). A
Blizzard developer has now stated the inheritance himself, and stated it about
*information access* — the read side, not the execute side. The read side is the half that
kills a rotation helper: the problem is not being unable to press the button, it is being
unable to see target auras, cooldown state, or the combat log in order to decide what to
recommend.

**Corroborating tell.** You do not ship a first-party cooldown manager if addons can still
read cooldowns. Blizzard building its own damage meter *and* cooldown manager for Forever
is an implicit statement that the addon-side versions of both are going away. Mills's
"trivializing" line describes a rotation helper almost exactly.

**What it still does not settle.**
- Hedged throughout: "certain restrictions", "probably", "a lot of parity". No published
  restriction list or allow-list.
- Combat-only vs always-on is not addressed. §P.18 and §P.19 answer it by measurement, and
  the answer is neither: most gates are combat-scoped, `UnitPower` is not.
- A first-party cooldown manager is a *product*, not an API an addon could build against.
- Nothing here touches the Auction House or out-of-game export, and Jones's "full access to
  customized UI" line suggests neither is a target.

---

## 2. Addons exist in Forever (the execute-side line)

**[PRIMARY]** [Kotaku, 2026-09-14, Rebekah Valentine](https://kotaku.com/new-things-learned-world-of-warcraft-forever-2000734005)
— interview at BlizzCon 2026 with Tim Jones and lead encounter designer Mike Nuthals.

Nuthals says Forever carries over retail's in-combat addon disarmament: players will not
have access to computational addons that programmatically automate marking or
communicating for players.

Read on its own this is the familiar execute-side rule, which would have left rotation
helpers legal. §1 supersedes that reading. The "in-game **or** in-combat" ambiguity in
Nuthals's phrasing is still unresolved and still matters — it is the same combat-only vs
always-on question.

No mention of the Auction House, economy data, companion apps, or data export.

---

## 3. The doctrine itself

**[PRIMARY]** [Blizzard news, Ion Hazzikostas, Game Director — "Combat Philosophy and Addon
Disarmament in Midnight"](https://news.blizzard.com/en-us/article/24246290/combat-philosophy-and-addon-disarmament-in-midnight)

Written for **Midnight (retail)**. Per §1, Forever inherits at least "a lot of" it.

The model: combat events are a black box. Addons can change the size or shape of the box
and paint it a different color, but cannot look inside.

Specifically removed:
- Addons cannot know whether specific buffs or debuffs are active on targets
- Addons cannot determine cooldown states of abilities
- Addons cannot parse combat events in real time to drive automated recommendations

Explicitly still allowed:
- Changing location, size, shape and appearance of buffs, debuffs, nameplates, cast bars
- Aesthetic presentation of information
- All class secondary resources (Runes, Holy Power, etc.) remain fully non-secret

Stated goal: addons should no longer offer a competitive advantage in WoW combat, and
should remain robust tools for aesthetic customization and personalized presentation.

The post does **not** say whether the box is closed only during combat or at all times, and
does not name WeakAuras, Hekili, rotation helpers, the Auction House, or out-of-game data.

---

## 4. Third-party addons sunsetting on retail Midnight

**[UNVERIFIED]** Hekili's maintainer announced the addon sunsets with retail's Midnight
12.0 pre-patch, because the new APIs remove the spell-simulation hooks it relied on.
Surfaced as https://x.com/hekili808/status/1973479282006696123 with a reported date of
2026-01-20, which looks inconsistent with the status ID. Treat as corroboration, not fact,
until fetched directly. This is about retail, not Forever.

**[UNVERIFIED]** A successor called "HekiLight" built on Blizzard's own `C_AssistedCombat`
API was mentioned for retail Midnight. No source claims it targets Forever. Blizzard
shipping an official rotation assist while disarming third-party ones is the pattern to
watch, which is why `C_AssistedCombat` is in the probe's scan list; §0.4 and §P.6 record
what it actually does on this build, which is nothing.

**[UNVERIFIED]** https://us.forums.blizzard.com/en/wow/t/addonsweakauras-restricted/2350657
— official forum thread about WeakAuras being restricted in Forever. Not yet fetched. No
allow-list published.

---

## 5. The one live empirical signal from another developer

**[UNVERIFIED]** https://github.com/Caeth/CleanCombatLog — "Combat log addon for world of
warcraft: forever", a developer actively testing whether Forever permits
`COMBAT_LOG_EVENT_UNFILTERED`.

**Answered 2026-09-18 by probe output — see §P.1.** Forever does not permit an addon to
register `COMBAT_LOG_EVENT_UNFILTERED` at all, out of combat or otherwise, and
`CombatLogGetCurrentEventInfo` is absent from the build. The refusal is harder than "fires
with fewer fields": there is nothing to subscribe to.

---

## 6. No longer load-bearing

**[REPORTED, NOT FETCHED]** [GamesRadar](https://www.gamesradar.com/games/world-of-warcraft/world-of-warcraft-forever-takes-page-out-of-retails-book-as-blizzard-confirms-access-to-add-ons-will-be-restricted-in-the-throwback-mmo/)
— press reporting that Blizzard confirmed Forever restricts computational
combat/communication addons as retail does.

This was previously the only thing connecting the Midnight doctrine to Forever, and was
flagged for verification for that reason. §1 replaces it with a dev statement. Fetching it
is now optional and would only add a second-hand paraphrase.

---

## 8. Checked and not relevant

**[EXCLUDED]** [Marlamin, 2026-09-12](https://blog.marlam.in/datamining-forever/) — his
personal datamining and spoiler policy for Forever. Nothing on addons, the Lua API, the
Auction House, or data export. Was initially cited as the best technical lead on the basis
of a search snippet; that was wrong. Only recheck if he posts new client-file findings.

**[EXCLUDED]** [IGN, 2026-09-13, Michael Peyton](https://www.ign.com/articles/world-of-warcraft-forever-wow-2-unlikely)
— Zierhut and Nuthals on why Forever makes a WoW 2 unnecessary. Engine and server
efficiency, raid sizes (10/20/40), an itemization pass, a campfire grouping feature. Zero
addon content.

**[EXCLUDED]** MMO-Champion "No addons in Forever?" thread — unsourced speculation. US and
EU forum threads asking for addon status — no staff reply.

**[EXCLUDED]** Unattributed claim that item and loot data is being obfuscated client-side
to defeat datamining, attributed to Wowhead / Warcraft Tavern off a dev interview. Never
confirmed firsthand. Relevant to a notification addon if true.

---

## 9. Packaging and the `.toc`: `16001` is derived, and one file covers every flavour

**[PRIMARY]** Two maintained retail addons added Forever to their `.toc` in the first days
of the beta, and both wrote down how. Fetched and read directly.

- [McTalian-WoW-Addons/RPGLootFeed#617](https://github.com/McTalian-WoW-Addons/RPGLootFeed/pull/617),
  merged 2026-09-17, shipped in v1.36.1 — credit to the RPGLootFeed maintainers.
- [wyomarus/Wayfinder#8](https://github.com/wyomarus/Wayfinder/pull/8) — a second,
  independent worked example, which confirms the same interface number "directly against
  Blizzard's public version CDN" and moves to `.pkgmeta` + `@project-version@` packaging.

Three things they settle between them. None needs a running client, which is why they are
recorded here rather than queued for the probe.

**The number is derived, not assigned.** From RPGLootFeed#617:

> "WoW Forever beta (wow_classic_beta, 1.60.1) first appeared on wago.tools today;
> interface version is 16001."

> "BuildInfo.GetInterfaceVersion formats %d%02d%02d, so 1.60.1 -> 16001."

So `16001` is a function of the version triple and will move with it. An addon that
hardcodes it is hardcoding 1.60.1, not "Forever" — `/fprobe port` recomputes the formula
against the client's own `GetBuildInfo()` every run, so a build bump shows up as a
disagreement rather than as silence.

**One `.toc` carries every flavour.** RPGLootFeed "packages a single TOC carrying all six
interface versions; no per-flavor TOC splitting is involved". A comma-separated
`## Interface` line is the answer; a `-Mainline.toc` / `-Classic.toc` split is not needed,
and this plugin should not suggest one.

**Every ordinal interface comparison silently skips Forever.** This is the one that costs
an afternoon, and it is a build-tooling bug rather than an addon bug. RPGLootFeed's
nightly `.toc` updater reported no work to do:

> "skips a beta whose interface is numerically lower than its live product
> (50504 > 16001), so the nightly toc-updater reports no updates."

16001 sits below every live product number — retail is 120100 and climbing. Any updater,
CI check or compatibility gate that treats a higher interface as a newer client classifies
Forever as stale, does nothing, and reports success. The in-addon form of the same mistake,
`select(4, GetBuildInfo()) >= 100000`, is §0.5 and the linter's `version-check-trap`; the
build-tooling form is new here and has no automated check, because it lives in whatever
CI the addon happens to use.

**Distribution.** **[REPORTED]**
[Auctioneer Crusade on CurseForge](https://www.curseforge.com/wow/addons/auctioneer-crusade-forever),
updated 2026-09-18, ships under a distinct **Forever flavour** with its own download
channel. This supersedes the earlier position that no addon site carried one. What
CurseForge's Forever channel accepts in a `.toc` has not been checked here.

---

## 10. Client identity: the game type is `camelot`, and there is no `WOW_PROJECT_*` for it

**[PRIMARY]** [fooxytv/CooldownManagerClassic#80](https://github.com/fooxytv/CooldownManagerClassic/issues/80)
— the maintainer reading the `forever` branch of Blizzard's own published interface code.
The reading is theirs; it is quoted here because it answers a question this plugin could
not otherwise answer at all.

> "Interface version `16001`, from game version 1.60.1." / "Game type `camelot`"

> "`Blizzard_CooldownViewer` is `AllowLoadGameType: standard, camelot`"

> "No new `WOW_PROJECT_*` constant appears anywhere in the `forever` branch"

> "Forever runs the modern API surface. `C_Spell` appears in 113 files on that branch,
> `C_SpellBook` in 40, `C_UnitAuras` in 29." / "It rides the `wow_classic` progression
> line but shares Mainline's UI architecture."

Corroborated independently by [danielcosta42/guildos#18](https://github.com/danielcosta42/guildos/pull/18),
which describes build 1.60.1.69893 as "camelot, on the retail UI".

**Why this matters more than it looks.** §0 records this client reporting `project = 1`,
which is `WOW_PROJECT_MAINLINE` — the same value retail reports. Put together with "no new
`WOW_PROJECT_*` constant", that gives three consequences:

- **`WOW_PROJECT_ID` cannot detect Forever.** It answers `WOW_PROJECT_MAINLINE`, exactly as
  retail does. An addon branching on it takes its retail path on both clients, which is
  right by accident for the API surface and wrong for everything in §11.
- **`WOW_PROJECT_ID == WOW_PROJECT_CLASSIC` is false here**, so a Classic-line addon
  detecting its own flavour that way will not recognise the Classic-line client it is
  running on.
- **Blizzard's own modules gate on the `.toc` instead**, with
  `## AllowLoadGameType: standard, camelot`. That is a load-time directive, not a runtime
  test, and it is the mechanism the client itself uses.

The linter now flags `WOW_PROJECT_ID` comparisons as `project-id-detection`. Whether a
*third-party* `.toc` is honoured when it carries `AllowLoadGameType: camelot` is
unmeasured — Blizzard's own modules using it does not prove the client reads it from an
addon.

---

## 11. A port diary: five client differences another developer hit

**[PRIMARY]** [perriekkola/perskan#22](https://github.com/perriekkola/perskan/pull/22) —
"WoW Forever support: port fixes, hidden options, and relevance-based nameplate names". A
real port of a nameplate addon with its failures itemised. Credit to that author: this is
the most useful single document another developer has published about porting to this
client.

> "Forever is a Classic-line client (`_classic_beta_`, interface `16001` — 1.60.x), now
> the third `## Interface` entry behind the two retail ones."

**These are their measurements, not ours.** None has been reproduced on a client here, so
none of them is in `research/restrictions.yaml`. Each is named below with the probe command
that will settle it.

1. **`.toc` directives must stay contiguous.** "A blank line sat between `## IconTexture`
   and `## SavedVariables`" — the directive went unrecognised and **all saved data was
   unloaded at login**. The header ends at the first non-directive line. This one needs no
   client to act on: it is now the linter's `toc-header-break`, an error.
2. **Saved variables are restored *before* addon Lua executes** — the opposite of retail. A
   file-scope `BindPadVars = {...}` therefore overwrites restored data instead of providing
   a stub. This is the most consequential claim in the PR and it is what §12 turns on.
   `/fprobe sv`.
3. **`GetCurrentRegionName()` returns an empty string** rather than a region identifier.
   `/fprobe port`.
4. **`GetNamePlateForUnit()` raises** on target-of-target tokens instead of returning nil.
   `/fprobe port`.
5. **The realm name is not a stable identity.** Their AceDB fix applies a different key
   ruleset "on any client whose interface version is between 16000 and 20000", producing
   keys like `"Per Ro - PvP"`. `/fprobe port`.

One internal tension worth keeping in view: the PR repeats the flat claim that Forever
"writes SavedVariables on exit and never reads them back" **while simultaneously describing
a load order in which they are read**. Both cannot be true as stated. §12 is that thread.

---

## 12. The SavedVariables failure is a tracked beta bug, and its cause is contested

§P.9 measured it here: the client writes the file and never reads it back. That is still
this repo's position. What is new is that it is **filed as a bug rather than settled
behaviour**, and that three published explanations disagree about the cause — two of which
would make it the addon's fault, and therefore avoidable.

**It is tracked and unfixed.** **[PRIMARY]**
[ClassicWoWCommunity/forever-bugs#34](https://github.com/ClassicWoWCommunity/forever-bugs/issues/34),
"Addon settings reset after reload despite SavedVariables being written to disk", opened
2026-09-18 against build 69913 / interface 16001 — the same build as §P, which is a useful
corroboration of the build — **still open, no Blizzard acknowledgement**, multiple addons,
cross-platform. So any guidance built on this carries an expiry and should be re-checked
on every new build.

**Explanation A: the client restores nothing.** What §P.9 measured, and what the official
forum threads describe. **[PRIMARY]**
[EU forums, 2026-09-18](https://eu.forums.blizzard.com/en/wow/t/wow-forever-game-not-save-any-addons-settings/629470)
— fetched, no staff reply — carries a clean minimal repro: a bare test addon, everything
else disabled, writes `["test"] = 6`; after a fresh restart `/dump` returns empty, and the
next client close overwrites the file with empty values. A bare test addon should not be
hitting explanation C, which is what makes this the strongest evidence for A.

**Explanation B: only some WTF paths are read.** **[PRIMARY]**
[US forums, 2026-09-18](https://us.forums.blizzard.com/en/wow/t/uiaddon-settings-wiped-on-client-restart/2353992)
— fetched, no staff reply. User UDrew reports that only top-level `WTF\SavedVariables`
files load, while the account-scoped ones are ignored. Note that the EU repro above used
`WTF\Account\SavedVariables\` — directly under `Account`, with no account segment — so
there are at least three candidate paths in circulation and the reports do not agree on
which one the client writes, let alone which it reads.

**Explanation C: the addon clobbers the restored table.** **[REPORTED]**
[TylerAkins/forever-quest-markers#21](https://github.com/TylerAkins/forever-quest-markers/pull/21),
"Fix options not sticking by binding SavedVariables in place":

> "Previous fixes replaced the SavedVariables table or delayed creating it until
> PLAYER_ENTERING_WORLD. Forever then serialized the original empty table. **Working
> addons bind the TOC global on `ADDON_LOADED` and only mutate that table.**"

Read together with §11 item 2, this is coherent: the client *does* restore the table, the
addon's own file-scope initialiser replaces it, and exit serialises the replacement.
**Do not over-read it.** By its own admission the PR was not tested against the live beta,
and what actually fixed their persistence was unrelated — "Deleting the leftover
`ForeverQuestPins.lua` files fixed persist on current main, without this PR." The PR calls
itself defensive hardening.

**Why this is not already answered here.** §P.9 and `reference/guides/savedvariables.md`
record a pre-seeded file that never arrived and a load counter stuck at 1, which argues for
A. But the probe reached that result through `ForeverProbeDB = ForeverProbeDB or {}` at
file scope, and whether that idiom is safe depends entirely on the load order in §11 item 2
— which nobody has measured. Under retail's order the `local db` taken on the next line
points at an orphaned table, and the counter would read 1 forever *even if the client
restored perfectly*. The existing measurement cannot tell that apart from A.

**What settles it.** `addons/ForeverProbe/SavedVars.lua`, reported by `/fprobe sv`. It
loads first in the `.toc` and records four saved globals bound four different ways —
including each table's **address** — at file scope, `ADDON_LOADED`, `PLAYER_LOGIN` and
`PLAYER_ENTERING_WORLD`. An address that changes between phases is the client swapping the
global out from under the addon, which reads the load order directly rather than inferring
it. `scripts/seed-savedvars.ps1` covers B by writing a differently tokenised file into all
four candidate WTF paths at once, so whichever token arrives names the path that works.
One session settles A, B and C together.

---

## 13. The Secret surface may be countable from the client's own documentation

**[PRIMARY]** [danielcosta42/guildos#18](https://github.com/danielcosta42/guildos/pull/18)
— "Ready for the WoW: Forever beta: Secret Values, the client read from the build, and the
probe". Credit to that author for both figures below.

> "Forever runs the retail Secret Values system (4,025 documented entries carry Secret
> fields; Anniversary has 3)."

> "In chat messaging lockdown a `CHAT_MSG_*` line and its sender arrive secret."

It also states that a restricted unit's "name, class and GUID, and stats **while
restricted**" can arrive as secret values — conditional wording, consistent with this
repo's per-category gating rather than a blanket rule.

Their generator method is a second, independent path to the reference this plugin builds:

> "`tools/forever-scan/` does it again for a new build: API documentation from wago.tools'
> CASC endpoint for both clients, indexed with luajit, compared with the probe's inventory
> and checked against Blizzard's Lua and both executables."

Two consequences worth acting on:

- **If 4,025 reproduces, the restriction list becomes a build artefact.** Today
  `research/restrictions.yaml` is hand-maintained from black-box probing, one function at a
  time. A `Secret` field on the documented entries would mean the machine-readable part can
  be *generated*, leaving only the verdicts and the prose hand-written. `/fprobe docs
  secrets` counts it — and *discovers* the key name rather than assuming it is spelled
  `Secret`, because assuming the retail name is exactly how §P.22 would have gone wrong.
- **The wago.tools CASC endpoint is a second source for the reference** that needs no
  running client, which matters for regenerating against a build nobody has logged into
  yet.

The chat-lockdown line also gives the first concrete behaviour behind the
`InChatMessagingLockdown` / `AreOutgoingAddonChatMessagesRestricted` flags already recorded
in §0.3. Unmeasured here.

---

## 14. A contradicted claim: that unit health is secret at all times

**[UNVERIFIED]** [wowforeverbuilds.com, 2026-09-18](https://wowforeverbuilds.com/news/what-the-wow-forever-beta-breaks-for-addons-secret-health-values-dead-secure-sni)
— bylined only "WoW Forever Builds News Desk". Unknown site, no named author; not on the
excluded-SEO list, but not established either. Fetched and read, not taken from a snippet.
It claims hands-on testing against build 1.60.1.69913, the same build as §P.

> "Unit health comes back as a secret value that addons cannot compare or calculate with."

It frames the restriction as **always-on rather than combat-only**, says
`UnitHealth("player")` returns something typed as a number that addons "cannot compare or
do arithmetic with", and adds that "Blizzard's own frames are unaffected — the restriction
targets tainted addon code".

**This contradicts §P.3, §P.10 and §P.18 in a specific, testable way.** ForeverProbe
measured, out of combat, that `ShouldUnitPowerBeSecret(player)` is true while auras and
cooldowns are not — the published doctrine backwards in both directions, gated per
category. A blanket always-on health gate is a different model of the same client. It is
recorded here rather than dismissed because the *shape* of the claim is new and useful: a
value that is typed as a number and still refuses comparison is a fourth failure mode this
repo's read tests could not have detected, because they only record what came back.

**How it gets settled.** `/fprobe secrets`, in and out of combat. It separates masked (a
plain value that may still be a lie), secret (comparison and arithmetic both throw),
half-secret (secret, but arithmetic works — which is what this article actually describes)
and plain, per unit and per read, with each operation in its own `pcall`. Until that runs,
treat the claim as a lead. If it is wrong, it is another instance of confident secondary
reporting that the restriction chapter should contradict by name.

One part of the article corroborates something already on file, with a new detail — the
missing `loadstring_untainted`:

> "Blizzard's restricted-environment code, `RestrictedExecution.lua`, fetches an engine
> function called `loadstring_untainted` at line 22 and calls it at line 79. The Forever
> client never provides it."

— producing "`RestrictedExecution.lua:79: attempt to call a nil value`". That file and line
number are new, and they match the GSE #2110 report already recorded in §0.2.

---

## What is still unmeasured

Everything above is either measured or attributed. These are the gaps, listed so that
nothing here is mistaken for a complete account of the client.

- **`SecureActionButtonTemplate:SetAttribute` in combat.** §P.20 recorded the call raising
  no error and firing no block event, which is why `research/restrictions.yaml` carries it
  as `caution` rather than as a permission. Retail protects exactly this call, and this
  client has already shown that a refusal can be silent, so "no error" is weaker evidence
  than the attribute actually taking effect. Re-test before relying on it.
- **Three `C_Secrets` gates have no captured out-of-combat value**: `ShouldUnitSpellCastBeSecret`,
  `ShouldUnitThreatStateBeSecret` and `ShouldUnitThreatValuesBeSecret`. The in-game chat
  line truncated before printing them. Their in-combat behaviour is measured (§P.18); their
  out-of-combat state is inferred from the reads, not read off the gate.
- **`/fprobe video` in combat** has not been run, so whether `SetCVar` on the display CVars
  survives combat is unknown (§P.22). `SetCVar` is not a protected function and none of
  these CVars carry lock flags, so a block is unlikely — but §P.20 showed this client's
  action gating does not always match retail.
- **Exclusive fullscreen** is untested for §P.22; the measurement was taken in maximized
  windowed mode, which was the case in doubt and passed.
- **Beta-realm scale.** §P.15's auction timings come from a market of 14,389 auctions and
  680 item keys. A launch realm will be larger by an order of magnitude, and neither the
  500-result page size nor the three-second completion is guaranteed to hold. What
  generalises is the shape — unthrottled, paginated, completion-flagged browse — not the
  timing.
- **The `ReplicateItems` throttle is bracketed, not pinned**: greater than 162 seconds, at
  most 1047 (§P.17). Retail's documented 900 sits inside the bracket and is the obvious
  candidate, but it was not measured here.
- **The published restriction list.** Blizzard has not released one, and "certain
  restrictions" (§1) is as specific as the on-record statements get. Everything in this
  document about what is permitted comes from measurement, which is why it is measurement
  rather than citation.

Sections 9 to 14 are other developers' findings, fetched and credited. Most were measured
here on 2026-09-20 (§P.23 to §P.26); what remains open is listed below. Nothing from those
sections entered `research/restrictions.yaml` until it had been measured — §P.25 is the one
that did, and it both added an entry and corrected an existing one.

- **Why per-character survives a `/reload` and not a cold start** (§P.27). The behaviour is
  measured; the mechanism is not, and the obvious explanation (globals kept in memory
  across a reload) is refuted by the account-wide global in the same Lua state not
  surviving. Not blocking anything, but it decides how much to trust the reload case.
- **Moving the probe's own DB to `## SavedVariablesPerCharacter`** to lift §P.21's
  one-session constraint. Measured as possible, not yet done.
- **Whether a target's max values are secret out of combat** — answered, §P.28: yes, and
  hostility makes no difference. Listed here only because §P.25 left it open.
- **Whether a third-party `.toc` honours `## AllowLoadGameType: camelot`** (§10). Nothing
  in `_G` reports the game type as a value, so the directive is the only candidate
  mechanism and it is untested from an addon.
- **Whether the restriction data can actually be generated from the documentation**
  (§P.26). The taxonomy is measured; the generator does not consume it yet.
  `projectField`/`projectFunction` capture a single `Secret` field and should be widened to
  every key matching the pattern.
- **`SecureActionButtonTemplate:SetAttribute` in combat**, the three `C_Secrets` gates with
  no out-of-combat value, `/fprobe video` in combat, exclusive fullscreen, beta-realm
  scale, and the `ReplicateItems` throttle bracket — all as listed above, unchanged.
