<!-- GENERATED from Blizzard_APIDocumentation, client build unknown. Do not edit; edit the generator. -->

# C_Spell.GetSpellCharges

> **SECRET — measured, in combat only.** Spell and action cooldowns become secret in combat.
> Measured 2026-09-18 on build 69913. Evidence: §P.18 in [findings](../../../../docs/findings.md).
> 
> _Workaround:_ The sanctioned path is C_Spell.GetSpellCooldownDuration -> LuaDurationObject -> Cooldown:SetCooldownFromDurationObject, which does not require addon code to read the number.

```lua
chargeInfo = C_Spell.GetSpellCharges(spellIdentifier)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `spellIdentifier` | `SpellIdentifier` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `chargeInfo` | `SpellChargeInfo` | no |  |

Blizzard's own rendering: `C_Spell.GetSpellCharges(spellIdentifier)`

System: `Spell` · Namespace: `C_Spell`
