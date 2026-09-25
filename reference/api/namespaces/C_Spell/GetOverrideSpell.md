<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Spell.GetOverrideSpell

```lua
overrideSpellID = C_Spell.GetOverrideSpell(spellIdentifier, spec, onlyKnown, ignoreOverrideSpellID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `spellIdentifier` | `SpellIdentifier` | no |  |
| 2 | `spec` | `number` | no | `0` |
| 3 | `onlyKnown` | `bool` | no | `True` |
| 4 | `ignoreOverrideSpellID` | `number` | no | `0` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `overrideSpellID` | `number` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_Spell.GetOverrideSpell(spellIdentifier, optional spec, optional onlyKnown, optional ignoreOverrideSpellID)`

System: `Spell` · Namespace: `C_Spell`
