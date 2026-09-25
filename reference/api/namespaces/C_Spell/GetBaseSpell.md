<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Spell.GetBaseSpell

```lua
baseSpellID = C_Spell.GetBaseSpell(spellIdentifier, spec)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `spellIdentifier` | `SpellIdentifier` | no |  |
| 2 | `spec` | `number` | no | `0` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `baseSpellID` | `number` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenTainted"` |
| argument `spec` | `NeverSecret` | `true` |

Blizzard's own rendering: `C_Spell.GetBaseSpell(spellIdentifier, optional spec)`

System: `Spell` · Namespace: `C_Spell`
