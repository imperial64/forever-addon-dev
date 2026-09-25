<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Secrets.ShouldUnitSpellCastBeSecret

```lua
isSpellCastSecret = C_Secrets.ShouldUnitSpellCastBeSecret(unit, spellIdentifier)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unit` | `UnitToken` | no |  |
| 2 | `spellIdentifier` | `SpellIdentifier` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `isSpellCastSecret` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_Secrets.ShouldUnitSpellCastBeSecret(unit, spellIdentifier)`

System: `SecretUtil` · Namespace: `C_Secrets`
