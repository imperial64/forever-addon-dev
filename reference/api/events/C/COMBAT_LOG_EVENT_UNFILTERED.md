<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# COMBAT_LOG_EVENT_UNFILTERED

> **FORBIDDEN — measured, at all times.** Addons may not register for the combat log, in either form.
> Measured 2026-09-20 on build 69913. Evidence: §P.1, §P.12 in [findings](../../../../research/findings.md).
> 
> _Workaround:_ None for parsing. Blizzard ships C_DamageMeter for damage numbers. Every other event tried is permitted, including UNIT_AURA, UNIT_COMBAT and both PLAYER_REGEN events - the rule is "no combat log", not "no combat information".

**Payload**

_No payload._

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this event | `HasRestrictions` | `true` |

System: `CombatLog`
