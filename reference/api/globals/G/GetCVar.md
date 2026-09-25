<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# GetCVar

> **CAUTION — measured, at all times.** A CVar's VALUE does not tell you whether it is in effect. The enable flag is a separate CVar.
> Measured 2026-09-20 on build 69913. Evidence: §Q.1, §P.22 in [findings](../../../../research/findings.md).
> 
> _Workaround:_ Before trusting a CVar's value, look for a paired use<Name> and read it with GetCVarBool. ConsoleGetAllCommands() enumerates the real names, which is how the graphics CVars in P.22 were found; do not assume a flag exists because a neighbouring CVar has one.

> **Present on this client, but not documented by Blizzard.** It exists in the client's global table and can be called; Blizzard's own API documentation carries no signature for it, so none is shown here rather than one being invented.

Source: ForeverProbe global surface dump.
