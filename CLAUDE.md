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
| `skills/` | What Claude loads: `build`, `api`, `restrictions`, `regenerate`, `publish` |
| `reference/api/` | **Generated.** One page per symbol, path derivable from the name. 16,041 pages |
| `reference/guides/`, `reference/restrictions/` | Hand-written, for an outside reader |
| `tools/` | The generator, the linter, the SavedVariables parser. Python, so plugin users need no Lua runtime |
| `addons/ForeverProbe/` | The probe — and the doc generator the `regenerate` skill drives |
| `scripts/` | Install to the client, collect results back. PowerShell, because they touch a Windows WoW install |
| `research/` | The measurement record the restriction and cost data are drawn from |

**Generated versus hand-written is a directory boundary.** Everything under
`reference/api/` carries a generated header and is rewritten wholesale; editing it by hand
is always wrong. Determinism there is load-bearing: no per-symbol page carries a timestamp,
so regenerating against a newer client produces a diff that *is* the patch delta.

## Where this is up to (2026-09-25)

The plugin works end to end: it installs, the reference generates from a capture, the four
skills route, and `tools/lint_addon.py` runs clean against `addons/ForeverProbe/ForeverProbe.lua`,
which is already correct for this client.

Remaining:

1. `reference/guides/` and `reference/restrictions/` cover the essentials; they are thinner
   than the material in `research/` and worth extending.
2. Worked examples under `examples/` — a scaffolded addon the `build` skill produces, kept
   as a dogfood test.

Two measurements to redo in game when convenient. The first is
`SecureActionButton:SetAttribute` apparently succeeding **in combat** (P.20, flagged
`caution`, and retail protects it). §P.32 has since caught 70009 refusing a similar call by
event alone, so re-test it with the block log open. The second is the three `C_Secrets`
gates with no out-of-combat value because the chat line truncated (`UnitSpellCast`,
`UnitThreatState`, `UnitThreatValues`).

**Ran 2026-09-25 on build 1.60.1.70009**, in two client launches with a full exit and
relaunch through Battle.net between them. The captures are
`*_2026-09-25_132437_70009-s1*` and `*_132620_70009-s2*`, the plan is
`research/test-plan-70009.md`, and the write-up is §P.30 to §P.34. What changed:

1. **SavedVariables are read back on 70009**, account-wide and per-character, across
   `/reload` and across a full relaunch. A seeded token came back in all twelve companion
   globals and in the probe's own DBs. §P.23 and §P.27 remain the 69913 record. §P.30
2. **`## LoadSavedVariablesFirst: 1` is real.** With it, the restore precedes file scope, so
   an unconditional `X = {...}` destroys saved data and `X = X or {...}` keeps it. Without
   it, which is the default, the client replaces the global at `ADDON_LOADED`. That
   discards both file-scope tables and orphans any `local db` taken at file scope. §P.31
3. **Secure snippets run on 70009 out of combat**, while `loadstring_untainted` is still
   `nil`, so the global is not a feature test. In combat, `Execute` on a header made before
   combat returns normally and does nothing, apart from two `ADDON_ACTION_BLOCKED` events.
   On a header made in combat it raises "Header frame must be explicitly protected". §P.32
4. The two exotic WTF seed paths are still not read. §P.33
5. The porting checks reproduce, with one exception. `UnitName`/`UnitFullName("player")`
   now return `"Abla", "Imperial"`, so the second half of the character's name is in the
   realm slot. §P.34

Three lines the probe printed in that run are instrument bugs, not results. They are the
`/fprobe sv` "load order: undetermined … no" verdict, its "ForeverProbeDB … fresh" line, and
`/fprobe`'s "EXTERNAL outbound read-back failed". §P.30 explains each. Do not cite them.

**Ran 2026-09-20** across three sessions; captures `ForeverProbe_2026-09-20_*`, written up
as §P.23 to §P.28. What changed:

1. **SavedVariables: no persistence across sessions, on either directive**, on 69913.
   Account-wide is never read back; per-character survives a `/reload` but not a logout.
   Neither the binding idiom nor the load order is the variable, and the exotic WTF paths
   other developers named are neither read nor written. §P.23, §P.27. **Superseded on
   70009, see above.**
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
   AceDB key was really about. §P.24. On 70009 the name is split across the two return
   values instead, see §P.34.

Worth doing next, in the repo rather than in game:

1. ~~Move the probe's DB to `## SavedVariablesPerCharacter`~~ — **moot.** That move was
   only ever a way round 69913 discarding account-wide data on `/reload`. On 70009 the
   account-wide DB survives a `/reload` and a relaunch (§P.30), so there is nothing to
   route around. The probe's rebind guard is what keeps `db` pointing at the restored table
   under the default load order (§P.31). Keep the DB account-wide, which is where
   `collect-savedvars.ps1` expects the surface dump.
2. ~~Teach the generator the Secret taxonomy~~: **done 2026-09-25.** Every `Secret`-shaped
   key, plus `ChecksForbiddenAspects`, `IsProtectedFunction`, `HasRestrictions` and
   `Requires*`, is now projected and rendered verbatim on the pages and in `data/api.json`.
   The part not done yet is generating the machine-readable half of `restrictions.yaml` from
   those keys. It is still hand-maintained.
3. **Diff an in-game `/fprobe docs dump` against `tools/docs_from_source.py`** for the same
   build. The 70009 reference was generated from source. The source route reproduced the
   69913 in-game dump exactly, but the in-game dumper's new projection (enum values,
   per-function `Namespace`, shared tables, restriction keys) has not run on a client yet.

The reference can now be regenerated without a client: `tools/docs_from_source.py` on a
`Gethe/wow-ui-source` `forever` checkout fetched through `gh api`, plus a fresh `/fprobe`
surface dump for the "present on this client" stubs. `skills/regenerate/SKILL.md` has both
routes.

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
- **SavedVariables behaviour is per build, so say which build.** On 69913 nothing
  account-wide was read back, and per-character survived only a `/reload` (§P.23, §P.27).
  On 70009 both are read back across a relaunch (§P.30). By default the client
  **replaces** each saved global at `ADDON_LOADED`, after file scope, unless the `.toc`
  declares `## LoadSavedVariablesFirst: 1` (§P.31). Never take a file-scope reference to a
  saved global; bind it inside `ADDON_LOADED`. Re-run `/fprobe cold seed`, `/quit`,
  relaunch, `/fprobe cold <token>` on every new build before trusting either result.
- **An absent global is not a feature test.** Measured 2026-09-25: `loadstring_untainted`
  is `nil` on 70009, where secure snippets run (§P.32). Decide a capability by exercising it
  and reading the effect back, the same lesson as a secret value's `type()`.
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
  and which WTF path the client actually reads. §12 is now settled (§P.27, §P.30, §P.33).
  Its load-order verdict line misreads 70009 (see below), so `/fprobe cold` is the
  instrument for SavedVariables now. `scripts/seed-savedvars.ps1` overwrites the real
  account-scoped `ForeverProbe.lua`, so do not run it casually
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
- `/fprobe cold seed [reload]` — write a marker token into every saved global of the probe and
  of the two companions `ForeverProbeSV_First` (`## LoadSavedVariablesFirst: 1`) and
  `ForeverProbeSV_Late` (without). `reload` marks the `/reload` leg; plain `seed` marks the
  cold-start leg and must be the last thing before a full exit. W.30, W.32
- `/fprobe cold [token]` — what each saved global held at file scope, `ADDON_LOADED`,
  `PLAYER_LOGIN` and `PLAYER_ENTERING_WORLD`, per variant, including the file-scope clobber
  check. Pass the seeded token to have other tokens marked `x`
- `/fprobe snippet` — `type(loadstring_untainted)`, then `Execute` a one-line snippet on a
  `SecureHandlerBaseTemplate` and a `SecureHandlerAttributeTemplate` frame and read the
  attribute back. Run it out of combat first in the same session, then again mid-fight,
  where it reuses those frames and also creates fresh ones. W.12, W.33
- `/fprobe copy` — everything the probe printed since load in a selectable box, for pasting
  back; `/fprobe copy clear` empties it. The same text is saved as `transcript`

The external-channel check needs a write from outside the game first:
`scripts/write-external-data.ps1`, then `/reload`, then `/fprobe external`. That script
writes into the *installed* addon folder, and `install-addon.ps1` preserves the
installed `ExternalData.lua` unless you pass `-ResetExternalData`.

Both runs are required before the delta means anything. `/reload` or log out to flush.

**On build 70009 the two passes may span a `/reload` or a full relaunch.** Measured
2026-09-25: the probe's account-wide DB came back across both, and session 1's surface dump
was still in it in session 2 (§P.30). That depends on the probe's rebind guard, because the
client replaces `ForeverProbeDB` at `ADDON_LOADED`, after the probe's file scope (§P.31).
The per-character move that was once planned to lift this is therefore not needed.

On 69913 and earlier, **both passes had to happen in one session**. That build wrote
SavedVariables and never read them back, so a `/reload` discarded whichever pass came first,
and a `/reload` before running anything wrote an empty table over the previous session
(§P.21). If the client is ever back on such a build, check `/fprobe cold` before relying on
a reload.

`/fprobe sv`'s one-line load-order verdict is wrong on 70009. `SavedVars.lua` snapshots file
scope before `ForeverProbe.lua` creates its table, so it never sees the swap. Use
`/fprobe cold` and the `rebind` record instead, until the probe is fixed (§P.30).

## Cautions

- The `.toc` declares `16001`, first measured on beta build 1.60.1.69893. It was confirmed
  by `/fprobe port` on 69913 (§P.24) and again on 70009 (§P.34). `/fprobe` prints the
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
