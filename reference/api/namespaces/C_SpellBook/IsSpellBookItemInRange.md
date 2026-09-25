<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_SpellBook.IsSpellBookItemInRange

```lua
inRange = C_SpellBook.IsSpellBookItemInRange(spellBookItemSlotIndex, spellBookItemSpellBank, targetUnit)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `spellBookItemSlotIndex` | `luaIndex` | no |  |
| 2 | `spellBookItemSpellBank` | `SpellBookSpellBank` | no |  |
| 3 | `targetUnit` | `UnitToken` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `inRange` | `bool` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_SpellBook.IsSpellBookItemInRange(spellBookItemSlotIndex, spellBookItemSpellBank, optional targetUnit)`

System: `SpellBook` · Namespace: `C_SpellBook`
