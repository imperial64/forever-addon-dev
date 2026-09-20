<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# C_CVar.SetCVar

> **PERMITTED — measured, at all times.** Display brightness and contrast ARE addon-writable, live, at frame rate.
> Measured 2026-09-20 on build 69913. Evidence: §P.22 in [findings](../../../../research/findings.md).
> 
> _Workaround:_ Until /fprobe video has been run mid-fight, freeze on PLAYER_REGEN_DISABLED and resume on PLAYER_REGEN_ENABLED rather than assuming the write lands in combat.

```lua
success = C_CVar.SetCVar(name, value)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `name` | `cstring` | no |  |
| 2 | `value` | `cstring` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `success` | `bool` | no |  |

Blizzard's own rendering: `C_CVar.SetCVar(name, optional value)`

System: `CVarScripts` · Namespace: `C_CVar`
