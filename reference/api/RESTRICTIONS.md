<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# Restrictions

Measured on client 1.60.1 build 69913 (interface 16001) with ForeverProbe (P); AmbianceCost (Q).

Everything here was measured against a running client. Blizzard's own documentation says what a function takes; this says whether the client will let an addon call it and whether the value can be read.

| Applies to | Verdict | Scope | Summary |
|---|---|---|---|
| `C_ChatInfo.SendAddonMessage`, `C_ChatInfo.SendAddonMessageLogged` | **CAUTION** | always | AreOutgoingAddonChatMessagesRestricted() returns true, in and out of combat. |
| `C_AssistedCombat.IsAvailable`, `C_AssistedCombat.GetRotationSpells` | **PERMITTED** | always | C_AssistedCombat exists but reports itself unavailable. |
| `COMBAT_LOG_EVENT`, `COMBAT_LOG_EVENT_UNFILTERED` | **FORBIDDEN** | always | Addons may not register for the combat log, in either form. |
| `C_CVar.GetCVar`, `GetCVar` | **CAUTION** | always | A CVar's VALUE does not tell you whether it is in effect. The enable flag is a separate CVar. |
| `C_CVar.SetCVar`, `SetCVar` | **PERMITTED** | always | Display brightness and contrast ARE addon-writable, live, at frame rate. |
| `onupdate-elapsed-quantised` | **CAUTION** | always | The elapsed argument to an OnUpdate script is quantised to 1 ms. |
| `UnitHealthMax`, `UnitPowerMax` | **SECRET** | always | Another unit's max health and max power are secret at ALL times; the player's own are never secret. |
| `ReloadUI` | **FORBIDDEN** | always | An addon cannot reload the UI. A human must type /reload. |
| `C_AuctionHouse.ReplicateItems` | **FAILS SILENTLY** | always | A throttled full scan returns an EMPTY MARKET, not an error. |
| `retail-graphics-cvar-names-absent` | **CAUTION** | always | gxBrightness, gxContrast and gxGamma do NOT exist on this client. |
| `savedvariables-not-read-back` | **BROKEN ON THIS BUILD** | always | The client writes ACCOUNT-WIDE SavedVariables and never reads them back. Per-character saved variables are read back normally. |
| `secret-value-contagion` | **CAUTION** | always | tostring() on a secret value returns a SECRET STRING. The taint survives conversion. |
| `UnitHealth` | **SECRET** | always | Unit health is secret at ALL times, including out of combat. |
| `UnitPower` | **SECRET** | always | Unit power is secret at ALL times, including out of combat. |
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

## cvar-enable-flag-pairing

A CVar's VALUE does not tell you whether it is in effect. The enable flag is a separate CVar.

Measured with the client running uncapped at 273.7 fps: maxFPS read 120 and targetFPS read 60, while useMaxFPS and useTargetFPS both read 0. A slider CVar retains its last position whether or not the limit is applied, so an addon reading maxFPS alone concludes the client is capped at 120 when it is running at more than twice that - with no error, because nothing failed. The same shape is recorded for HDRBrightness/useHDRBrightness and HDRPeakBrightness/useHDRPeakBrightness in P.22. Two instances is a pattern to check for, NOT a proven convention: no enumeration was done to establish that every <Name> carries a use<Name>. Reads only - whether an addon can WRITE useMaxFPS was not measured.

**Workaround.** Before trusting a CVar's value, look for a paired use<Name> and read it with GetCVarBool. ConsoleGetAllCommands() enumerates the real names, which is how the graphics CVars in P.22 were found; do not assume a flag exists because a neighbouring CVar has one.

_Evidence: §Q.1, §P.22 in `research/findings.md`._

## graphics-cvars-writable

Display brightness and contrast ARE addon-writable, live, at frame rate.

Brightness, Contrast and Gamma carry no lock flags - GetCVarInfo reports isLockedFromUser, isSecure and isReadOnly all false. Writes land through both C_CVar.SetCVar and the undocumented global SetCVar, identically, and read back exactly. A write is a cheap live post-process, not a device restart: a four-second sweep writing every frame from OnUpdate managed 442 writes over 443 frames at 111 fps, worst frame gap 31 ms. That is a ceiling rather than a cost; the per-call figures are in research/costs.yaml under cvar-write. Brightness and Contrast are on a 0-100 scale (default 50), Gamma centres on 1.0. Measured in maximized windowed mode at 1920x1080, so this is not fullscreen-only. NOT measured in combat: SetCVar is not a protected function and none of these carry lock flags, so a block is unlikely, but P.20 has already shown this client's action gating does not always match retail.

**Workaround.** Until /fprobe video has been run mid-fight, freeze on PLAYER_REGEN_DISABLED and resume on PLAYER_REGEN_ENABLED rather than assuming the write lands in combat.

_Evidence: §P.22 in `research/findings.md`._

## onupdate-elapsed-quantised

The elapsed argument to an OnUpdate script is quantised to 1 ms.

Across 15 phases covering 19,692 frames, every retained frame-gap statistic is a whole number of milliseconds and every accumulated phase duration lands on an exact multiple of 1 ms. Frame-rate-independent easing on elapsed is unaffected - the quantisation is far below the time constants involved - but an addon that profiles itself by accumulating elapsed produces noise for anything costing under about a millisecond, and the noise looks like data.

**Workaround.** Use debugprofilestart/debugprofilestop, which are present and working on this client and have microsecond resolution.

_Evidence: §Q.5 in `research/findings.md`._

## other-unit-max-values

Another unit's max health and max power are secret at ALL times; the player's own are never secret.

Measured 2026-09-20. On the player, UnitHealthMax and UnitPowerMax are plain numbers in every state measured. On a target, both are secret in every state measured - including standing out of combat, on a friendly quest NPC and on a hostile mob alike. Hostility makes no difference. So the axis is the UNIT, not combat. This was first recorded as in-combat because the out-of-combat pass had no target selected; re-running it with one moved the scope to always. What stays readable about another unit: level, name, GUID and class.

_Evidence: §P.25, §P.28 in `research/findings.md`._

## readable-in-combat

Unit identity, max health, spell casts and threat state stay readable in combat.

Measured false on their gates while in combat: ShouldUnitIdentityBeSecret, ShouldUnitHealthMaxBeSecret, ShouldUnitSpellCastBeSecret, ShouldUnitThreatStateBeSecret. Cast bars work. Recorded because "addons cannot see combat" is the common summary and it is wrong. Max health is readable ON THE PLAYER. Measured 2026-09-20 by value, a TARGET's UnitHealthMax is secret in combat while the player's is not, so ShouldUnitHealthMaxBeSecret answers per unit and the gate above was read for the player. See other-unit-max-values. Unit identity holds up by value too: UnitName, UnitGUID, UnitClass and UnitLevel are all plain on both the player and the target, in and out of combat.

_Evidence: §P.18, §P.25 in `research/findings.md`._

## reloadui-protected

An addon cannot reload the UI. A human must type /reload.

This is the binding constraint on any out-of-game data channel: the inbound channel works, but refreshing it costs a manual /reload.

_Evidence: §0.2, §P.9 in `research/findings.md`._

## replicate-throttle

A throttled full scan returns an EMPTY MARKET, not an error.

The throttle is real, measured at more than 162 seconds and at most 1047. When it bites, the call returns true, no REPLICATE_ITEM_LIST_UPDATE fires, and GetNumReplicateItems stays at 0 - indistinguishable from an auction house with nothing on it. IsThrottledMessageSystemReady describes the message system, not this throttle, and read true throughout.

**Workaround.** Track your own last-scan time and refuse to call inside your own window. The client will not tell you. A naive addon writes "the market is empty" over its price history. Browse is unthrottled and returns the complete item-key market in about three seconds, so prefer it as the data source.

_Evidence: §P.15, §P.17 in `research/findings.md`._

## retail-graphics-cvar-names-absent

gxBrightness, gxContrast and gxGamma do NOT exist on this client.

All three retail names report present=false. The client's own names are Brightness, Contrast and Gamma, with HDRBrightness, HDRPeakBrightness, useHDRBrightness and useHDRPeakBrightness alongside them. Anything ported from a retail addon on the assumption that the gx-prefixed names still apply will not work. What a write to a name the client does not have actually does was NOT measured - the write tests only ran against names confirmed present - so do not assume it errors.

**Workaround.** Enumerate rather than assume. ConsoleGetAllCommands() is present and returned 1902 commands; filtering it is how these names were found in the first place.

_Evidence: §P.22 in `research/findings.md`._

## savedvariables-not-read-back

The client writes ACCOUNT-WIDE SavedVariables and never reads them back. Per-character saved variables are read back normally.

An addon declaring ## SavedVariables starts from defaults on every launch. Measured: the load counter stays at 1 across sessions and no token survives a /reload, while the file itself lands on disk correctly. Outbound works; the in-client round trip does not. Reported as a beta bug rather than a policy decision. Partly scoped on 2026-09-20, and the scope depends on WHAT you reload. Across a /reload inside one client run, a per-character global came back carrying a token from an earlier session while an account-wide global bound by identical code in the same handler came back empty. Across a full client restart, neither came back. So the account-wide path is dead in both cases, and the per-character path works only within a client run. Also measured: the two exotic WTF paths other developers named - WTF\Account\SavedVariables\ and WTF\SavedVariables\ - are neither read nor written. Files seeded there before a cold start were still untouched afterwards.

**Workaround.** None for persistence across sessions. ## SavedVariablesPerCharacter does NOT survive logging out either - measured on a cold start - so there is no way to keep user settings between play sessions on this build. It does survive a /reload, which the account-wide path does not. That is worth using for state an addon needs to carry across a reload inside one session, and it is what lifts the one-session constraint on the probe's own two-pass workflow (P.21). For data coming from outside the game, an external process writes Lua into the AddOns folder and the client executes it as addon code at load. That inbound channel works; it costs a manual /reload per refresh.

_Evidence: §P.9, §P.23, §P.27, §0.2 in `research/findings.md`._

## secret-value-contagion

tostring() on a secret value returns a SECRET STRING. The taint survives conversion.

A pcall around the read reports success and hands back a value that throws later, wherever it is next indexed - usually a print or a format, far from the read. This took the probe down mid-run. Worse, a secret string stored in SavedVariables would take the whole flush with it. Two things measured 2026-09-20 that make this harder to spot than it looks. type() reports "number" on a secret number, so a type check is NOT a secrecy check. And EQUALITY throws: `value == value` raises, which means the reflexive `if value == nil then` guard is itself unsafe on a secret. Comparison and arithmetic throw as expected; equality throwing is the one that catches people, because it is the guard they wrote to be careful.

**Workaround.** issecretvalue is the only safe test - not type(), not a comparison against nil. Use it before AND after conversion. The client also provides issecrettable, hasanysecretvalues, scrub, scrubsecretvalues, canaccesssecrets, secretwrap and dropsecretaccess.

_Evidence: §P.2, §P.25, §P.28 in `research/findings.md`._

## secure-setattribute-in-combat

SetAttribute on a secure action button SUCCEEDED in combat. Re-test before relying on it.

Retail protects exactly this, and it is the mechanism every action-bar addon depends on. The measurement here is that the call raised no error and fired no block event - which is weaker evidence than the attribute actually taking effect, and this client has already shown that a refusal can be silent.

_Evidence: §P.20 in `research/findings.md`._

## threat-values-secrecy

Threat VALUES are secret in combat, but threat STATE is not.

ShouldUnitThreatValuesBeSecret() is true in combat while ShouldUnitThreatStateBeSecret() is false. An addon may know whether it has aggro and not by how much. That kills the numeric threat meter and leaves the "you are about to pull" warning working, which does not look accidental.

_Evidence: §P.18 in `research/findings.md`._

## unit-health-secrecy

Unit health is secret at ALL times, including out of combat.

Measured 2026-09-20 on the player, standing still with no target and again in combat: UnitHealth("player") is a secret value in both states, and so is a target's. It behaves exactly like UnitPower. This was added late. Earlier runs measured power in both states and health only incidentally, so the document carried an always-on gate for power and nothing for health. A secondary report claiming health was always secret turned out to be right on that point.

**Workaround.** None for the number. The player's own UnitHealthMax is readable, so a denominator is available while the numerator is not; for any other unit neither is. Hand values to Blizzard's own widgets rather than reading them.

_Evidence: §P.25, §P.28 in `research/findings.md`._

## unit-power-secrecy

Unit power is secret at ALL times, including out of combat.

ShouldUnitPowerBeSecret("player") is true standing still with no target, and UnitPower("player") returns a secret value in both combat states. This directly contradicts Blizzard's published doctrine, which promises that "all class secondary resources remain fully non-secret". Measured twice, in both states, by gate and by value. Either the doctrine does not describe this client or this is a beta bug. UnitPowerMax was listed here until 2026-09-20 and has been moved out: on the PLAYER it is not secret in either combat state. See other-unit-max-values.

_Evidence: §P.3, §P.10, §P.18, §P.25 in `research/findings.md`._

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
