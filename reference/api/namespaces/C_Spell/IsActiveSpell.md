<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Spell.IsActiveSpell

```lua
isActiveSpell = C_Spell.IsActiveSpell(spellIdentifier, targetUnit)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `spellIdentifier` | `SpellIdentifier` | no |  |
| 2 | `targetUnit` | `UnitToken` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `isActiveSpell` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenTainted"` |
| this function | `SecretWhenUnitAuraRestricted` | `true` |
| this function | `SecretWhenUnitIdentityRestricted` | `true` |

Blizzard's own rendering: `C_Spell.IsActiveSpell(spellIdentifier, optional targetUnit)`

System: `Spell` · Namespace: `C_Spell`
