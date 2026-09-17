# Findings — WoW Forever addon capabilities

Last updated 2026-09-17. Everything here predates any client testing; all of it is
superseded by probe output once that exists.

Confidence labels: **[PRIMARY]** fetched and read directly · **[REPORTED]** credible
secondary source, fetched · **[UNVERIFIED]** surfaced in search, not independently
confirmed · **[EXCLUDED]** checked and found irrelevant or unreliable.

**Plan status after the 2026-09-17 pruning pass:**

| Plan | Status | Next action |
|---|---|---|
| Economy / TSM-style | **The goal.** Everything else is secondary | Probe `C_AuctionHouse` vs `QueryAuctionItems` |
| Claude Code notification bridge | Tooling, built alongside | Probe `io` / `os` / CVar / SavedVariables flush behaviour |
| Guild management | **Scrapped** 2026-09-17 | None. Not a focus question; do not probe or design for it |
| Rotation helper | **Shelved** 2026-09-17 | One probe kill-check (§7); do not design against it |

Two plans, not four. The economy addon is the actual objective. The bridge is tooling for
talking to Claude Code from inside a running client — general-purpose, not WoW-specific,
and expected to be reused across projects — so it is worth building even though it is not
the goal. Guild management was dropped to avoid splitting focus, not because anything
blocks it; the guild APIs are almost certainly fine, which is exactly why the question is
not interesting.

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

Ordered by what it now decides. The first rows run entirely out of combat and settle both
live plans; the combat run only closes out the shelved one.

| Probe output | Conclusion |
|---|---|
| `C_AuctionHouse` present | Economy addon viable, retail AH code largely ports |
| Only `QueryAuctionItems` etc. | Classic-era AH API: throttled, full-scan, much slower addon |
| Neither AH API | Economy plan is dead as designed — and the project loses its goal |
| `io` / `os` absent (expected) | Bridge cannot read live inbound data; needs `/reload`, a CVar, or a pixel channel |
| `SendAddonMessage` / `SetCVar` present | Candidate inbound and sideband channels for the bridge |
| `targetAura1` readable out of combat, `nil` in combat | Black box is real and combat-scoped; rotation helper stays shelved, pre-pull display only |
| `targetAura1` unreadable in both states | Black box is always-on — close the rotation helper and re-check both live plans for collateral reads |
| `targetAura1` readable in both states | Contradicts §1; re-verify before believing it |
| `spellCooldownStart` masked in combat | Cooldown tracking gone; matches Blizzard shipping its own cooldown manager |
| Combat log events stop or lose fields in combat | Real-time parsing gone |
| `C_AssistedCombat` present | Blizzard ships its own rotation assist; different game entirely, watch trigger 5 fires |

## Open questions, in priority order

1. Which Auction House API, if any? Gates the economy plan, which is the project's goal.
2. Any out-of-game export channel beyond SavedVariables, and anything usable *inbound*?
   Gates the bridge.
3. Is the black box combat-only or always-on? — decides the shelved rotation helper, and
   is the cheap check that the two live plans are not caught by collateral damage.
4. Does `COMBAT_LOG_EVENT_UNFILTERED` still fire with full fields?
5. What is actually inside "certain restrictions"? Only a published list or the beta
   client answers this.

**Answered 2026-09-17:** does Forever inherit the Midnight doctrine? Yes on the read side,
per Tim Jones (§1) — hedged, but on the record.
