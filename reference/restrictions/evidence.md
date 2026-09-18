# How to read this, and how much to trust it

Everything in `reference/restrictions/` was measured against a running client. That is
worth saying plainly because **the published doctrine does not describe this client**, and
the press summaries derived from it are wrong in both directions.

## The three provenance tiers

| Tier | Source | How it appears |
|---|---|---|
| 1 | Blizzard's own `HasRestrictions` flag, from the client's documentation | `RESTRICTED — Blizzard flag` banner. 274 functions |
| 2 | Presence or absence in a capture of the client's global table | `Present on this client` / a missing page |
| 3 | **Our measured runtime behaviour** | `RESTRICTED — measured` banner, with an evidence link |

Tier 3 is the only one nobody else has, and it is the only one that answers "what happens
when I actually call this".

## Where the doctrine and the client disagree

Blizzard's Midnight addon-disarmament post says combat is a black box: addons cannot know
target auras, cannot determine cooldown states, and class secondary resources "remain fully
non-secret".

On this build, measured:

- Auras and cooldowns **are** readable out of combat, by name.
- Class resources (`UnitPower`) are **never** readable, in or out of combat.
- Cast bars and threat *state* keep working in combat.

So the doctrine is a statement of intent, not a specification of this client. Where this
reference and a patch note disagree, the reference was measured and the patch note was not.

## Four systems, not one switch

The most common mistake is treating "addon disarmament" as a single thing. It produces
wrong answers in both directions.

| System | Refuses by | Scope |
|---|---|---|
| Combat log | `ADDON_ACTION_FORBIDDEN` on `RegisterEvent` | always |
| Value secrecy (`C_Secrets`) | returning a secret, or throwing | per category, mostly combat |
| Protected actions | `ADDON_ACTION_FORBIDDEN` / `BLOCKED` on call | mixed |
| Restriction state (`C_RestrictedActions`) | a queryable global flag | combat |

## What is deliberately marked uncertain

This reference says "not measured" rather than filling gaps by inference. Two examples,
both live:

- **`SecureActionButton:SetAttribute` in combat** is marked `caution`, not "permitted". It
  appeared to succeed, but "no error and no block event" is weaker evidence than the
  attribute taking effect.
- **Three `C_Secrets` gates have no out-of-combat measurement** — `UnitSpellCast`,
  `UnitThreatState`, `UnitThreatValues` — because the in-game output truncated. They are
  recorded as *not captured* rather than assumed from the gates beside them.

If something here is stated flatly, it was measured. If it is hedged, the hedge is the
finding.

## Checking a claim yourself

Every entry links to a section of `research/findings.md`, which records the client build,
the date, and what was run. The probe that produced it is in `addons/ForeverProbe/` and the
raw captures are in `research/captures/`, so any claim can be re-derived rather than taken
on trust.

The machine-readable copy is `data/restrictions.json`, generated from
`research/restrictions.yaml` — which is the single hand-maintained source for all of this.

## Staleness

Measured on client **1.60.1 build 69913**, 2026-09-18. Forever is in beta and moved 69893 →
69913 in a single day. The probe addon warns in game when your client has moved past the
shipped reference, and `regenerate` rebuilds the API half from your own client.

The restriction half does **not** regenerate — it is measured by hand, and a new build may
invalidate it.
