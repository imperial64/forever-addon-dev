# Findings — WoW Forever addon capabilities

Last updated 2026-09-18. §P is our own probe, run on the beta client, and outranks
everything. §0 is a third-party capture of the same build, fetched and queried here, which
outranks every press source below it.

Companion document: `auction-addon-architecture.md` — how existing auction addons acquire,
store, price and act on market data, and the four constraints that decide whether the
economy plan is buildable. Read it before designing anything Auction House related.

Confidence labels, strongest first: **[PROBE]** measured by ForeverProbe on our own
client · **[MEASURED]** read off someone else's capture of the running client · **[PRIMARY]** fetched and read directly · **[REPORTED]** credible secondary
source, fetched · **[UNVERIFIED]** surfaced in search, not independently confirmed ·
**[EXCLUDED]** checked and found irrelevant or unreliable.

**Plan status, updated 2026-09-18 against the measured client (§0):**

| Plan | Status | Next action |
|---|---|---|
| Economy / TSM-style | **The goal — and no longer blocked.** `C_AuctionHouse` ships in full (§0.1) | Measure the *numbers*: throttle, caps, owner fields. `/fprobe ah` then `/fprobe ah scan` |
| Claude Code bridge | Tooling, built alongside. Viable but human-in-the-loop (§0.2) | Confirm the SavedVariables write and the `BridgeData.lua` inbound path on this build |
| Guild management | **Scrapped** 2026-09-17 | None. Not a focus question; do not probe or design for it |
| Rotation helper | **Closed** 2026-09-18. `C_AssistedCombat` is present (§0.4) and Efe declined to reopen on it | None. Do not design, scaffold or spec against it |

Two plans, not four. The economy addon is the actual objective. The bridge is tooling for
talking to Claude Code from inside a running client — general-purpose, not WoW-specific,
and expected to be reused across projects — so it is worth building even though it is not
the goal. Guild management was dropped to avoid splitting focus, not because anything
blocks it; the guild APIs are almost certainly fine, which is exactly why the question is
not interesting.

---

## P. Measured here, on our own client (2026-09-18)

**[PROBE — ForeverProbe, run by Efe on beta build 1.60.1.69913, character in Elwynn
Forest, out of combat]** This outranks everything below it, including §0. It is the first
result in this document that came from our own client rather than someone else's capture
or someone's reporting. Note the build: 69913, one ahead of the capture §0 describes.

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

`UseAction` is forbidden outright rather than merely protected in combat. Neither live plan
uses it.

### P.5 Both live plans confirmed on our own client

This is the corroboration §0 needed, measured here rather than read off someone else's
capture.

**Auction House** — `/fprobe` scored every section full: modern 12/12, commodity 5/5,
replicate 3/3, restricted 7/7, legacy 0/8, legacy actions 0/4. The verdict line reads
"modern `C_AuctionHouse` only — retail AH code largely ports". The restricted set matches
retail's seven exactly. §0.1 is confirmed, and the economy plan's API question is closed
twice over.

**Bridge** — `io=false os=false load=true addonMsg=true cvar=true json=true clipboard=true
reloadUI=true`, and the inbound channel works: `BridgeData.lua` loaded and reported
"shipped default only", which is the probe's way of saying the file was executed as addon
code and the receiver ran. The channel is live; it has simply not been written to yet.
`scripts/write-bridge-data.ps1` then `/reload` closes that loop.

The one new constraint is `AreOutgoingAddonChatMessagesRestricted() = true`. The bridge's
primary path does not use addon messages, so this costs nothing today, but it removes the
sideband that §0.2 listed as a candidate.

### P.6 Odds and ends

- **The client is build 69913**, not the 69893 the §0 capture describes. Forever is
  patching the beta daily; §0 is already one build behind, which is an argument for
  trusting the probe over the capture wherever they disagree.
- `C_AssistedCombat` is present but **inert**: `IsAvailable()` returns false and
  `GetRotationSpells()` returns 0 entries. The rotation helper is closed on Efe's decision
  (§0.4) and this does not reopen it — but it does mean the API Blizzard shipped is not
  currently doing anything for a player on this build.
- Global dump: 5,958 functions and 269 `C_` namespaces, against the capture's 6,045 and
  269. Same shape, slightly different surface — consistent with the build difference.
- Surface scores: read 32/48, execute 16/18, secure 14/15, plans 26/31.

---

### P.9 The bridge, decided: outbound works, the round trip does not

Measured 2026-09-18 on our own client, and this settles the second live plan.

**Outbound works.** `WTF/Account/130656239#1/SavedVariables/ForeverProbe.lua` exists on
disk, 303 KB, written on logout. Everything the probe recorded — the full global dump, the
namespace map, the secrecy gates, the auction surface — came back out of the client in a
file an external process can read. That is the entire outbound requirement.

**The in-client round trip does not.** `bridge.loads` reads 1 in every session, and
`tokenFromPreviousSession` is `nil` after a `/reload` that definitely happened. The client
writes the file and never reads it back, exactly as §0.2 reported from someone else's
testing, now confirmed here.

**The inbound channel works.** `bridge.inboxEntries = 1` with `untouched = true`: the
shipped `BridgeData.lua` was executed as addon code and its receiver ran. The mechanism is
live — it has simply never been written to by an external process yet.
`scripts/write-bridge-data.ps1` then `/reload` is what closes that loop.

**So the bridge is buildable in exactly the shape §0.2 predicted**, and the SavedVariables
bug costs it nothing, because nothing in the design needed the client to read its own
saves. Claude Code writes a `.lua` file; the player types `/reload`; the addon answers into
SavedVariables; Claude Code reads that. The `/reload` is the price, and `ReloadUI()` being
protected is what keeps it manual.

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

**The collateral-damage check both live plans needed has now passed.** Every event either
plan requires is in the allowed list: `AUCTION_HOUSE_SHOW` and
`AUCTION_HOUSE_THROTTLED_SYSTEM_READY` for the economy addon, `CHAT_MSG_ADDON`,
`PLAYER_MONEY` and `BAG_UPDATE` for the bridge and for inventory-side economy work. Nothing
the two plans read or listen to is restricted at any of the three levels above.

`PLAYER_REGEN_DISABLED`/`ENABLED` being allowed is worth keeping: an addon can still know
whether it is in combat, which is what lets both plans defer their work to a safe moment
rather than discovering a restriction mid-scan.

The full allowed list is in `db.eventProbe` in the SavedVariables; the in-game print
truncates it.

---

### P.13 Consequences of P.1

- **Neither live plan is touched.** The economy addon and the bridge read auction data,
  money, bags and addon messages. None of them subscribe to the combat log.
- **The rotation helper stays closed** (§0.4, decided 2026-09-18). This would have been an
  independent kill for it, had it still been open.
- **`CleanCombatLog` (§5) is answered.** That developer is testing whether Forever permits
  `COMBAT_LOG_EVENT_UNFILTERED`. It does not permit even listening. No need to keep
  watching the repo for this.
- **Blizzard's own damage meter is the only route to combat data**, which is consistent
  with Jones saying they are shipping one (§1) and with `C_DamageMeter` being present
  (§0.3).

### P.14 Still to measure here

`/fprobe events` walks the neighbourhood of the refusal and attributes each result, so the
next run says whether the rule is "no combat log" or "no combat information": it tries
`COMBAT_LOG_EVENT` as well as the unfiltered form, combat state events, the unit events
the doctrine names, and — as the collateral-damage check — the events both live plans
actually need (`AUCTION_HOUSE_SHOW`, `AUCTION_HOUSE_THROTTLED_SYSTEM_READY`,
`CHAT_MSG_ADDON`, `PLAYER_MONEY`, `BAG_UPDATE`).

The probe no longer registers the combat log at load. The answer is in, and repeating it
every login only trains the player to dismiss a dialog that is a result.

---

## 0. The client itself, measured (2026-09-18)

**[MEASURED — a third-party capture of the live beta client, fetched and queried directly
here; not our own probe output]**
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
above all press reporting in this document and below our own probe output, which does not
exist yet.

### 0.1 Auction House — open question 1 is answered

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

**Consequence.** The economy addon is a **Retail port, not a Classic one** — the modern
namespace with commodities, which is the good outcome and the one
`auction-addon-architecture.md` is written against. No Auction House function appears in
any restriction surface (§0.3). What is still unknown is every *number*: scan throttle,
result caps, whether `ReplicateItems` returns owner names. Only the probe answers those.

### 0.2 The client boundary — open question 2, mostly answered

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

`C_EncodingUtil` is the find. It was not in the plan and it changes the shape of the
bridge: the inbound generated `.lua` file and the outbound SavedVariables blob stop being
hand-rolled Lua literals and become a real wire format, with compression, that both sides
can agree on. The same goes for an addon-message sideband, which was previously
unattractive largely because of payload encoding.

**Two blockers, both reported as beta bugs rather than policy:**

1. **SavedVariables are written but never read back.** Proven by the kit with a pre-seeded
   file: the global was `nil` from main chunk to logout, in every candidate WTF folder.
   The normal write-now / read-next-launch loop is dead in this build. Note the asymmetry
   — this breaks the *in-client* round trip, not the outbound half that an external reader
   cares about, and those are worth telling apart. The probe now does.
2. **`ReloadUI()` is protected.** An addon cannot reload itself; a human must type
   `/reload`. That is what stops a fully unattended in-client loop, and it is the binding
   constraint on the bridge — not the sandbox.

The working inbound pattern is unchanged and now has a second independent implementation:
an external process writes Lua into the AddOns folder and the client executes it as addon
code at load (the kit's `ForeverCompat` `seeds/` plus `tools/sv_bridge.py` and a
sub-second `sv_watch.py`). This is the same mechanism as `auction-addon-architecture.md`
§5, and the one `BridgeData.lua` already tests.

### 0.3 The restriction surface — open question 3, strong indication

`C_Secrets` is present with **27 functions**, and every one of them is unit-, spell- or
combat-scoped: `ShouldAurasBeSecret`, `ShouldCooldownsBeSecret`, `ShouldUnitPowerBeSecret`,
`ShouldUnitThreatValuesBeSecret`, `ShouldUnitIdentityBeSecret`, `HasSecretRestrictions`
and so on. **Nothing in the secrecy surface touches the Auction House, the economy, CVars,
addon messages or encoding.** `C_RestrictedActions` (3 functions), `C_CombatLog` with
`IsCombatLogRestricted`, and a first-party `C_DamageMeter` (8 functions) are all present.

Crucially the restriction is a *gate*, not a removal: per the kit, while
`C_Secrets.ShouldAurasBeSecret()` is true, every aura read from addon code throws. A gate
that can be asked its own state is a much cheaper answer to combat-only-vs-always-on than
diffing masked values — the probe calls all of them in both combat states and prints the
delta.

**§P.3 has since made the expected answer wrong.** Out of combat on our own client,
`HasSecretRestrictions()` is already true and `UnitPower("player")` already returns a
secret, while auras and cooldowns do not. The gates are not a single combat-scoped switch,
and this section's "if the gates read false out of combat" framing should not be relied
on.

One practical consequence for the probe, also corrected by measurement: a secret value does
**not** reliably throw on `tostring()` — it returns a secret *string*, and the throw
happens later, wherever that string is next indexed. See §P.2.

### 0.4 `C_AssistedCombat` is present — watch trigger 4 has fired

`C_AssistedCombat` exists on this build with four functions: `IsAvailable`,
`GetRotationSpells`, `GetNextCastSpell`, `GetActionSpell`. This is the specific thing
listed as reviving the rotation helper: Blizzard's own rotation-assist API, in Forever,
which would tell an addon what to cast next without the addon reading combat state at all.

**Decided 2026-09-18: the rotation helper is not reopened.** Efe's call, asked and
answered. So this is the end of trigger 4 as a live question — `C_AssistedCombat` is
recorded because the record should be accurate, not because anything follows from it. The
probe calls its two no-argument functions and stores what they return; nothing else in
this repo may design, scaffold or spec against it. Do not raise it again without Efe
raising it first.

### 0.5 The Classic globals are gone

`UnitAura`, `GetSpellCooldown`, `GetSpellInfo`, `GetItemInfo`, `GetSpecialization`,
`GetTalentInfo`, `GetMerchantItemInfo` and `CombatLogGetCurrentEventInfo` are all absent;
their `C_*` equivalents (`C_UnitAuras`, `C_Spell`, `C_Item`, `C_Traits`) are present.
`CombatLogGetCurrentEventInfo` being absent matters on its own: the combat-log event can
fire with nothing on the other side able to read it, and "never fires" and "fires but is
unreadable" are different answers to question 4.

Two more facts that shape any addon written here, both from the kit and both about
developer experience rather than policy: registering an event this client does not know
**throws and aborts the rest of the file**, and after 100 Lua errors in a session the
client stops delivering errors to any handler. The probe now wraps every registration in
`pcall` for the first reason.

---

## 1. Blizzard has now said on camera that the restriction is on the *read* side

**[PRIMARY — transcript supplied by Efe; video title fetched, channel and publish date not
independently verified]**
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
- Combat-only vs always-on is still unanswered. It is now the only open question that
  could revive the rotation helper, and the probe can answer it today.
- A first-party cooldown manager is a *product*, not a `C_AssistedCombat`-style API an
  addon could build against. Watch trigger 5 (a Blizzard rotation-assist API) stays open.
- Nothing here touches the Auction House or out-of-game export. Jones's "full access to
  customized UI" line explicitly protects both live plans.

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

## 4. Corroboration that this ends rotation helpers

**[UNVERIFIED]** Hekili's maintainer announced the addon sunsets with retail's Midnight
12.0 pre-patch, because the new APIs remove the spell-simulation hooks it relied on.
Surfaced as https://x.com/hekili808/status/1973479282006696123 with a reported date of
2026-01-20, which looks inconsistent with the status ID. Treat as corroboration, not fact,
until fetched directly. This is about retail, not Forever.

**[UNVERIFIED]** A successor called "HekiLight" built on Blizzard's own `C_AssistedCombat`
API was mentioned for retail Midnight. No source claims it targets Forever. If Blizzard
ships an official rotation assist while disarming third-party ones, that reframes the whole
question — hence `C_AssistedCombat` stays in the probe's scan list.

**[UNVERIFIED]** https://us.forums.blizzard.com/en/wow/t/addonsweakauras-restricted/2350657
— official forum thread about WeakAuras being restricted in Forever. Not yet fetched. No
allow-list published.

---

## 5. The one live empirical signal from another developer

**[UNVERIFIED]** https://github.com/Caeth/CleanCombatLog — "Combat log addon for world of
warcraft: forever", a developer actively testing whether Forever permits
`COMBAT_LOG_EVENT_UNFILTERED`.

**Answered 2026-09-18 by our own probe — see §P.1.** Forever does not permit an addon to
register `COMBAT_LOG_EVENT_UNFILTERED` at all, out of combat or otherwise, and
`CombatLogGetCurrentEventInfo` is absent from the build. Nothing to track here any more;
the question this repo existed to answer is closed, and closed harder than "fires with
fewer fields".

---

## 6. No longer load-bearing

**[REPORTED, NOT FETCHED]** [GamesRadar](https://www.gamesradar.com/games/world-of-warcraft/world-of-warcraft-forever-takes-page-out-of-retails-book-as-blizzard-confirms-access-to-add-ons-will-be-restricted-in-the-throwback-mmo/)
— press reporting that Blizzard confirmed Forever restricts computational
combat/communication addons as retail does.

This was previously the only thing connecting the Midnight doctrine to Forever, and was
flagged for verification for that reason. §1 replaces it with a dev statement. Fetching it
is now optional and would only add a second-hand paraphrase.

---

## 7. The rotation helper: shelved, with one kill-check left

Shelved, not merely at risk. A rotation helper is a read-side addon, and the read side is
the thing a Blizzard developer has now said is restricted. Do not design, scaffold, or
spec against it.

The combat-only question is the only thing that would revive it. Probe outcomes:

- `targetAura1` and `spellCooldownStart` return real values **out of combat** and `nil` or
  masked values **in combat** → the box is combat-scoped. The helper is still dead
  *during* combat, which is when it matters, so this revives only a degraded form: a
  pre-pull / planning display, not a live recommender.
- Everything readable in **both** states → Forever did not inherit the read-side
  restriction in practice despite §1. The plan comes back in full, but treat this as the
  surprising result and re-verify before acting on it.
- Masked in both states → confirmed dead; close the plan, and re-check both live plans for
  collateral damage.

Residual salvage if the box is real: §3 says class secondary resources stay fully
readable, and the player's own spellbook and talents are not combat state. That supports a
resource-and-spec display with no target awareness and no cooldown awareness — a much
smaller addon than "rotation helper", to be re-scoped from scratch if wanted rather than
salvaged from the existing design.

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

## What the probe resolves

§0 has already answered the presence questions from someone else's client. What the probe
adds is the half a static name capture cannot give: whether a call is *permitted*, what it
*returns*, and what is gated at runtime. The rows below are rewritten accordingly — the
presence rows are now confirmations rather than discoveries.

| Probe output | Conclusion |
|---|---|
| `/fprobe ah scan` returns auctions, with timings | The real throttle and result cap, which §0 cannot supply. This is the economy plan's remaining unknown |
| `ReplicateItems` tuple carries owner names | Forever did **not** inherit retail's 9.0.2 anonymisation — changes what the addon can attribute |
| `C_AuctionHouse` calls fire `ADDON_ACTION_BLOCKED` | Presence without permission. Would contradict §0.1 and reopen the plan |
| `C_Secrets` gates read false out of combat, true in combat | Black box is combat-scoped; both live plans are clear of it (§0.3) |
| Any `C_Secrets` gate true **out** of combat | Always-on restriction — re-check both live plans for collateral reads |
| Bridge token survives a `/reload` | The SavedVariables read-back bug (§0.2) is fixed or never applied here |
| Token lost but `collect-savedvars.ps1` finds the file | Outbound is fine; only the in-client round trip is broken. Enough for the bridge |
| `BridgeData.lua` reports an external write | Inbound channel confirmed on this build, at the cost of a manual `/reload` |
| `targetAura1` readable out of combat, `nil` in combat | Black box is real and combat-scoped; rotation helper stays shelved, pre-pull display only |
| `targetAura1` unreadable in both states | Black box is always-on — close the rotation helper and re-check both live plans for collateral reads |
| `targetAura1` readable in both states | Contradicts §1; re-verify before believing it |
| `spellCooldownStart` masked in combat | Cooldown tracking gone; matches Blizzard shipping its own cooldown manager |
| Combat log events stop or lose fields in combat | Real-time parsing gone |
| `C_AssistedCombat` present | Blizzard ships its own rotation assist; different game entirely, watch trigger 5 fires |

## Open questions, in priority order

1. **Answered 2026-09-18 (§0.1): modern `C_AuctionHouse`, all 85 functions, no legacy
   API.** The open question is now the *numbers*, and it is the only thing standing
   between this project and building the thing it exists to build:
   - the real `ReplicateItems` throttle (retail: 900s) — `/fprobe ah scan`, then wait
     for the throttle-cleared line
   - the per-query browse cap and how many `RequestMoreBrowseResults` rounds reach it —
     `/fprobe ah browse`, which costs nothing and can be repeated
   - whether replicate rows still carry owner names (retail stripped them in 9.0.2),
     which decides whether listings can be attributed at all
   - how long a full scan takes end to end, and whether it stalls the client
   `auction-addon-architecture.md` §2 and §9.
2. **Closed 2026-09-18 by measurement (§P.9).** Outbound works — the SavedVariables file
   is on disk and an external process can read it. Inbound works — the generated `.lua` is
   executed as addon code and the receiver runs. The client not reading its own saves back
   costs the design nothing, because nothing in it needed that. The price is a manual
   `/reload` per refresh, because `ReloadUI()` is protected. The bridge is buildable; what
   is left is building it. `auction-addon-architecture.md` §5.
2a. Will Forever expose auction data through Blizzard's Game Data API? No Classic title
   has since late 2024, and TSM's entire architecture depends on that feed. This gates
   what *kind* of economy addon is possible, independently of question 1.
   `auction-addon-architecture.md` §7.
3. Is the black box combat-only or always-on? **The combat-scoped reading is now failing
   twice over, out of combat, on our own client.** Event subscription to the combat log is
   unconditionally forbidden (§P.1); `HasSecretRestrictions()` is true and
   `UnitPower("player")` returns a secret value while standing in a field doing nothing
   (§P.3) — the latter directly contradicting §3's promise that class resources stay
   readable. Auras and cooldowns, the two things §3 names as removed, read as not secret
   out of combat. What remains is to get a clean gate table now that the argument arity is
   handled, and to run the in-combat pass for the delta. Neither live plan reads any of
   it, which is the only reason this is still a curiosity rather than a problem.
   **The collateral-damage check has passed** (§P.12): every event both live plans need is
   allowed, and nothing they read is gated.
4. **Closed 2026-09-18 (§P.1, §P.12).** An addon may not register for the combat log at
   all — both `COMBAT_LOG_EVENT` and `COMBAT_LOG_EVENT_UNFILTERED` are refused, out of
   combat, and there is no `CombatLogGetCurrentEventInfo` to read either with. The
   boundary is mapped and it is narrow: every other event tried is allowed, including
   `UNIT_AURA`, `UNIT_COMBAT` and both combat-state events. The rule is "no combat log",
   not "no combat information".
5. What is actually inside "certain restrictions"? Only a published list or the beta
   client answers this.

**Answered 2026-09-17:** does Forever inherit the Midnight doctrine? Yes on the read side,
per Tim Jones (§1) — hedged, but on the record. §0.3 shows the machinery that implements
it, and shows it is scoped to units, spells and combat.

**Answered 2026-09-18:** which AH API, and what crosses the client boundary — §0.1, §0.2.

**Answered 2026-09-18, from our own client:** addons may not subscribe to the combat log,
and that restriction is not combat-scoped — §P.1.
