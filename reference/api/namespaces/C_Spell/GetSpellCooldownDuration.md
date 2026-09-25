<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Spell.GetSpellCooldownDuration

```lua
duration = C_Spell.GetSpellCooldownDuration(spellIdentifier, ignoreGCD)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `spellIdentifier` | `SpellIdentifier` | no |  |
| 2 | `ignoreGCD` | `bool` | no | `False` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `duration` | `LuaDurationObject` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenTainted"` |

Blizzard's own rendering: `C_Spell.GetSpellCooldownDuration(spellIdentifier, optional ignoreGCD)`

System: `Spell` · Namespace: `C_Spell`
