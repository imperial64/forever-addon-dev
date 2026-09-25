<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_SpellBook.GetSpellBookItemLink

```lua
spellLink = C_SpellBook.GetSpellBookItemLink(spellBookItemSlotIndex, spellBookItemSpellBank, glyphID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `spellBookItemSlotIndex` | `luaIndex` | no |  |
| 2 | `spellBookItemSpellBank` | `SpellBookSpellBank` | no |  |
| 3 | `glyphID` | `number` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `spellLink` | `string` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_SpellBook.GetSpellBookItemLink(spellBookItemSlotIndex, spellBookItemSpellBank, optional glyphID)`

System: `SpellBook` · Namespace: `C_SpellBook`
