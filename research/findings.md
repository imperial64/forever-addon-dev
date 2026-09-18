# Findings — WoW Forever addon capabilities

Last updated 2026-09-18. This is the evidence base behind the restriction data this plugin
ships. §P is a probe run on the beta client, and outranks everything. §Q is a second
live-client measurement, by a different instrument and about cost rather than policy, and
ranks with §P. §0 is a third-party capture of the same build, fetched and queried here,
which outranks every press source below it. The numbered sections are press and developer
statements, kept for context and ranked below all three.

`research/restrictions.yaml` cites the sections below by number, so section IDs are stable:
they are never renumbered, only added to.

Confidence labels, strongest first: **[PROBE]** measured on a live client by an
instrumented addon - ForeverProbe in §P, AmbianceCost in §Q; each section names its
instrument · **[MEASURED]** read off someone else's capture of the running client ·
**[PRIMARY]** fetched and read directly · **[REPORTED]** credible secondary source,
fetched · **[UNVERIFIED]** surfaced in search, not independently confirmed ·
**[EXCLUDED]** checked and found irrelevant or unreliable.

---

## P. Measured on a live client (2026-09-18)

**[PROBE — ForeverProbe, beta build 1.60.1.69913, character in Elwynn Forest, out of
combat]** This outranks everything below it, including §0: it is behaviour observed on a
running client rather than someone else's capture or someone's reporting. §Q is the one
exception - a second instrument on the same client, ranking with this section rather than
under it. Note the build: 69913, one ahead of the capture §0 describes.

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

## Q. What calls cost, measured by a second instrument (2026-09-18)

**[PROBE — AmbianceCost, beta build 1.60.1.69913, out of combat, five runs]** Also measured
on a running client, so this ranks alongside §P rather than under it — but by a *different*
addon, from a different repository, and that difference is worth stating rather than quietly
folding into §P. §P asks what the client permits. §Q asks what calls cost, which is the
other question that decides whether a design is possible.

| | |
|---|---|
| Instrument | `AmbianceCost`, an addon in a separate repository, not in this one |
| Capture | `research/captures/AmbianceCost_2026-09-18_215313_cost-bench.lua` |
| Method | `debugprofilestart` / `debugprofilestop` around an adaptively sized loop; loop overhead measured separately and subtracted; each call benched on its own frame |
| Replication | 5 runs, 21:34–21:53, across graphics presets and frame-rate caps |
| Machine | RTX 5080, 1920x1080, D3D12, `gxMaximize=1` (maximized windowed); vsync on for runs 1–3, off for 4–5 |
| Combat | out of combat in all five runs |

Every figure below was re-derived from the checked-in capture rather than copied from the
handover note. Where the two disagreed, what is written here is what the capture says, and
the difference is stated in place.

The machine-readable form of everything in this section is `research/costs.yaml`, which is
a separate source from `research/restrictions.yaml` for the reason the next paragraph gives:
nothing here is a refusal, and it ages differently.

**`/fprobe` does not reproduce any of this, and `regenerate` will not re-measure it.** The
capture is checked in so the numbers can be re-derived, but they are dated to build 69913 in
a way §P's policy findings are not: a new build invalidates them silently and nothing in
this repo will notice. Read them as an order of magnitude that held on one machine, not as a
constant. A `/fprobe cost` subcommand would close that gap; it has not been written, and
whether it is worth writing is a decision for this repo rather than an obligation from the
handover.

### Q.1 A frame-limit checkbox does not zero its CVar

The slider value and the enable flag are **separate CVars**. Read at 21:53 with the client
reporting 273.7 fps:

| Slider CVar | Value | Enable flag | Value |
|---|---|---|---|
| `maxFPS` | 120 | `useMaxFPS` | 0 |
| `targetFPS` | 60 | `useTargetFPS` | 0 |
| `maxFPSBk` | 30 | `useMaxFPSBk` | 1 |

`maxFPS` retains the last slider position whether or not the limit is applied. An addon
reading `maxFPS` alone concludes the client is capped at 120 while it is in fact running
uncapped at more than twice that — and gets no error, because from the client's point of
view nothing went wrong. This is the §Q finding most likely to produce a confidently wrong
answer rather than a visible failure.

The same shape is already recorded in §P.22 for `HDRBrightness` / `useHDRBrightness` and
`HDRPeakBrightness` / `useHDRPeakBrightness`. Two instances is a **pattern worth checking
for, not a proven convention**: no enumeration of this client's CVars was done to establish
that every `<Name>` carries a `use<Name>`. The safe reading is "a CVar's value may not be in
effect — look for a paired flag before trusting it", not "`use<Name>` always exists".

`useMaxFPSBk = 1` is unrelated to the other two and applies only when the window is
unfocused. The graphics panel's slider minimum is 8 FPS, so unticking the box is the only
way to express "no limit" — which is exactly why a stale value is left behind.

**n = 1 for the pairing.** Only the last of the five runs captured the `use*` names; the
first four recorded the slider values alone. The finding does not rest on replication: one
run in which `maxFPS` reads 120 while the client reports 273.7 fps is enough to establish
that `maxFPS` was not being applied.

Not verified: whether **writing** `useMaxFPS` from an addon takes effect. Only reads were
done. §P.22 establishes that `SetCVar` writes land on the brightness CVars; that does not
carry over to these without a measurement.

### Q.2 `C_Map.GetPlayerMapPosition` returns an object and allocates 1864 bytes per call

Present and working. It returns a position **object exposing `GetXY()`** — not two numbers,
and not a plain `{x, y}` table.

| | |
|---|---|
| Cost | 4.38 – 5.71 µs per call (n=5) |
| Cost including `GetXY()` unpacking | 4.91 – 7.91 µs per call (n=5) |
| Allocation | **1864 bytes per call**, byte-identical in all five runs |

The shape is not a divergence from Blizzard's documentation — the generated page types the
return as `vector2 (Vector2DMixin)`. It is a divergence from the Classic habit of
`local x, y = GetPlayerMapPosition(...)`, and that bare global is not on this client at all
(§0.5), so Classic code fails at the call rather than at the unpack.

1864 bytes is far above a bare table and is the dominant cost of reading player position on
this client — roughly six times the cost of a `SetCVar` write in time, and the only figure
here that constrains a design. Polling every frame costs about 218 KB/s of garbage at
120 fps and about 500 KB/s at 274. At 10 Hz the same work is about 18 KB/s.

So: **poll position on an accumulator, not per frame.** The allocation was measured with the
collector stopped, which is what keeps a collection inside the measuring loop from reading
as a negative delta and reporting "allocates nothing".

Not verified: behaviour inside instances, where Retail returns nil. The instrument guarded
for it and never exercised the guard.

### Q.3 `C_Map.GetBestMapForUnit` is present and cheap

0.610 – 0.636 µs per call (n=5), returning a numeric uiMapID, with no measurable allocation.
Seven to nine times cheaper than the position read. It is still a map-tree lookup, so it
belongs behind a zone-change event rather than in a per-frame path, but its cost is not what
would make a position poller expensive — §Q.2 is.

### Q.4 What a `SetCVar` write costs, extending §P.22

§P.22 records that 442 writes over four seconds produced no frame-gap spike. That is a
ceiling, not a cost. The per-call figures, both through `C_CVar.SetCVar` on `Brightness`:

| Write | Cost |
|---|---|
| **changed** value | 0.786 – 0.823 µs (n=5) |
| **unchanged** value | 0.304 – 0.316 µs (n=5) |

A changed value costs about 2.6x a no-op write, so the client is doing real work on change —
and that work is still sub-microsecond. One changed write per frame is about 0.02% of a
frame at 274 fps. The "cheap live post-process" conclusion in §P.22 holds and now has a
number under it.

### Q.5 `OnUpdate` elapsed is quantised to 1 ms

The `elapsed` argument this client passes to an `OnUpdate` script has **1 ms resolution**.

What the capture actually holds is worth stating, because it is not the raw per-frame
values: 15 phases (three per run, five runs) covering **19,692 frames**, of which only the
p50, p99 and max gap per phase were retained. All 45 of those order statistics are whole
numbers of milliseconds. The stronger evidence is the other column — each phase's elapsed
time, accumulated from `elapsed` over roughly 1,200 frames, lands on an exact multiple of
1 ms in every one of the 15 phases (10.000, 10.001, 10.002, 10.004, 10.005, 10.006, 10.012,
10.019 s). A sum of 1,200 fractional values does not land on an exact millisecond by
accident.

Two consequences:

- **Frame-rate-independent easing on `elapsed` still works.** The quantisation is far below
  the time constants involved.
- **`elapsed` cannot measure anything costing less than ~1 ms.** An addon profiling itself
  this way produces noise, not measurements. `debugprofilestop` is the instrument with the
  resolution, and it is available — §Q.6.

The handover note described this as "~7000 frame samples". The capture holds 19,692 frames
across 15 phases, and the per-frame values themselves were not retained; the claim is
unchanged, the sample description is corrected.

### Q.6 The profiling and GC primitives work on this client

Confirmed exercised, which is what made everything above measurable:

- `debugprofilestart()` / `debugprofilestop()` — microsecond resolution
- `collectgarbage("count")`, `("stop")`, `("restart")`, `("collect")`

All of these are documented by Blizzard and already carry generated pages, so their
*presence* is not the finding. The finding is that they behave on this client, which is a
weaker claim than presence but the one an author actually needs — §P.22 has already shown
that a documented retail name can be absent from this build. `collectgarbage("stop")` in
particular is load-bearing for any allocation measurement, per §Q.2.

### Q.7 Not recorded: the frame-gap phase data

The capture's `phases` table is checked in with the rest of the file and is **not evidence**.
Nothing in this repo cites it, and it should not be quoted. Two defects, both in the
instrument rather than the client:

- Phases run once each, in a fixed order, so drift across the roughly 30-second run loads
  entirely onto the later ones. The phase that polls far less often for the same number of
  writes reports the worse frame rate, which cannot be a cost. That ordering is drift.
- The first frames of a phase are not discarded, so the do-nothing control carries the
  largest frame gap in every run and flatters every phase measured after it.

The one claim those phases support: **no phase in any run produced a frame gap a player
would feel.** Everything quantitative in §Q comes from the microbench instead.

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
