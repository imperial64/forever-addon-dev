# forever-addon-dev

A Claude Code plugin for **AI-assisted development of World of Warcraft: Forever addons**.

Install it, and Claude answers Forever addon questions from measured ground truth instead
of from memory of Retail: the client's own API documentation, plus a restriction list
established by probing a live client. It scaffolds addons, looks up signatures, explains
why a call came back `nil`, and lints source against what the client will actually allow.

Forever launches 2026-11-04. Its addon API is Retail's, on interface `16001`, and it
carries Midnight's restrictions — but no restriction list has been published, and the
press summaries of what addons can and cannot do turn out to be wrong in both directions.
So this was measured instead, against a live client.

The plugin answers three questions:

| Question | Where the answer comes from |
|---|---|
| How do I build a Forever addon? | The gotchas that cost real debugging time, written as instruction |
| What is the full API? | 6,596 functions with signatures, generated from the client's own documentation |
| What am I not allowed to do? | 24 restrictions and measured behaviours, each established on a running client, with the evidence attached |
| What does a call cost? | Per-call time and allocation for the calls where it changes a design, measured on a live client |

It is addon-agnostic. There is no opinion here about what you should build — the reference
covers the whole API surface, and the restriction list is whatever the client enforces.

## Install

```
/plugin marketplace add imperial64/forever-addon-dev
/plugin install forever-addon-dev@forever-addon-dev
```

## Skills

| Skill | Use it for |
|---|---|
| `build` | Writing, structuring, scaffolding and debugging an addon |
| `api` | One symbol's exact signature, or whether it exists on this build |
| `restrictions` | Whether a call is forbidden, secret, throttled or protected, and why |
| `regenerate` | Rebuilding the reference from your own client after a patch |

## What makes the restriction list worth having

Blizzard's documentation tells you a function exists and what it takes. It does not tell
you whether the client will let an addon call it, or whether the value it returns can be
read. Both were measured here, and the answers are not what the published doctrine says.

- **`UseAction`, `ReloadUI`, `SetBinding` and `SetOverrideBindingClick` are not documented
  by Blizzard at all** — four of the most restricted functions on the client. Their pages
  here exist because they were measured.
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
data/              machine-readable: api.json, restrictions.json, costs.json
tools/             the generator, the linter, the SavedVariables parser
addons/ForeverProbe/  the probe addon - also the doc generator
scripts/           install to the client, collect results back
research/          the measurement record; restrictions.yaml and costs.yaml are
                   the two hand-maintained sources everything else generates from
```

## Checking an addon

```bash
python tools/lint_addon.py path/to/YourAddon/
```

Flags calls this client does not have, subscriptions it will refuse, reads that come back
secret, protected actions, and the version-check trap that makes Retail addons take their
Classic code path on interface `16001`. It is a regex linter, not a Lua parser, so a clean
run is not a proof of correctness — it says so on every run.

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

Generation is deterministic and no per-symbol page carries a timestamp, so regenerating
against a newer client produces a diff that *is* the patch delta.

## Provenance

Nothing here is inferred from a patch note. The rule this grew up under: probe output
supersedes reporting, and a source is not cited unless it was fetched. Where something is
uncertain it says so — `research/findings.md` marks several gates as *not measured* rather
than guessing them from their neighbours.

This repository was itself built with AI assistance. The probe, the generator, the linter
and the prose were written with Claude Code; what keeps that honest is that the claims are
measured rather than recalled, and the measurements are in the repository next to the
guidance they support.

Not affiliated with Blizzard Entertainment. See [LICENSE](LICENSE).
