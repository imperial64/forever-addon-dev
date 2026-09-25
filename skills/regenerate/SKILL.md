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

`/reload` is required: the client flushes SavedVariables then, and nothing reaches disk
until it happens. The dump is around 4 MB and writes in one
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
"not on this client". It must come from the **same build** as the documentation: a stub
says "present on this client", and a surface from another build cannot say that. The
generator checks the two build numbers, and on a mismatch it prints a warning, writes it
into `BUILD.md` and words every stub as unverified. Do not land a reference that carries
that warning.

## The other route: from Blizzard's source, no dump

The same documentation ships as Lua source, and the Gethe/wow-ui-source mirror carries it
on its `forever` branch, one commit per build (the message names it, e.g. "1.60.1 (70009)").
`tools/docs_from_source.py` turns that folder into a capture of the shape `/fprobe docs
dump` writes, so step 2 needs no client. This is how the 70009 reference was produced.

1. Fetch `Interface/AddOns/Blizzard_APIDocumentationGenerated/` at that commit with
   `gh api`: `repos/Gethe/wow-ui-source/git/trees/<sha>?recursive=1` lists the files, and
   `repos/Gethe/wow-ui-source/git/blobs/<blob sha>` returns each one base64-encoded.
2. Export it, passing what a source export cannot know. `--date` is the client's
   `GetBuildInfo()` date, read from the surface capture's `build.buildDate`; the commit
   time as `--captured-at` keeps a rerun byte-identical:

   ```bash
   python tools/docs_from_source.py <dir>/Blizzard_APIDocumentationGenerated \
     research/captures/SourceDocs_<build>_<short sha>.lua \
     --version 1.60.1 --build <build> --interface 16001 --date "<buildDate>" \
     --commit <sha> --captured-at "<commit time>"
   ```

3. The surface still has to come from a client: one full `/fprobe` run on that build,
   collected as in step 3. Then build exactly as in step 4, with the `SourceDocs_` capture
   in place of the dump.

The adapter warns about a handful of constants whose value is a FrameXML global it cannot
resolve (`MAX_RAID_MARKERS` and a few more). They are emitted as nil, which is what the
client itself held for `MAX_RAID_MARKERS` on 69913. That is expected output, not a failure.

## What to check afterwards

- `reference/api/BUILD.md` names the new build and says `client build <n>` rather than
  `unknown`. Unknown means the capture predates the dumper recording it — re-dump.
- `addons/ForeverProbe/DocsVersion.lua` is rewritten from the same capture, so the probe's
  in-game "reference is behind this client" check moves with it. Reinstall the addon.
- The generator prints any restriction or cost that no longer resolves. **Read those.** A
  symbol named in `research/restrictions.yaml` or `research/costs.yaml` that has vanished
  from the client is the failure that actually matters: guidance that keeps recommending a
  function Blizzard removed.
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

On build 70009 the two action passes may span a `/reload` or a relaunch, because
SavedVariables are read back (`research/findings.md` P.30). On 69913 and earlier they had
to happen in **one session**, because a `/reload` between them discarded the first.

New findings go into `research/restrictions.yaml`, which regenerates the banners, the
JSON, `reference/api/RESTRICTIONS.md` and the table inside the restrictions skill. Never
edit those by hand — they are generated, and the generated tree carries a header saying so.

## Cost data does not regenerate either, and is the staler half

`research/costs.yaml` holds what a *permitted* call costs — per-call time and allocation —
and feeds the `COST` banners, `data/costs.json` and `reference/api/COSTS.md` by the same
contract. Regenerating against a new build **carries those numbers forward untouched**,
because they came from a microbenchmark rather than from the client's documentation.

That is the one place this reference can go quietly wrong: a restriction that stops being
true usually shows up as a symbol that no longer resolves, and the generator says so. A cost
that stops being true looks exactly like a cost that is still true. So when you regenerate
against a build that moved, treat everything in `COSTS.md` as unverified until it is
re-measured, and say so rather than quoting it as current. No probe subcommand measures
these today; `research/findings.md` §Q records how they were taken.
