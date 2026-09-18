<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# C_UnitAuras.AddAuraSound

> **SECRET — measured, in combat only.** Aura reads RAISE in combat. They do not return nil.
> Measured 2026-09-18 on build 69913. Evidence: §P.18, §P.19 in [findings](../../../../research/findings.md).
> 
> _Workaround:_ Read before the pull and hold the value, or hand a duration object to a Cooldown widget before combat starts and let it keep ticking.

> **RESTRICTED — Blizzard flag.** This function carries `HasRestrictions` in the client's own documentation, meaning it is gated on a hardware event or refuses to run from a script.

```lua
auraSoundID = C_UnitAuras.AddAuraSound(trigger, sound)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `trigger` | `UnitAuraSoundTrigger` | no |  |
| 2 | `sound` | `UnitAuraSoundInfo` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `auraSoundID` | `number` | yes |  |

Blizzard's own rendering: `C_UnitAuras.AddAuraSound(trigger, sound)`

System: `UnitAuras` · Namespace: `C_UnitAuras`
