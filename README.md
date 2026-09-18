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

Nothing tested on our own client yet. But a third-party capture of the live beta has been
fetched and queried — see `docs/findings.md` §0. Two things follow from it:

- **The economy plan is unblocked.** Forever ships the full modern `C_AuctionHouse` (85
  functions, commodities included) and none of the Classic-era auction API. It is a Retail
  port. What is left to measure is the throttle and result caps, which is what
  `/fprobe ah scan` is for.
- **The bridge works, with a human in the loop.** The sandbox is intact (`io`/`os` absent)
  and the inbound channel is still a generated `.lua` file, but `C_EncodingUtil` gives it
  JSON/CBOR and compression, and `ReloadUI()` is protected — so every refresh costs a
  manual `/reload`.
