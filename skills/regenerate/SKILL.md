---
name: regenerate
description: >
  Rebuild the World of Warcraft Forever API reference from the user's own client, when
  their build is newer than the shipped one or a signature looks wrong. Use when the user
  says the reference is out of date, that the addon warned them their client has moved on,
  that a documented function does not exist or behaves differently, when they are on a new
  patch, or when they ask to regenerate, re-measure or verify the docs against their own
  game. Also use when asked how the reference was produced.
---

# Regenerate the reference against this client

The shipped reference was generated from one specific client build.
`${CLAUDE_PLUGIN_ROOT}/reference/api/BUILD.md` names it. Forever is in beta and patches
often — it moved 69893 → 69913 in a single day — so a reference slightly behind the client
is normal, and the probe addon warns in game when it happens.

Regenerating takes about two minutes and makes the reference exactly match the client the
user is actually running.

## What it needs

- The user's WoW install path and the Forever flavour folder, normally `_classic_beta_`
- Python 3 (no Lua runtime needed; the SavedVariables parser is pure Python)
- The user in game, out of combat, for one command

## The loop

**1. Install the probe addon into the client.**

```powershell
.\scripts\install-addon.ps1 -WowRoot "<path to WoW>" -Flavor "_classic_beta_"
```

It syntax-gates with luajit if present, and preserves any existing `ExternalData.lua`.
Enable ForeverProbe at the character screen — new addons are not enabled by default, which
is the usual reason nothing appears to happen.

**2. Dump the documentation, in game.**

```
/fprobe docs dump
/reload
```

`/reload` is required: the client flushes SavedVariables then, and this build never reads
them back, so nothing is saved until it happens. The dump is around 4 MB and writes in one
pass. If it truncates, take it in passes — `/fprobe docs dump 1 100`, `/reload`, collect,
then `101 100` — which merge rather than replace.

**3. Collect it.**

```powershell
.\scripts\collect-savedvars.ps1 -WowRoot "<path to WoW>" -Flavor "_classic_beta_" -Label "apidocs"
```

Captures land in `research/captures/`, timestamped. The script warns if a large capture
does not close cleanly, which is what a truncated flush looks like.

**4. Build the reference.**

```bash
python tools/build_reference.py research/captures/<newest>.lua \
  --surface research/captures/<a full /fprobe run>.lua --clean
```

`--surface` is optional but wanted: it points at a capture from a full `/fprobe` run, whose
global dump is what lets the generator stub the ~5,900 symbols the client has and Blizzard
does not document. Without it those pages are missing, and a missing page stops meaning
"not on this client".

## What to check afterwards

- `reference/api/BUILD.md` names the new build and says `client build <n>` rather than
  `unknown`. Unknown means the capture predates the dumper recording it — re-dump.
- The generator prints any restriction that no longer resolves. **Read those.** A symbol
  named in `research/restrictions.yaml` that has vanished from the client is the failure
  that actually matters: guidance that keeps recommending a function Blizzard removed.
- `git diff --stat reference/api` **is the patch delta.** Generation is deterministic and
  no per-symbol page carries a timestamp, so every changed file is a real API change
  between the two builds. That diff is worth reading.

## If the measurements themselves need redoing

The API reference is Blizzard's data. The restriction list is measured, and it does not
regenerate — it is established by hand with the probe:

```
/fprobe            surface, actions, reads, secrecy gates, out of combat
/fprobe events     which events may be subscribed to at all
/fprobe ah         at an auction house
/fprobe combat     in combat, for the delta
/fprobe report     the out-of-combat vs in-combat diff
```

Both action passes must happen in **one session**: a `/reload` between them discards the
first, because this build does not read SavedVariables back.

New findings go into `research/restrictions.yaml`, which regenerates the banners, the
JSON, `reference/api/RESTRICTIONS.md` and the table inside the restrictions skill. Never
edit those by hand — they are generated, and the generated tree carries a header saying so.
