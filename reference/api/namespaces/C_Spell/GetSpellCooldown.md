<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# C_Spell.GetSpellCooldown

> **SECRET — measured, in combat only.** Spell and action cooldowns become secret in combat.
> Measured 2026-09-20 on build 69913. Evidence: §P.18 in [findings](../../../../research/findings.md).
> 
> _Workaround:_ The sanctioned path is C_Spell.GetSpellCooldownDuration -> LuaDurationObject -> Cooldown:SetCooldownFromDurationObject, which does not require addon code to read the number.

```lua
spellCooldownInfo = C_Spell.GetSpellCooldown(spellIdentifier)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `spellIdentifier` | `SpellIdentifier` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `spellCooldownInfo` | `SpellCooldownInfo` | no |  |

Blizzard's own rendering: `C_Spell.GetSpellCooldown(spellIdentifier)`

System: `Spell` · Namespace: `C_Spell`
