# forever-addon-dev

A Claude Code plugin for building **World of Warcraft: Forever** addons.

Forever launches 2026-11-04. Its addon API is Retail's, on interface `16001`, and it
carries Midnight's restrictions — but no restriction list has been published, and the
press summaries of what addons can and cannot do turn out to be wrong in both directions.
So this was measured instead, against a live client.

The plugin answers three questions:

| Question | Where the answer comes from |
|---|---|
| How do I build a Forever addon? | The gotchas that cost real debugging time, written as instruction |
| What is the full API? | 6,577 functions with signatures, generated from the client's own documentation |
| What am I not allowed to do? | 17 restrictions, each measured on a running client, with the evidence attached |

## Install

```
/plugin marketplace add imperial64/forever-addon-dev
/plugin install forever-addon-dev@forever-addon-dev
```

## What makes the restriction list worth having

Blizzard's documentation tells you a function exists and what it takes. It does not tell
you whether the client will let an addon call it, or whether the value it returns can be
read. Both were measured here, and the answers are not what the published doctrine says.

- **`UseAction`, `ReloadUI`, `SetBinding` and `SetOverrideBindingClick` are not documented
  by Blizzard at all** — four of the most restricted functions on the client. Their pages
  here exist because we measured them.
- **Addons may not subscribe to the combat log.** Not "the payload is stripped" — the
  registration itself is refused, out of combat, with `ADDON_ACTION_FORBIDDEN`. Both
  `COMBAT_LOG_EVENT` and `COMBAT_LOG_EVENT_UNFILTERED`.
- **But cast bars still work in combat**, and so does threat *state*. Threat *values* are
  secret. An addon may know whether it has aggro and not by how much. The line was drawn
  with care, and "addons cannot see combat" is simply wrong.
- **`UnitPower` is secret at all times** — the one thing Blizzard's doctrine explicitly
  promises stays readable.
- **A throttled auction scan returns an empty market, not an error.** An addon that does
  not track its own scan timing will write "the market is empty" over its price history.

Every entry carries the section of [`research/findings.md`](research/findings.md) that
records the measurement.

## Layout

```
skills/            what Claude loads: build, api, restrictions, regenerate
reference/api/     generated: one page per symbol, path derivable from the name
reference/guides/  hand-written authoring guidance
data/              machine-readable: api.json, restrictions.json
tools/             the generator, the linter, the SavedVariables parser
addons/ForeverProbe/  the probe addon - also the doc generator
scripts/           install to the client, collect results back
research/          the lab notebook this grew out of, kept as the evidence base
examples/          worked examples
```

## Regenerating the reference

Forever is in beta and patches often — it moved 69893 → 69913 in a single day. The
reference ships generated from one build and the addon warns in game when your client has
moved past it.

```powershell
.\scripts\install-addon.ps1        # copy ForeverProbe into the client
# in game:  /fprobe docs dump      then  /reload
.\scripts\collect-savedvars.ps1
python tools/build_reference.py research/captures/<newest>.lua --surface <a full run> --clean
```

## Provenance

Nothing here is inferred from a patch note. The rule this grew up under: probe output
supersedes reporting, and a source is not cited unless it was fetched. Where something is
uncertain it says so — `research/findings.md` marks three gates as *not captured* rather
than guessing them from their neighbours.

Not affiliated with Blizzard Entertainment. See [LICENSE](LICENSE).
