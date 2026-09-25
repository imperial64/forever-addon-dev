<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# GetActionCooldown

> **SECRET — measured, in combat only.** Spell and action cooldowns become secret in combat.
> Measured 2026-09-20 on build 69913. Evidence: §P.18 in [findings](../../../../research/findings.md).
> 
> _Workaround:_ The sanctioned path is C_Spell.GetSpellCooldownDuration -> LuaDurationObject -> Cooldown:SetCooldownFromDurationObject, which does not require addon code to read the number.

> **Present on this client, but not documented by Blizzard.** It exists in the client's global table and can be called; Blizzard's own API documentation carries no signature for it, so none is shown here rather than one being invented.

Source: ForeverProbe global surface dump.
