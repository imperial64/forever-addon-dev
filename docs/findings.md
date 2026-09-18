# Findings — WoW Forever addon capabilities

Last updated 2026-09-18. §0 is measured against the live beta client — a third-party
capture, fetched and queried here, which supersedes every press source below it. Our own
probe output supersedes §0 in turn, and does not exist yet.

Companion document: `auction-addon-architecture.md` — how existing auction addons acquire,
store, price and act on market data, and the four constraints that decide whether the
economy plan is buildable. Read it before designing anything Auction House related.

Confidence labels, strongest first: **[MEASURED]** read off a capture of the running
client · **[PRIMARY]** fetched and read directly · **[REPORTED]** credible secondary
source, fetched · **[UNVERIFIED]** surfaced in search, not independently confirmed ·
**[EXCLUDED]** checked and found irrelevant or unreliable.

**Plan status, updated 2026-09-18 against the measured client (§0):**

| Plan | Status | Next action |
|---|---|---|
| Economy / TSM-style | **The goal — and no longer blocked.** `C_AuctionHouse` ships in full (§0.1) | Measure the *numbers*: throttle, caps, owner fields. `/fprobe ah` then `/fprobe ah scan` |
| Claude Code bridge | Tooling, built alongside. Viable but human-in-the-loop (§0.2) | Confirm the SavedVariables write and the `BridgeData.lua` inbound path on this build |
| Guild management | **Scrapped** 2026-09-17 | None. Not a focus question; do not probe or design for it |
| Rotation helper | **Shelved** — but `C_AssistedCombat` is present (§0.4) | Efe's call whether that revives it. Until then: no design, no scaffolding |

Two plans, not four. The economy addon is the actual objective. The bridge is tooling for
talking to Claude Code from inside a running client — general-purpose, not WoW-specific,
and expected to be reused across projects — so it is worth building even though it is not
the goal. Guild management was dropped to avoid splitting focus, not because anything
blocks it; the guild APIs are almost certainly fine, which is exactly why the question is
not interesting.

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
diffing masked values — the probe now calls all of them in both combat states and prints
the delta. If the gates read false out of combat, the black box is combat-scoped and both
live plans are untouched by it.

One practical consequence for the probe: a secret value **throws** on `tostring()`, on
comparison, and even on a boolean test. Reads that look safe are not.

### 0.4 `C_AssistedCombat` is present — watch trigger 4 has fired

`C_AssistedCombat` exists on this build with four functions: `IsAvailable`,
`GetRotationSpells`, `GetNextCastSpell`, `GetActionSpell`. This is the specific thing
listed as reviving the rotation helper: Blizzard's own rotation-assist API, in Forever,
which would tell an addon what to cast next without the addon reading combat state at all.

**Recorded, not acted on.** The rotation helper stays shelved, no design or scaffolding
follows from this, and the probe only calls the two no-argument functions to record what
they return. Reopening the plan is Efe's call, not a conclusion this document draws.

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

Worth tracking. This repo's commits will answer the black-box question before Blizzard
documents anything. If the combat log still fires with full fields in Forever, the
restriction is narrower than §1 implies.

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
   API.** What replaces it as the top question is the numbers — scan throttle, result
   caps, and whether owner names survive in `ReplicateItems`. Only `/fprobe ah scan`
   answers those. `auction-addon-architecture.md` §2.
2. **Answered 2026-09-18 (§0.2), with two caveats.** The sandbox is intact, the inbound
   channel is the generated `.lua` file executed at load, and `C_EncodingUtil` gives both
   directions a real wire format. The caveats are the open work: SavedVariables are not
   read back on this build, and `ReloadUI()` is protected, so every refresh costs a human
   typing `/reload`. `auction-addon-architecture.md` §5.
2a. Will Forever expose auction data through Blizzard's Game Data API? No Classic title
   has since late 2024, and TSM's entire architecture depends on that feed. This gates
   what *kind* of economy addon is possible, independently of question 1.
   `auction-addon-architecture.md` §7.
3. Is the black box combat-only or always-on? Now cheap to answer: `C_Secrets` exposes
   the gates directly and `/fprobe report` diffs them across combat states (§0.3). Every
   gate is unit/spell/combat-scoped, so the expected answer is combat-only and the two
   live plans are clear — this is the confirmation, not the discovery.
4. Does `COMBAT_LOG_EVENT_UNFILTERED` still fire with full fields?
5. What is actually inside "certain restrictions"? Only a published list or the beta
   client answers this.

6. Does `C_AssistedCombat` work for a player, and is it gated? It is present (§0.4) and
   is a trigger-4 item. Measured only; reopening the rotation helper is Efe's call.

**Answered 2026-09-17:** does Forever inherit the Midnight doctrine? Yes on the read side,
per Tim Jones (§1) — hedged, but on the record. §0.3 shows the machinery that implements
it, and shows it is scoped to units, spells and combat.

**Answered 2026-09-18:** which AH API, and what crosses the client boundary — §0.1, §0.2.
