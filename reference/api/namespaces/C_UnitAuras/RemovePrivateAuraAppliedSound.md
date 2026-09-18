<!-- GENERATED from Blizzard_APIDocumentation, client build unknown. Do not edit; edit the generator. -->

# C_UnitAuras.RemovePrivateAuraAppliedSound

> **SECRET — measured, in combat only.** Aura reads RAISE in combat. They do not return nil.
> Measured 2026-09-18 on build 69913. Evidence: §P.18, §P.19 in [findings](../../../../docs/findings.md).
> 
> _Workaround:_ Read before the pull and hold the value, or hand a duration object to a Cooldown widget before combat starts and let it keep ticking.

> **Present on this client, but not documented by Blizzard.** It exists in the client's global table and can be called; Blizzard's own API documentation carries no signature for it, so none is shown here rather than one being invented.

Source: ForeverProbe global surface dump.
Namespace: `C_UnitAuras`
