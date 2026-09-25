<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Spell.GetSpellTexture

```lua
iconID, originalIconID, conditionalIconID = C_Spell.GetSpellTexture(spellIdentifier)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `spellIdentifier` | `SpellIdentifier` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `iconID` | `fileID` | no |  |
| 2 | `originalIconID` | `fileID` | no |  |
| 3 | `conditionalIconID` | `fileID` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenTainted"` |

Blizzard's own rendering: `C_Spell.GetSpellTexture(spellIdentifier)`

System: `Spell` · Namespace: `C_Spell`
