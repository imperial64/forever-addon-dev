<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# Restrictions

Measured on client 1.60.1 build 69913 (interface 16001) with ForeverProbe.

Everything here was measured against a running client. Blizzard's own documentation says what a function takes; this says whether the client will let an addon call it and whether the value can be read.

| Applies to | Verdict | Scope | Summary |
|---|---|---|---|
| `C_ChatInfo.SendAddonMessage`, `C_ChatInfo.SendAddonMessageLogged` | **CAUTION** | always | AreOutgoingAddonChatMessagesRestricted() returns true, in and out of combat. |
| `C_AssistedCombat.IsAvailable`, `C_AssistedCombat.GetRotationSpells` | **PERMITTED** | always | C_AssistedCombat exists but reports itself unavailable. |
| `COMBAT_LOG_EVENT`, `COMBAT_LOG_EVENT_UNFILTERED` | **FORBIDDEN** | always | Addons may not register for the combat log, in either form. |
| `ReloadUI` | **FORBIDDEN** | always | An addon cannot reload the UI. A human must type /reload. |
| `C_AuctionHouse.ReplicateItems` | **FAILS SILENTLY** | always | A throttled full scan returns an EMPTY MARKET, not an error. |
| `savedvariables-not-read-back` | **BROKEN ON THIS BUILD** | always | The client writes SavedVariables and never reads them back. |
| `secret-value-contagion` | **CAUTION** | always | tostring() on a secret value returns a SECRET STRING. The taint survives conversion. |
| `UnitPower`, `UnitPowerMax` | **SECRET** | always | Unit power is secret at ALL times, including out of combat. |
| `unknown-event-registration-throws` | **CAUTION** | always | RegisterEvent on an event this client does not have RAISES, aborting the rest of the file. |
| `UseAction` | **FORBIDDEN** | always | UseAction fires ADDON_ACTION_FORBIDDEN in and out of combat. |
| `C_UnitAuras` | **SECRET** | in-combat | Aura reads RAISE in combat. They do not return nil. |
| `EditMacro`, `SetOverrideBindingClick`, `SetOverrideBinding` +1 | **BLOCKED IN COMBAT** | in-combat | Macro editing and binding overrides are permitted out of combat and blocked in it. |
| `C_Spell.GetSpellCooldown`, `C_Spell.GetSpellCharges`, `GetActionCooldown` | **SECRET** | in-combat | Spell and action cooldowns become secret in combat. |
| `readable-in-combat` | **PERMITTED** | in-combat | Unit identity, max health, spell casts and threat state stay readable in combat. |
| `SecureActionButtonTemplate:SetAttribute` | **CAUTION** | in-combat | SetAttribute on a secure action button SUCCEEDED in combat. Re-test before relying on it. |
| `C_Secrets.ShouldUnitThreatValuesBeSecret` | **SECRET** | in-combat | Threat VALUES are secret in combat, but threat STATE is not. |
| `C_Secrets.ShouldUnitStatsBeSecret` | **SECRET** | in-combat | Unit stats become secret in combat. |

## addon-messages-restricted

AreOutgoingAddonChatMessagesRestricted() returns true, in and out of combat.

The restriction probe reports outgoing addon messages as restricted in both states. What that restricts in practice was not measured - no message was sent - so this is a flag to check before designing a sideband on it, not a confirmed refusal.

_Evidence: §P.10, §P.18 in `research/findings.md`._

## assisted-combat-inert

C_AssistedCombat exists but reports itself unavailable.

IsAvailable() returns false and GetRotationSpells() returns zero entries on this build. Recorded for accuracy; nothing in this project builds on it.

_Evidence: §0.4, §P.6 in `research/findings.md`._

## aura-secrecy

Aura reads RAISE in combat. They do not return nil.

While ShouldAurasBeSecret() is true, C_UnitAuras reads throw with "Auras cannot be accessed when secret while tainted by '<addon>'". Note "while tainted by": the restriction is scoped to the call stack, not the data - Blizzard's own UI reads the same auras in the same combat. Out of combat the gate is false and auras read normally, by name.

**Workaround.** Read before the pull and hold the value, or hand a duration object to a Cooldown widget before combat starts and let it keep ticking.

_Evidence: §P.18, §P.19 in `research/findings.md`._

## combat-blocked-actions

Macro editing and binding overrides are permitted out of combat and blocked in it.

ADDON_ACTION_BLOCKED, which is retail's long-standing behaviour and is unremarkable. Measured for EditMacro and SetOverrideBindingClick; the other binding setters are listed by association and have not been measured individually.

_Evidence: §P.20 in `research/findings.md`._

## combat-log-subscription

Addons may not register for the combat log, in either form.

RegisterEvent fires ADDON_ACTION_FORBIDDEN and the frame never receives the event. Nothing is raised, so a pcall around the registration reports success. Measured at load, out of combat, standing in a field - this is not a combat-scoped rule. CombatLogGetCurrentEventInfo is absent from the client as well, so the restriction holds at two independent levels.

**Workaround.** None for parsing. Blizzard ships C_DamageMeter for damage numbers. Every other event tried is permitted, including UNIT_AURA, UNIT_COMBAT and both PLAYER_REGEN events - the rule is "no combat log", not "no combat information".

_Evidence: §P.1, §P.12 in `research/findings.md`._

## cooldown-secrecy

Spell and action cooldowns become secret in combat.

ShouldCooldownsBeSecret() and ShouldActionCooldownBeSecret() are both false out of combat and true in it. Blizzard ships its own cooldown manager.

**Workaround.** The sanctioned path is C_Spell.GetSpellCooldownDuration -> LuaDurationObject -> Cooldown:SetCooldownFromDurationObject, which does not require addon code to read the number.

_Evidence: §P.18 in `research/findings.md`._

## readable-in-combat

Unit identity, max health, spell casts and threat state stay readable in combat.

Measured false on their gates while in combat: ShouldUnitIdentityBeSecret, ShouldUnitHealthMaxBeSecret, ShouldUnitSpellCastBeSecret, ShouldUnitThreatStateBeSecret. Cast bars work. Recorded because "addons cannot see combat" is the common summary and it is wrong.

_Evidence: §P.18 in `research/findings.md`._

## reloadui-protected

An addon cannot reload the UI. A human must type /reload.

This is the binding constraint on any out-of-game bridge: the inbound channel works, but refreshing it costs a manual /reload.

_Evidence: §0.2, §P.9 in `research/findings.md`._

## replicate-throttle

A throttled full scan returns an EMPTY MARKET, not an error.

The throttle is real, measured at more than 162 seconds and at most 1047. When it bites, the call returns true, no REPLICATE_ITEM_LIST_UPDATE fires, and GetNumReplicateItems stays at 0 - indistinguishable from an auction house with nothing on it. IsThrottledMessageSystemReady describes the message system, not this throttle, and read true throughout.

**Workaround.** Track your own last-scan time and refuse to call inside your own window. The client will not tell you. A naive addon writes "the market is empty" over its price history. Browse is unthrottled and returns the complete item-key market in about three seconds, so prefer it as the data source.

_Evidence: §P.15, §P.17 in `research/findings.md`._

## savedvariables-not-read-back

The client writes SavedVariables and never reads them back.

Every addon starts from defaults on every launch. Measured: the load counter stays at 1 across sessions and no token survives a /reload, while the file itself lands on disk correctly. Outbound works; the in-client round trip does not. Reported as a beta bug rather than a policy decision.

**Workaround.** An external process writes Lua into the AddOns folder and the client executes it as addon code at load. That is the inbound bridge, and it works.

_Evidence: §P.9, §0.2 in `research/findings.md`._

## secret-value-contagion

tostring() on a secret value returns a SECRET STRING. The taint survives conversion.

A pcall around the read reports success and hands back a value that throws later, wherever it is next indexed - usually a print or a format, far from the read. This took the probe down mid-run. Worse, a secret string stored in SavedVariables would take the whole flush with it.

**Workaround.** Use issecretvalue before AND after conversion. The client also provides issecrettable, hasanysecretvalues, scrub, scrubsecretvalues, canaccesssecrets, secretwrap and dropsecretaccess.

_Evidence: §P.2 in `research/findings.md`._

## secure-setattribute-in-combat

SetAttribute on a secure action button SUCCEEDED in combat. Re-test before relying on it.

Retail protects exactly this, and it is the mechanism every action-bar addon depends on. Our measurement is that the call raised no error and fired no block event - which is weaker evidence than the attribute actually taking effect, and this client has already shown that a refusal can be silent.

_Evidence: §P.20 in `research/findings.md`._

## threat-values-secrecy

Threat VALUES are secret in combat, but threat STATE is not.

ShouldUnitThreatValuesBeSecret() is true in combat while ShouldUnitThreatStateBeSecret() is false. An addon may know whether it has aggro and not by how much. That kills the numeric threat meter and leaves the "you are about to pull" warning working, which does not look accidental.

_Evidence: §P.18 in `research/findings.md`._

## unit-power-secrecy

Unit power is secret at ALL times, including out of combat.

ShouldUnitPowerBeSecret("player") is true standing still with no target, and UnitPower("player") returns a secret value in both combat states. This directly contradicts Blizzard's published doctrine, which promises that "all class secondary resources remain fully non-secret". Measured twice, in both states, by gate and by value. Either the doctrine does not describe this client or this is a beta bug.

_Evidence: §P.3, §P.10, §P.18 in `research/findings.md`._

## unit-stats-secrecy

Unit stats become secret in combat.

_Evidence: §P.18 in `research/findings.md`._

## unknown-event-registration-throws

RegisterEvent on an event this client does not have RAISES, aborting the rest of the file.

An error in an addon's main chunk stops the remainder of that file loading, so a single stale event name can silently remove every command the addon defines. Distinct from a forbidden registration, which does not raise at all.

**Workaround.** Wrap every RegisterEvent in pcall.

_Evidence: §P.1, §0.5 in `research/findings.md`._

## useaction-forbidden

UseAction fires ADDON_ACTION_FORBIDDEN in and out of combat.

_Evidence: §P.4, §P.20 in `research/findings.md`._
