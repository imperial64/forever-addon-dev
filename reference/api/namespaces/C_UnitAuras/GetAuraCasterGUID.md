<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_UnitAuras.GetAuraCasterGUID

> **SECRET — measured, in combat only.** Aura reads RAISE in combat. They do not return nil.
> Measured 2026-09-20 on build 69913. Evidence: §P.18, §P.19 in [findings](../../../../research/findings.md).
> 
> _Workaround:_ Read before the pull and hold the value, or hand a duration object to a Cooldown widget before combat starts and let it keep ticking.

```lua
casterGUID = C_UnitAuras.GetAuraCasterGUID(auraInstanceUnit, auraInstanceID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `auraInstanceUnit` | `UnitToken` | no |  |
| 2 | `auraInstanceID` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `casterGUID` | `WOWGUID` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `RequiresUnitAuraAccess` | `true` |
| this function | `RequiresValidUnitAuraInstance` | `true` |
| this function | `SecretArguments` | `"AllowedWhenTainted"` |
| this function | `SecretWhenUnitAuraRestricted` | `true` |

Blizzard's own rendering: `C_UnitAuras.GetAuraCasterGUID(auraInstanceUnit, auraInstanceID)`

System: `UnitAuras` · Namespace: `C_UnitAuras`
