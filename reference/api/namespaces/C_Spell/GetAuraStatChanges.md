<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Spell.GetAuraStatChanges

```lua
healthChange, powerTypeChanges = C_Spell.GetAuraStatChanges(spellID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `spellID` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `healthChange` | `number` | no |  |
| 2 | `powerTypeChanges` | `table&lt;PowerTypeChange&gt;` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_Spell.GetAuraStatChanges(spellID)`

System: `Spell` · Namespace: `C_Spell`
