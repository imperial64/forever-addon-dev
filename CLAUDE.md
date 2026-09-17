# WoW Forever addon experimentation

Empirical investigation of what addons can actually do in World of Warcraft: Forever
(Blizzard's Classic+ title, launches 2026-11-04; beta from 2026-09-17). The goal is to
decide which of four planned addons are buildable, using evidence from the live client
rather than press reporting.

## Read this first

- `docs/findings.md` — everything established so far, with sources and confidence levels.
  Read it before answering any question about what Forever permits.
- News monitoring does **not** happen in this repo. A scheduled task owns it:
  `C:\Users\efeay\.claude\scheduled-tasks\wow-forever-addon-watch\seen.md`. Read that file
  for the latest external information; do not duplicate its searching here.

## The four addon plans

| Plan | Status | Blocker |
|---|---|---|
| Rotation helper | **At risk** | Blizzard's combat "black box" may remove the reads it needs |
| Economy / TradeSkillMaster-style | Unknown | No Forever-specific Auction House API information exists |
| Guild management | Likely viable | Nothing confirmed restricts out-of-combat guild data |
| Claude Code notification bridge | Unknown | No known IPC or data-export channel |

## The central question

Blizzard's disarmament doctrine (Ion Hazzikostas, for Midnight) treats combat state as a
black box: addons may restyle the box but not look inside. Addons reportedly cannot know
target buffs/debuffs, cannot determine cooldown states, and cannot parse combat events in
real time. Press reports say Forever inherits this.

Three things are unresolved, and the whole project hinges on them:

1. Does Forever actually inherit the Midnight doctrine, or a weaker version of it?
2. Is the box closed **only in combat**, or at all times? Efe's other three addons are
   entirely out-of-combat, so a combat-only restriction is a non-issue for them.
3. Does the restriction remove data, or only automation? Losing reads kills a rotation
   helper outright; losing only the ability to press a button does not, since a
   display-only helper is still useful.

`ForeverProbe` exists to answer all three from the client.

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
  source or probe result explicitly extends it to a non-combat state.
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
- `/fprobe combat` — re-run the tests while actually in combat (pull a mob first)
- `/fprobe report` — print the out-of-combat vs in-combat delta

Both runs are required before the delta means anything. `/reload` or log out to flush
SavedVariables.

## Cautions

- The `.toc` `## Interface:` number is a guess. `/fprobe` prints the real one; correct it.
  Until then, enable "Load out of date AddOns" at the character screen.
- The action tests deliberately attempt things that may be blocked. That is the point.
  They are harmless, but `SendChatMessage` tests were removed precisely because they would
  speak in the world; do not reintroduce them without thinking about that.
- Run tests somewhere quiet, on a character nobody cares about.
