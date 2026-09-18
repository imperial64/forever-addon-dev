<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# C_SpellBook.FindSpellBookSlotForSpell

```lua
spellBookItemSlotIndex, spellBookItemSpellBank = C_SpellBook.FindSpellBookSlotForSpell(spellIdentifier, includeHidden, includeFlyouts, includeFutureSpells, includeOffSpec)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `spellIdentifier` | `SpellIdentifier` | no |  |
| 2 | `includeHidden` | `bool` | no | `False` |
| 3 | `includeFlyouts` | `bool` | no | `True` |
| 4 | `includeFutureSpells` | `bool` | no | `False` |
| 5 | `includeOffSpec` | `bool` | no | `False` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `spellBookItemSlotIndex` | `luaIndex` | no |  |
| 2 | `spellBookItemSpellBank` | `SpellBookSpellBank` | no |  |

Blizzard's own rendering: `C_SpellBook.FindSpellBookSlotForSpell(spellIdentifier, optional includeHidden, optional includeFlyouts, optional includeFutureSpells, optional includeOffSpec)`

System: `SpellBook` · Namespace: `C_SpellBook`
