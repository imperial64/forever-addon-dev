<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Spell.GetSpellDisplayCount

```lua
displayCount = C_Spell.GetSpellDisplayCount(spellIdentifier, maxDisplayCount, replacementString)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `spellIdentifier` | `SpellIdentifier` | no |  |
| 2 | `maxDisplayCount` | `number` | no | `9999` |
| 3 | `replacementString` | `cstring` | no | `*` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `displayCount` | `string` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretWhenCooldownsRestricted` | `true` |

Blizzard's own rendering: `C_Spell.GetSpellDisplayCount(spellIdentifier, optional maxDisplayCount, optional replacementString)`

System: `Spell` · Namespace: `C_Spell`
