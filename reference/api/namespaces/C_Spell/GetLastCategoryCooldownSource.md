<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Spell.GetLastCategoryCooldownSource

```lua
spellID, itemID = C_Spell.GetLastCategoryCooldownSource(spellCategory)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `spellCategory` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `spellID` | `number` | yes |  |
| 2 | `itemID` | `number` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenTainted"` |
| this function | `SecretWhenCooldownsRestricted` | `true` |

Blizzard's own rendering: `C_Spell.GetLastCategoryCooldownSource(spellCategory)`

System: `Spell` · Namespace: `C_Spell`
