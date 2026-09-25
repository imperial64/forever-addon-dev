<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_CVar.GetCVar

> **CAUTION — measured, at all times.** A CVar's VALUE does not tell you whether it is in effect. The enable flag is a separate CVar.
> Measured 2026-09-20 on build 69913. Evidence: §Q.1, §P.22 in [findings](../../../../research/findings.md).
> 
> _Workaround:_ Before trusting a CVar's value, look for a paired use<Name> and read it with GetCVarBool. ConsoleGetAllCommands() enumerates the real names, which is how the graphics CVars in P.22 were found; do not assume a flag exists because a neighbouring CVar has one.

```lua
value = C_CVar.GetCVar(name)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `name` | `cstring` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `value` | `string` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"NotAllowed"` |

Blizzard's own rendering: `C_CVar.GetCVar(name)`

System: `CVarScripts` · Namespace: `C_CVar`
