# wow-addon-experimentation

Working out what addons can actually do in **World of Warcraft: Forever** (launches
2026-11-04, beta from 2026-09-17), by testing the live client instead of reading press
coverage.

Two addons are planned. A TradeSkillMaster-style **economy addon** is the goal. Alongside
it, a **Claude Code bridge** — general-purpose tooling for talking to Claude Code from
inside a running client, meant to be reused across projects rather than a WoW feature.
Blizzard's addon "disarmament" doctrine says nothing about either.

Two other plans were cut on 2026-09-17. **Guild management** is scrapped: nothing blocks
it, which is why it was not worth the divided attention. A **rotation helper** is
**shelved** on evidence — Tim Jones said on camera that Forever will have parity with retail on "the information that add-ons have access to", and
Blizzard is shipping its own damage meter and cooldown manager. That is a read-side
restriction, which is what a rotation helper actually needs. It keeps one probe kill-check
and nothing else — see `docs/findings.md` §7.

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

The out-of-combat run is the one that matters now: it prints an `AH` verdict (which Auction
House API, if any) and a `BRIDGE` verdict (which channels exist across the client
boundary), which between them decide both live plans without the combat pass.

`/fprobe report` prints the out-of-combat vs in-combat delta. Anything blocked only in
combat matches retail and is fine; anything blocked in both states is new and worth
checking for collateral damage to the two live plans; any combat *read* that returns data
out of combat but `nil` in combat is Blizzard's black box closing, which confirms the
rotation helper stays shelved.

## Status

Nothing tested yet. See `docs/findings.md`.
