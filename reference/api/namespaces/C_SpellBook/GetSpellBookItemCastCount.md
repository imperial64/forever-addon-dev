<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_SpellBook.GetSpellBookItemCastCount

```lua
castCount = C_SpellBook.GetSpellBookItemCastCount(spellBookItemSlotIndex, spellBookItemSpellBank)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `spellBookItemSlotIndex` | `luaIndex` | no |  |
| 2 | `spellBookItemSpellBank` | `SpellBookSpellBank` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `castCount` | `number` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretWhenCooldownsRestricted` | `true` |

Blizzard's own rendering: `C_SpellBook.GetSpellBookItemCastCount(spellBookItemSlotIndex, spellBookItemSpellBank)`

System: `SpellBook` · Namespace: `C_SpellBook`
