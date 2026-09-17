# Findings — WoW Forever addon capabilities

Last updated 2026-09-17. Everything here predates any client testing; all of it is
superseded by probe output once that exists.

Confidence labels: **[PRIMARY]** fetched and read directly · **[REPORTED]** credible
secondary source, fetched · **[UNVERIFIED]** surfaced in search, not independently
confirmed · **[EXCLUDED]** checked and found irrelevant or unreliable.

---

## 1. Addons exist in Forever

**[PRIMARY]** [Kotaku, 2026-09-14, Rebekah Valentine](https://kotaku.com/new-things-learned-world-of-warcraft-forever-2000734005)
— interview at BlizzCon 2026 with lead Classic designer Tim Jones and lead encounter
designer Mike Nuthals.

Nuthals says Forever carries over retail's in-combat addon disarmament: players will not
have access to computational addons that programmatically automate marking or
communicating for players.

This is the first and so far only on-the-record confirmation that addons are supported at
all. Note the exact phrasing was "the in-game **or** in-combat add-on disarmament". Whether
"in-game" is loose speech for "in-combat" or signals something broader is unresolved, and
it matters a great deal.

No mention of the Auction House, economy data, companion apps, or data export.

---

## 2. The disarmament doctrine is much broader than that one line

**[PRIMARY]** [Blizzard news, Ion Hazzikostas, Game Director — "Combat Philosophy and Addon
Disarmament in Midnight"](https://news.blizzard.com/en-us/article/24246290/combat-philosophy-and-addon-disarmament-in-midnight)

Written for **Midnight (retail)**, not Forever. Press reports say Forever inherits it.

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

**Why this is the important document.** It is a *read-side* restriction. The Kotaku line
reads like retail's familiar execute-side rule, where an addon may suggest an ability but
not press it — that rule leaves rotation helpers like Hekili and WeakAuras perfectly legal.
The black box is a different and much harsher thing: it removes the inputs, so a rotation
helper cannot compute a recommendation to display in the first place.

The post does **not** say whether the box is closed only during combat or at all times, and
does not name WeakAuras, Hekili, rotation helpers, the Auction House, or out-of-game data.

---

## 3. Corroboration that this ends rotation helpers

**[UNVERIFIED]** Hekili's maintainer announced the addon sunsets with retail's Midnight
12.0 pre-patch, because the new APIs remove the spell-simulation hooks it relied on.
Surfaced as https://x.com/hekili808/status/1973479282006696123 with a reported date of
2026-01-20, which looks inconsistent with the status ID. Treat as corroboration, not fact,
until fetched directly. This is about retail, not Forever.

**[UNVERIFIED]** A successor called "HekiLight" built on Blizzard's own `C_AssistedCombat`
API was mentioned for retail Midnight. No source claims it targets Forever. If Blizzard
ships an official rotation assist while disarming third-party ones, that reframes the whole
question — hence `C_AssistedCombat` is in the probe's scan list.

**[UNVERIFIED]** https://us.forums.blizzard.com/en/wow/t/addonsweakauras-restricted/2350657
— official forum thread about WeakAuras being restricted in Forever. Not yet fetched. No
allow-list published.

---

## 4. The one live empirical signal from another developer

**[UNVERIFIED]** https://github.com/Caeth/CleanCombatLog — "Combat log addon for world of
warcraft: forever", a developer actively testing whether Forever permits
`COMBAT_LOG_EVENT_UNFILTERED`.

Worth tracking. This repo's commits will answer the black-box question before Blizzard
documents anything. If the combat log still fires with full fields in Forever, the doctrine
did not carry over intact.

---

## 5. Load-bearing link not yet verified

**[REPORTED, NOT FETCHED]** [GamesRadar](https://www.gamesradar.com/games/world-of-warcraft/world-of-warcraft-forever-takes-page-out-of-retails-book-as-blizzard-confirms-access-to-add-ons-will-be-restricted-in-the-throwback-mmo/)
— press reporting that Blizzard confirmed Forever restricts computational
combat/communication addons as retail does.

This article is the only thing connecting the Midnight doctrine to Forever. Everything in
section 2 applies to Forever *only if this link holds*. Fetch and verify it.

---

## 6. Checked and not relevant

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

| Probe output | Conclusion |
|---|---|
| `targetAura1` readable out of combat, `nil` in combat | Black box is real and combat-scoped |
| `targetAura1` unreadable in both states | Black box is always-on — worst case, escalate |
| `targetAura1` readable in both states | Forever did **not** inherit the doctrine; rotation helper is viable |
| `spellCooldownStart` masked in combat | Cooldown tracking gone; confirms the doctrine |
| Combat log events stop or lose fields in combat | Real-time parsing gone |
| `C_AssistedCombat` present | Blizzard ships its own rotation assist; different game entirely |
| `C_AuctionHouse` present | Economy addon viable, retail AH code largely ports |
| Only `QueryAuctionItems` etc. | Classic-era AH API: throttled, full-scan, much slower addon |
| Neither AH API | Economy plan is dead as designed |
| `io` / `os` absent (expected) | Notification bridge cannot read live inbound data; needs `/reload` or a pixel bridge |

## Open questions, in priority order

1. Does Forever inherit the Midnight black box? (verify GamesRadar, then probe)
2. Combat-only, or always-on?
3. Does `COMBAT_LOG_EVENT_UNFILTERED` still fire with full fields?
4. Which Auction House API, if any?
5. Any out-of-game export channel beyond SavedVariables?
