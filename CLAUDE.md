# WoW Forever addon experimentation

Empirical investigation of what addons can actually do in World of Warcraft: Forever
(Blizzard's Classic+ title, launches 2026-11-04; beta from 2026-09-17). The goal is to
decide which of four planned addons are buildable, using evidence from the live client
rather than press reporting.

## Read this first

- `docs/findings.md` — everything established so far, with sources and confidence levels.
  Read it before answering any question about what Forever permits.
- `docs/auction-addon-architecture.md` — how existing auction addons acquire, store, price
  and act on market data. Read it before designing anything Auction House related.
- News monitoring does **not** happen in this repo. A scheduled task owns it:
  `C:\Users\efeay\.claude\scheduled-tasks\wow-forever-addon-watch\seen.md`. Read that file
  for the latest external information; do not duplicate its searching here.

## The addon plans (pruned 2026-09-17)

Two plans, down from four. Don't add a third.

| Plan | Status | Blocker |
|---|---|---|
| Economy / TradeSkillMaster-style | **The goal — unblocked 2026-09-18** | None. Forever ships the full modern `C_AuctionHouse`; what is left is measuring throttle and caps |
| Claude Code bridge | Tooling, built alongside | Partly. Sandbox intact, inbound `.lua` channel works, but `ReloadUI()` is protected so a human must `/reload` |
| Guild management | **Scrapped** 2026-09-17 | None — dropped to keep focus, not blocked |
| Rotation helper | **Shelved** 2026-09-17 | Read side restricted. `C_AssistedCombat` is present in the beta, which is a revival trigger — Efe's call, not Claude's |

The economy addon is what this project is for. The bridge is **general-purpose tooling for
talking to Claude Code from inside a running client**, not a WoW feature — it is expected
to be reused across projects, which is why it survives the cut even though it is not the
goal. Treat its design as "what channel exists across the client boundary", not "what
WoW notifications look nice".

Guild management is scrapped: nothing blocks it, which is precisely why it was not worth
the divided attention. Do not probe for it, design it, or reopen it without Efe asking.

The rotation helper is not an active plan: do not design, scaffold, or spec against it. It
gets exactly one probe kill-check (`docs/findings.md` §7) and comes back only if the black
box turns out to be readable out of combat — and even then only as a pre-pull planning
display, not a live recommender.

## The central question

Blizzard's disarmament doctrine (Ion Hazzikostas, for Midnight) treats combat state as a
black box: addons may restyle the box but not look inside. Addons cannot know target
buffs/debuffs, cannot determine cooldown states, and cannot parse combat events in real
time.

**A capture of the live beta client (`docs/findings.md` §0, fetched and queried 2026-09-18)
has moved most of this.** Forever is the Retail API set on interface 16001, the restriction
is implemented as `C_Secrets` gates that are all unit/spell/combat-scoped, and neither the
Auction House nor any bridge channel appears in a restriction surface.

**Question 1 — does Forever inherit it — is answered.** Tim Jones, on camera at BlizzCon
2026: there will be "parity between certain restrictions... in terms of the information
that add-ons have access to". That is the read side, which is the half that kills a
rotation helper. Blizzard shipping its own damage meter and cooldown manager in Forever
points the same way. Hedged with "certain restrictions" and "probably", and no restriction
list has been published, but the Midnight→Forever link is no longer a press inference.

What is still open, in order:

1. The Auction House **numbers**: real scan throttle, result caps, and whether
   `ReplicateItems` still carries owner names. The API question itself is answered —
   modern `C_AuctionHouse`, 85 functions, no legacy API. `/fprobe ah scan` is the only
   thing that answers the rest.
2. Does the bridge's round trip survive this build? The sandbox is intact and the inbound
   generated-`.lua` channel is the mechanism, but on the beta the client writes
   SavedVariables and never reads them back, and `ReloadUI()` is protected. The outbound
   half can still be fine — that is what `collect-savedvars.ps1` decides.
3. Is the box closed **only in combat**, or at all times? Now cheap: `C_Secrets` exposes
   the gates and `/fprobe report` diffs them across combat states. Expected answer is
   combat-only, so this is a confirmation and a collateral-damage check.

`ForeverProbe` exists to answer these from our own client. Prioritise its out-of-combat
run: that alone resolves both live plans. Presence is already known from §0 — what the
probe adds is permission, returned values, and runtime gating.

## Working rules

- **Evidence beats reporting.** Probe output supersedes any news article, including
  Blizzard's own posts, which are written for retail and may not describe Forever.
- **Never cite a source without fetching it.** Search snippets have been actively
  misleading on this topic; one earlier source was cited as the best technical lead and
  turned out to be about spoiler etiquette.
- **A blocked action does not always raise a Lua error.** It often fires
  `ADDON_ACTION_BLOCKED` or `ADDON_ACTION_FORBIDDEN` instead. Any test using `pcall` alone
  will report a false "allowed". The probe captures both events.
- **A black box does not error either.** Restricted reads return `nil`, `0`, or masked
  values while the function stays present. Compare returned *values* across combat states,
  never just whether the call succeeded.
- **Don't build on the in-combat restriction as a reason to abandon a plan** unless a
  source or probe result explicitly extends it to a non-combat state. The rotation helper
  was shelved on a dev statement about *information access*, not on this rule; that
  statement reaches nothing either live plan reads.
- Known SEO junk sites producing confident unsourced claims — exclude them:
  warcraftforever.games, world-of-warcraft-forever.wiki, pewpewshop.pro, woweternity.com.
- `ign.com` and `massivelyop.com` return 403 to plain fetching; use a browser tool.

## Workflow

```
edit addons/ForeverProbe/  ->  scripts/install-addon.ps1  ->  play, run /fprobe
  ->  scripts/collect-savedvars.ps1  ->  results land in data/  ->  analyse, commit
```

Probe usage in-game:

- `/fprobe` — static API surface scan plus action and read tests, out of combat
- `/fprobe ah` — Auction House detail; run it standing at an auction house
- `/fprobe ah scan` — fire a full `ReplicateItems` scan. Burns the 15-minute throttle
- `/fprobe bridge` — inbound `BridgeData.lua` and outbound SavedVariables flush
- `/fprobe combat` — re-run the tests while actually in combat (pull a mob first)
- `/fprobe report` — print the out-of-combat vs in-combat delta

The bridge check needs a write from outside the game first:
`scripts/write-bridge-data.ps1`, then `/reload`, then `/fprobe bridge`. That script
writes into the *installed* addon folder, and `install-addon.ps1` preserves the
installed `BridgeData.lua` unless you pass `-ResetBridgeData`.

Both runs are required before the delta means anything. `/reload` or log out to flush
SavedVariables.

## Cautions

- The `.toc` declares `16001`, measured on beta build 1.60.1.69893. `/fprobe` prints the
  client's own number; if they disagree, the client wins. The beta product folder is
  `_classic_beta_`, which is what the scripts now default to.
- Registering an event this client does not know **throws and aborts the rest of the
  file**, and a secret value throws on `tostring()` or a boolean test. Both have already
  cost a silent probe failure elsewhere; keep every registration and every combat-state
  read inside `pcall`.
- The action tests deliberately attempt things that may be blocked. That is the point.
  They are harmless, but `SendChatMessage` tests were removed precisely because they would
  speak in the world; do not reintroduce them without thinking about that.
- Run tests somewhere quiet, on a character nobody cares about.
