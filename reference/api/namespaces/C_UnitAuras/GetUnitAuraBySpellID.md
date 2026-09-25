<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_UnitAuras.GetUnitAuraBySpellID

> **SECRET — measured, in combat only.** Aura reads RAISE in combat. They do not return nil.
> Measured 2026-09-20 on build 69913. Evidence: §P.18, §P.19 in [findings](../../../../research/findings.md).
> 
> _Workaround:_ Read before the pull and hold the value, or hand a duration object to a Cooldown widget before combat starts and let it keep ticking.

```lua
aura = C_UnitAuras.GetUnitAuraBySpellID(unit, spellID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unit` | `UnitTokenRestrictedForAddOns` | no |  |
| 2 | `spellID` | `SpellIdentifier` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `aura` | `AuraData` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `RequiresNonSecretAura` | `true` |
| this function | `SecretArguments` | `"AllowedWhenTainted"` |
| this function | `SecretWhenUnitAuraRestricted` | `true` |
| argument `unit` | `NeverSecret` | `true` |

Blizzard's own rendering: `C_UnitAuras.GetUnitAuraBySpellID(unit, spellID)`

System: `UnitAuras` · Namespace: `C_UnitAuras`
