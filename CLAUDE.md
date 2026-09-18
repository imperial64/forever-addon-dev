# forever-addon-dev

A Claude Code plugin for building World of Warcraft: Forever addons (Blizzard's Classic+
title, launches 2026-11-04; beta from 2026-09-17).

This began as an empirical investigation into whether a TradeSkillMaster-style economy
addon was buildable. That investigation is **finished** - every question it set out to
answer is answered - and the repo is now the plugin those answers pay for. The research did
not get archived: it is the plugin's evidence base, and the git history is kept, because a
restriction list is only trustworthy if you can see the commits that measured it.

## Read this first

- `research/findings.md` - everything measured, with confidence levels. Section P is our
  own client and outranks everything; section 0 is a third-party capture of the same build;
  sections 1-8 are press and dev statements. Read it before answering any question about
  what Forever permits.
- `research/restrictions.yaml` - the same material as machine-readable entries. This is the
  single hand-maintained source: the generator emits page banners, `data/restrictions.json`
  and `reference/api/RESTRICTIONS.md` from it, so they cannot drift. **Edit restrictions
  here, never in the generated tree.**
- `research/auction-addon-architecture.md` - how auction addons acquire, store, price and
  act on market data. Read it before designing anything Auction House related.
- News monitoring does **not** happen in this repo. A scheduled task owns it, under
  `.claude/scheduled-tasks/wow-forever-addon-watch/seen.md` in Efe's home directory.

## What this repo produces

| Piece | What it is |
|---|---|
| `skills/` | What Claude loads: `build`, `api`, `restrictions`, `regenerate` |
| `reference/api/` | **Generated.** One page per symbol, path derivable from the name. 15,049 pages |
| `reference/guides/`, `reference/restrictions/` | Hand-written, for an outside reader |
| `tools/` | The generator, the linter, the SavedVariables parser. Python, so plugin users need no Lua runtime |
| `addons/ForeverProbe/` | The probe - and the doc generator the `regenerate` skill drives |
| `scripts/` | Install to the client, collect results back. PowerShell, because they touch a Windows WoW install |
| `research/` | The lab notebook, kept as the cited evidence base |

**Generated versus hand-written is a directory boundary.** Everything under
`reference/api/` carries a generated header and is rewritten wholesale; editing it by hand
is always wrong. Determinism there is load-bearing: no per-symbol page carries a timestamp,
so regenerating against a newer client produces a diff that *is* the patch delta.

## Research status: closed

| Question | Answer |
|---|---|
| Which Auction House API | Modern `C_AuctionHouse`, 85 functions, no legacy API. All four numbers measured (P.15, P.17) |
| Any channel across the client boundary | Both directions work; costs a manual `/reload` (P.9) |
| Combat-only or always-on | Three separate systems, none touching either live plan (P.18) |
| Combat log | Addons may not subscribe, either form (P.1, P.12) |

The economy addon is unblocked and is the flagship worked example. The Claude Code bridge
is general-purpose tooling for talking to Claude Code from inside a running client. Guild
management was scrapped 2026-09-17 for focus. The rotation helper is **closed** -
`C_AssistedCombat` turned out to be present, which was its stated revival trigger, and Efe
declined to reopen on it. Do not raise it again without Efe raising it first.

## Where this is up to (2026-09-18)

The plugin works end to end: it installs, the reference generates from a capture, the four
skills route. Remaining, in order:

1. **`tools/lint-addon.py`** - check addon source against `data/restrictions.json` and the
   presence surface. Verification that matters: run it against
   `addons/ForeverProbe/ForeverProbe.lua`, which is already correct for this client, and it
   should flag nothing. Then break a copy deliberately and confirm each check fires.
2. **`examples/economy-addon/`** - the flagship example, scaffolded by the `build` skill as
   the dogfood test. Browse is the data source, not `ReplicateItems`.
3. `reference/guides/` and `reference/restrictions/` are empty; the skills point at
   `research/` instead, which is written for us rather than for a stranger.
4. No git remote yet, so `plugin.json` carries no `homepage` or `repository`.

Two measurements to redo in game when convenient: `SecureActionButton:SetAttribute`
apparently succeeding **in combat** (P.20 - flagged `caution`, retail protects it), and the
three `C_Secrets` gates with no out-of-combat value because the chat line truncated
(`UnitSpellCast`, `UnitThreatState`, `UnitThreatValues`).

## Working rules

- **Evidence beats reporting.** Probe output supersedes any news article, including
  Blizzard's own posts, which are written for retail and may not describe Forever.
- **Never cite a source without fetching it.** Search snippets have been actively
  misleading on this topic; one earlier source was cited as the best technical lead and
  turned out to be about spoiler etiquette.
- **A blocked action does not always raise a Lua error.** It often fires
  `ADDON_ACTION_BLOCKED` or `ADDON_ACTION_FORBIDDEN` instead. Any test using `pcall` alone
  will report a false "allowed". The probe captures both events.
- **This applies to `RegisterEvent` too, which is where it actually bit us.** Measured
  2026-09-18: registering `COMBAT_LOG_EVENT_UNFILTERED` is forbidden, returns normally,
  and the frame simply never receives the event. A refusal can be a refusal to *listen*,
  not just a masked value — check `/fprobe blocked` after any run.
- **A black box does not error either.** Restricted reads return `nil`, `0`, masked
  values, or a *secret* value while the function stays present. Compare returned *values*
  across combat states, never just whether the call succeeded.
- **Secret values are contagious and `tostring()` does not launder them.** Measured
  2026-09-18: `tostring()` of a secret returns a secret *string*, so a `pcall` around the
  read reports success and the value throws later, wherever it is next indexed — which is
  usually a print or a format, far from the read. Use `issecretvalue` before and after
  conversion, and always before storing: a secret string in the DB would take the whole
  SavedVariables flush with it. The probe's `plain()` helper is the only sanctioned way to
  turn a game read into text.
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
  ->  scripts/collect-savedvars.ps1  ->  captures land in research/captures/
  ->  tools/build_reference.py  ->  reference/api/  ->  commit
```

Probe usage in-game:

- `/fprobe` — static API surface scan plus action and read tests, out of combat
- `/fprobe ah` — Auction House detail, shapes and throttle state; run it standing at an
  auction house
- `/fprobe ah browse [rounds]` — the cheap measurement: fires one browse query and walks
  `RequestMoreBrowseResults`, timing each round, to find the per-query cap. Costs nothing
  and can be repeated
- `/fprobe ah scan` — fire a full `ReplicateItems` scan. Burns the 15-minute throttle
- `/fprobe ah throttle` — what the throttle actually turned out to be. Stay logged in
  after a scan; the client announces it and the probe prints the measured gap
- `/fprobe bridge` — inbound `BridgeData.lua` and outbound SavedVariables flush
- `/fprobe video` — the brightness/contrast CVars: whether they exist under the retail
  names, whether `GetCVarInfo` reports them locked, secure or read-only, whether a write
  survives a readback, and which display mode the measurement was taken in. Enumerates the
  real names out of `ConsoleGetAllCommands` rather than trusting the retail ones. Every
  value it touches is restored. Run it again in combat for the other half
- `/fprobe video ramp [cvar]` — sweep one of them down and back over four seconds. This is
  the measurement that decides whether a smooth ease is possible: it writes every frame
  from `OnUpdate` and reports the frame gaps, so a device restart per write shows up as a
  spike. Whether the *screen* changed is yours to report — a write that is accepted and
  ignored looks identical from Lua
- `/fprobe blocked` — every `ADDON_ACTION_BLOCKED`/`FORBIDDEN` captured, attributed to the
  call that caused it. Run it after any forbidden-action popup
- `/fprobe events` — which events an addon may subscribe to at all. Each refusal pops a
  dialog; press Ignore
- `/fprobe combat` — re-run the tests while actually in combat (pull a mob first)
- `/fprobe report` — print the out-of-combat vs in-combat delta
- `/fprobe docs` — does Blizzard's own API documentation load, and what shape is it
- `/fprobe docs dump [start] [count]` — dump it into SavedVariables for the generator
- `/fprobe docs version` — whether the shipped reference still matches this client

The bridge check needs a write from outside the game first:
`scripts/write-bridge-data.ps1`, then `/reload`, then `/fprobe bridge`. That script
writes into the *installed* addon folder, and `install-addon.ps1` preserves the
installed `BridgeData.lua` unless you pass `-ResetBridgeData`.

Both runs are required before the delta means anything, and **both must happen in one
session**: this build writes SavedVariables and never reads them back, so a `/reload`
discards whichever pass came first. `/reload` or log out to flush.

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
