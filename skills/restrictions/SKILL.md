---
name: restrictions
description: >
  What World of Warcraft Forever addons are not allowed to do - combat-log subscription
  refused outright, C_Secrets value gates that make reads secret or throwing, protected
  and forbidden actions, the silent Auction House scan throttle, and SavedVariables that
  are written but never read back - each with the measurement that established it on a
  live client. Use when asked whether something is blocked, forbidden, secret, throttled,
  protected or permitted; why a call returned nil, an empty result or a secret value; why
  an addon threw "cannot be accessed when secret"; or for the full restriction list. For
  a function's signature use the api skill; for how to structure an addon use the build skill.
---

# What Forever addons may not do

Everything here was measured on a running client, not read in a patch note. That matters
because **the published doctrine is wrong in both directions** on this build: it says
cooldowns and auras are gone (they are readable out of combat) and that class resources
stay readable (`UnitPower` is secret at all times).

Source of truth: `${CLAUDE_PLUGIN_ROOT}/research/restrictions.yaml`. Generated views:
`reference/api/RESTRICTIONS.md`, `data/restrictions.json`, and a banner on each affected
page in `reference/api/`.

Longer form, written for an outside reader:

- `reference/restrictions/combat-log.md` — the one capability with no workaround
- `reference/restrictions/secret-values.md` — the gates, the contagion, the safe conversion
- `reference/restrictions/protected-actions.md` — forbidden versus blocked, and detecting both
- `reference/restrictions/auction-house-throttle.md` — the silent one
- `reference/restrictions/evidence.md` — provenance tiers, and what is deliberately marked
  uncertain

## There are four separate systems, not one switch

Treating "addon disarmament" as a single thing is the most common mistake, and it produces
wrong answers in both directions.

| System | How it refuses | Scope |
|---|---|---|
| **Combat log** | `RegisterEvent` fires `ADDON_ACTION_FORBIDDEN`; the frame never receives the event | Always |
| **Value secrecy** (`C_Secrets`) | The call succeeds and returns a value addon code may not read — or throws | Per category; mostly in-combat |
| **Protected actions** | `ADDON_ACTION_FORBIDDEN` or `ADDON_ACTION_BLOCKED` on call | Mixed |
| **Restriction state** (`C_RestrictedActions`) | A global flag, 0 out of combat and 2 in it — **queryable**, unlike the rest | In-combat |

That last one is useful: an addon can ask `C_RestrictedActions.IsAddOnRestrictionActive()`
whether it is currently restricted, instead of inferring it from a masked value.

<!-- BEGIN GENERATED restrictions-table -->
## Every restriction, measured

| Applies to | Verdict | Scope | What happens |
|---|---|---|---|
| `C_ChatInfo.SendAddonMessage`, `C_ChatInfo.SendAddonMessageLogged` | **CAUTION** | always | AreOutgoingAddonChatMessagesRestricted() returns true, in and out of combat. |
| `C_AssistedCombat.IsAvailable`, `C_AssistedCombat.GetRotationSpells` | **PERMITTED** | always | C_AssistedCombat exists but reports itself unavailable. |
| `COMBAT_LOG_EVENT`, `COMBAT_LOG_EVENT_UNFILTERED` | **FORBIDDEN** | always | Addons may not register for the combat log, in either form. |
| `ReloadUI` | **FORBIDDEN** | always | An addon cannot reload the UI. A human must type /reload. |
| `C_AuctionHouse.ReplicateItems` | **FAILS SILENTLY** | always | A throttled full scan returns an EMPTY MARKET, not an error. |
| SavedVariables | **BROKEN ON THIS BUILD** | always | The client writes SavedVariables and never reads them back. |
| Any secret value | **CAUTION** | always | tostring() on a secret value returns a SECRET STRING. The taint survives conversion. |
| `UnitPower`, `UnitPowerMax` | **SECRET** | always | Unit power is secret at ALL times, including out of combat. |
| RegisterEvent | **CAUTION** | always | RegisterEvent on an event this client does not have RAISES, aborting the rest of the file. |
| `UseAction` | **FORBIDDEN** | always | UseAction fires ADDON_ACTION_FORBIDDEN in and out of combat. |
| C_UnitAuras (all reads) | **SECRET** | in-combat | Aura reads RAISE in combat. They do not return nil. |
| `EditMacro`, `SetOverrideBindingClick` +2 | **BLOCKED IN COMBAT** | in-combat | Macro editing and binding overrides are permitted out of combat and blocked in it. |
| `C_Spell.GetSpellCooldown`, `C_Spell.GetSpellCharges` +1 | **SECRET** | in-combat | Spell and action cooldowns become secret in combat. |
| Identity, max health, casts, threat state | **PERMITTED** | in-combat | Unit identity, max health, spell casts and threat state stay readable in combat. |
| `SecureActionButtonTemplate:SetAttribute` | **CAUTION** | in-combat | SetAttribute on a secure action button SUCCEEDED in combat. Re-test before relying on it. |
| Threat values | **SECRET** | in-combat | Threat VALUES are secret in combat, but threat STATE is not. |
| Unit stats | **SECRET** | in-combat | Unit stats become secret in combat. |

Measured 2026-09-18 on client 1.60.1 build 69913. Detail and evidence for each: `reference/api/RESTRICTIONS.md`.
<!-- END GENERATED restrictions-table -->

## Three refusal shapes, and only one is obvious

An addon has to handle all three. This is the single most useful thing to tell someone
writing code for this client.

**1. It throws.** Aura reads in combat:

```
GetAuraDataByIndex(): Auras cannot be accessed when secret while tainted by 'YourAddon'
```

Note *"while tainted by"* — the restriction is scoped to the **call stack**, not the data.
Blizzard's own UI reads those same auras in that same combat. An addon is refused because
the stack is the addon's.

**2. It returns a secret value, and `tostring()` does not launder it.** The taint survives
conversion, so a `pcall` around the read reports success and the value detonates later,
wherever the resulting string is next indexed — usually in a print or a format, far from
the read. Worse, a secret string written into SavedVariables takes the whole flush with it.

```lua
-- The only safe pattern. Test before AND after conversion.
local function plain(v)
    if issecretvalue and issecretvalue(v) then return "<SECRET>" end
    local ok, str = pcall(tostring, v)
    if not ok then return "<UNPRINTABLE>" end
    if issecretvalue and issecretvalue(str) then return "<SECRET>" end
    local okCut, cut = pcall(string.sub, str, 1, 200)
    return okCut and cut or "<SECRET>"
end
```

The client also provides `issecrettable`, `hasanysecretvalues`, `scrub`,
`scrubsecretvalues`, `canaccesssecrets`, `secretwrap` and `dropsecretaccess`.

**3. It returns plain `nil`, or an empty result.** Cast info and cooldown start return
`nil`. A throttled `ReplicateItems` returns an *empty auction house*: the call returns
true, no event fires, and the count stays at zero. Indistinguishable from a market with
nothing on it, which is how a naive addon overwrites its own price history with nothing.

## What stays readable in combat

Worth saying explicitly, because "addons cannot see combat" is the common summary and it
is wrong:

- **Unit identity** and **max health**
- **Spell casts** — cast bars work
- **Threat state** — whether you have aggro, though not the numeric value

Threat state readable while threat values are secret is a deliberate-looking line: it kills
the numeric threat meter and leaves the "you are about to pull" warning working.

## When someone asks "why did this return nil?"

Work through it in this order:

1. **Is it a secret value rather than nil?** Check with `issecretvalue`. The two look the
   same in a print, and only one of them will take the addon down later.
2. **Are they in combat?** Most gates are combat-scoped. `UnitPower` is not — it is secret
   always.
3. **Is it the auction throttle?** An empty market from `ReplicateItems` inside the window
   is a throttle, not an empty market, and the client will not say so.
4. **Did the event ever register?** A forbidden `RegisterEvent` does not raise. The frame
   simply never receives anything. `/fprobe blocked` in the probe addon names the call.
5. **Does the function exist on this build?** The api skill answers that; a missing
   reference page means it is not on this client.

## Evidence

Every entry links to the section of `research/findings.md` that records the measurement,
including the client build and date. When answering, cite the section — the value of this
data is that it is checkable, and an unsourced restriction claim is worth no more than the
press reporting it replaces.
