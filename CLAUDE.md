# forever-addon-dev

A Claude Code plugin for AI-assisted development of World of Warcraft: Forever addons
(Blizzard's Classic+ title, launches 2026-11-04; beta from 2026-09-17).

The plugin exists because Forever ships Retail's API on interface `16001` with Midnight's
restrictions and no published restriction list. So the restrictions were measured against a
live client with a probe addon, and the API reference was generated from the client's own
documentation. This repository is itself built with AI assistance; what keeps that
trustworthy is that every claim in it is measured and the measurement is checked in beside
the claim.

The plugin is addon-agnostic. It has no opinion about what anyone should build, and it
should not acquire one: the reference covers the whole API surface and the restriction list
is whatever the client enforces.

## Read this first

- `research/findings.md` — everything measured, with confidence levels. Section P is a
  measurement on a live client and outranks everything; section 0 is a third-party capture
  of the same build; the numbered sections are press and developer statements. Read it
  before answering any question about what Forever permits.
- `research/watch-findings.md` — an **inbox**, not evidence: unverified leads from the
  daily watch, queued for investigation. Nothing here may be cited as a fact or promoted
  into the restriction data until it has been measured, or fetched and written up in
  `research/findings.md`.
- `research/restrictions.yaml` — the same material as machine-readable entries. This is the
  single hand-maintained source: the generator emits page banners, `data/restrictions.json`
  and `reference/api/RESTRICTIONS.md` from it, so they cannot drift. **Edit restrictions
  here, never in the generated tree.**
- `research/costs.yaml` — what a *permitted* call costs, same shape and same contract:
  page banners, `data/costs.json` and `reference/api/COSTS.md` are generated from it.
  Separate from the restriction list on purpose. A restriction is policy and is the same on
  every machine; a cost is a measurement on one machine on one build, and nothing here
  re-measures it. Keeping them apart is what stops a stale number sitting under a heading
  that promises measured policy.

## What this repo produces

| Piece | What it is |
|---|---|
| `skills/` | What Claude loads: `build`, `api`, `restrictions`, `regenerate` |
| `reference/api/` | **Generated.** One page per symbol, path derivable from the name. 15,049 pages |
| `reference/guides/`, `reference/restrictions/` | Hand-written, for an outside reader |
| `tools/` | The generator, the linter, the SavedVariables parser. Python, so plugin users need no Lua runtime |
| `addons/ForeverProbe/` | The probe — and the doc generator the `regenerate` skill drives |
| `scripts/` | Install to the client, collect results back. PowerShell, because they touch a Windows WoW install |
| `research/` | The measurement record the restriction and cost data are drawn from |

**Generated versus hand-written is a directory boundary.** Everything under
`reference/api/` carries a generated header and is rewritten wholesale; editing it by hand
is always wrong. Determinism there is load-bearing: no per-symbol page carries a timestamp,
so regenerating against a newer client produces a diff that *is* the patch delta.

## Where this is up to (2026-09-20)

The plugin works end to end: it installs, the reference generates from a capture, the four
skills route, and `tools/lint_addon.py` runs clean against `addons/ForeverProbe/ForeverProbe.lua`,
which is already correct for this client.

Remaining:

1. `reference/guides/` and `reference/restrictions/` cover the essentials; they are thinner
   than the material in `research/` and worth extending.
2. Worked examples under `examples/` — a scaffolded addon the `build` skill produces, kept
   as a dogfood test.

Two measurements to redo in game when convenient: `SecureActionButton:SetAttribute`
apparently succeeding **in combat** (P.20 — flagged `caution`, retail protects it), and the
three `C_Secrets` gates with no out-of-combat value because the chat line truncated
(`UnitSpellCast`, `UnitThreatState`, `UnitThreatValues`).

**Ran 2026-09-20** across three sessions; captures `ForeverProbe_2026-09-20_*`, written up
as §P.23 to §P.28. What changed:

1. **SavedVariables: no persistence across sessions, on either directive.** Account-wide is
   never read back; per-character survives a `/reload` but not a logout. Neither the
   binding idiom nor the load order is the variable, and the exotic WTF paths other
   developers named are neither read nor written. §P.23, §P.27
2. **Secrecy is gated per UNIT, not by combat.** A target's health, max health, power and
   max power are secret standing out of combat, on a friendly NPC and a hostile mob alike.
   The player's own health and power are secret too, but its maxima are not. Level, name,
   GUID and class stay readable on everything. §P.25, §P.28
3. **`type()` says "number" on a secret, and `==` throws.** Comparison, arithmetic and
   equality are loud; `tostring()` and `..` are silent and hand back secret strings. Only
   `issecretvalue` is a test. §P.25, §P.28
4. **The Secret surface is a 38-key taxonomy in the client's own documentation**, 5,145 of
   29,416 entries, `SecretWhenInCombat` on four of them. Per-category gating is Blizzard's
   own model. §P.26
5. Interface formula, no `WOW_PROJECT_*`, empty `GetCurrentRegionName()`, and
   `GetNamePlateForUnit` refusing target-of-target: confirmed. Realm identity is stable;
   the character name genuinely contains a space, which is what the port diary's broken
   AceDB key was really about. §P.24

Worth doing next, in the repo rather than in game:

1. **Move the probe's DB to `## SavedVariablesPerCharacter`** — §P.27 measured that this
   survives a `/reload`, which lifts §P.21's "both passes in one session" constraint.
2. **Teach the generator the Secret taxonomy** (§P.26). `projectField`/`projectFunction`
   capture a single `Secret` field; widen to every key matching the pattern and the
   machine-readable half of `restrictions.yaml` becomes generable.

§Q is the one section no instrument in this repo can refresh. It is data measured by addons
in another repository, and `/fprobe` reproduces none of it, so a new build invalidates those
numbers silently. The captures are checked in; a `/fprobe cost` subcommand would close the
gap and has not been written. Three §Q items are unverified reads: whether an addon can
*write* `useMaxFPS` (Q.1 measured reads only), what `C_Map.GetPlayerMapPosition` does inside
an instance (Q.2), and `UnitPosition`'s return order — the client's documentation says X
first, retail folklore says Y first, and Q.8 measured only its allocation.

**Merged 2026-09-20: a second handoff from `dynamic-ambiance-forever`.** Nine items; see the
summary in that repo's `handoff/forever-addon-dev-2026-09-20.md` for what was offered. The
one that moved the record is **§P.29 — `SetCVar` on the display CVars is permitted in
combat**, measured in both states one pull apart, which closes the caveat §P.22 stated and
lets `graphics-cvars-writable` drop its freeze-on-`PLAYER_REGEN_DISABLED` workaround. §P.29
is the only §P finding not produced by `/fprobe`, and it says so in place. The rest landed in
§Q (allocation cost of a CVar write, `UnitPosition`, indoor behaviour, `IsIndoors` vs
`GetSubZoneText`, Lua 5.1 vs LuaJIT) and in the guides. One offered lead — a possible frame
rate cost to per-frame writes — was **not** recorded as a finding; §Q.7 states why and
forbids citing it.

## Working rules

- **Evidence beats reporting.** Probe output supersedes any news article, including
  Blizzard's own posts, which are written for retail and may not describe Forever.
- **Never cite a source without fetching it.** Search snippets have been actively
  misleading on this topic; one earlier source was cited as the best technical lead and
  turned out to be about spoiler etiquette.
- **A blocked action does not always raise a Lua error.** It often fires
  `ADDON_ACTION_BLOCKED` or `ADDON_ACTION_FORBIDDEN` instead. Any test using `pcall` alone
  will report a false "allowed". The probe captures both events.
- **This applies to `RegisterEvent` too, which is where it actually bit.** Measured
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
- **`type()` and `==` do not reveal a secret either.** Measured 2026-09-20: `type()` on a
  secret number returns `"number"`, and `value == value` THROWS — so `if v == nil then`,
  the guard written out of caution, is itself unsafe. `issecretvalue` is the only test.
- **Do not extend the in-combat restrictions to non-combat states** unless a source or
  probe result explicitly says so. Several published claims conflate the two. Note the
  converse bit too: §P.25 found `UnitHealth` secret *out* of combat, and the client's own
  documentation marks only four entries `SecretWhenInCombat` (§P.26). Combat is a minor
  axis in this system, not the organising one.
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
- `/fprobe external` — the out-of-game data channel: inbound `ExternalData.lua` and the
  outbound SavedVariables flush
- `/fprobe sv` — the SavedVariables experiment: load order, which binding idiom survives,
  and which WTF path the client actually reads. Run `scripts/seed-savedvars.ps1` and
  restart the client first; it seeds a differently tokenised file into all four candidate
  paths at once, so whichever token arrives names the path that works. Settles
  `research/findings.md` §12
- `/fprobe port` — the porting checks: whether interface `16001` really is `%d%02d%02d` of
  the version triple, which `WOW_PROJECT_*` constants exist, `GetCurrentRegionName()`,
  `GetNamePlateForUnit()` on target-of-target, and realm identity. §9 to §11
- `/fprobe secrets` — masked vs secret vs half-secret vs plain, per unit and per read, each
  operation in its own `pcall`. Run it in both combat states; the delta is the finding.
  §14
- `/fprobe video` — the brightness/contrast CVars: whether they exist under the retail
  names, whether `GetCVarInfo` reports them locked, secure or read-only, whether a write
  survives a readback, and which display mode the measurement was taken in. Enumerates the
  real names out of `ConsoleGetAllCommands` rather than trusting the retail ones. Every
  value it touches is restored. The in-combat half is answered — §P.29, by a third-party
  instrument — but `/fprobe` has still never been run mid-fight here, and doing so would be
  an independent check on a result this repo currently takes from outside
- `/fprobe video ramp [cvar]` — sweep one of them down and back over four seconds. This is
  the measurement that decides whether a smooth ease is possible: it writes every frame
  from `OnUpdate` and reports the frame gaps, so a device restart per write shows up as a
  spike. Whether the *screen* changed is for the operator to report — a write that is
  accepted and ignored looks identical from Lua
- `/fprobe blocked` — every `ADDON_ACTION_BLOCKED`/`FORBIDDEN` captured, attributed to the
  call that caused it. Run it after any forbidden-action popup
- `/fprobe events` — which events an addon may subscribe to at all. Each refusal pops a
  dialog; press Ignore
- `/fprobe combat` — re-run the tests while actually in combat (pull a mob first)
- `/fprobe report` — print the out-of-combat vs in-combat delta
- `/fprobe docs` — does Blizzard's own API documentation load, and what shape is it
- `/fprobe docs secrets` — how many documented entries carry a `Secret`-shaped key. If the
  reported 4,025 reproduces, the restriction list becomes generable rather than
  hand-probed. The key name is discovered, not assumed. §13
- `/fprobe docs dump [start] [count]` — dump it into SavedVariables for the generator
- `/fprobe docs version` — whether the shipped reference still matches this client

The external-channel check needs a write from outside the game first:
`scripts/write-external-data.ps1`, then `/reload`, then `/fprobe external`. That script
writes into the *installed* addon folder, and `install-addon.ps1` preserves the
installed `ExternalData.lua` unless you pass `-ResetExternalData`.

Both runs are required before the delta means anything, and **both must happen in one
session**: this build writes SavedVariables and never reads them back, so a `/reload`
discards whichever pass came first. `/reload` or log out to flush.

That one-session constraint is **liftable and has not been lifted yet**. §P.27 measured
that a `## SavedVariablesPerCharacter` global survives a `/reload` while an account-wide
one does not, so moving the probe's DB would let the two passes span a reload. Until that
change is made, the constraint above still applies as written.

## Cautions

- The `.toc` declares `16001`, measured on beta build 1.60.1.69893. `/fprobe` prints the
  client's own number; if they disagree, the client wins. The beta product folder is
  `_classic_beta_`, which is what the scripts now default to.
- Registering an event this client does not know **throws and aborts the rest of the
  file**, and a secret value throws on `tostring()` or a boolean test. Both have already
  cost a silent probe failure; keep every registration and every combat-state read inside
  `pcall`.
- The action tests deliberately attempt things that may be blocked. That is the point.
  They are harmless, but `SendChatMessage` tests were removed precisely because they would
  speak in the world; do not reintroduce them without thinking about that.
- Run tests somewhere quiet, on a character nobody cares about.
