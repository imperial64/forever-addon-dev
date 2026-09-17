# wow-addon-experimentation

Working out what addons can actually do in **World of Warcraft: Forever** (launches
2026-11-04, beta from 2026-09-17), by testing the live client instead of reading press
coverage.

Four addons are planned: a rotation helper, a TradeSkillMaster-style economy addon, a guild
management addon, and a bridge that surfaces Claude Code notifications in game. Blizzard's
addon "disarmament" doctrine puts the first one at risk and says nothing about the other
three.

## Layout

```
addons/ForeverProbe/   the probe addon
scripts/               install to WoW, collect results back
data/                  captured SavedVariables output, timestamped
docs/findings.md       what is known so far, with sources and confidence levels
CLAUDE.md              project context and working rules
```

## Use

```powershell
.\scripts\install-addon.ps1          # copy the probe into the beta client
# in game: /fprobe  (out of combat), then pull a mob and /fprobe combat, then /reload
.\scripts\collect-savedvars.ps1      # pull the results into data/
```

`/fprobe report` prints the out-of-combat vs in-combat delta, which is the whole point:
anything blocked only in combat matches retail and is fine, anything blocked in both states
is new, and any combat *read* that returns data out of combat but `nil` in combat is
Blizzard's black box closing.

## Status

Nothing tested yet. See `docs/findings.md`.
