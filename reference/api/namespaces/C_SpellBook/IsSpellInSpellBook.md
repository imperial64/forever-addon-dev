<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_SpellBook.IsSpellInSpellBook

```lua
isInSpellBook = C_SpellBook.IsSpellInSpellBook(spellID, spellBank, includeOverrides)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `spellID` | `number` | no |  |
| 2 | `spellBank` | `SpellBookSpellBank` | no | `Player` |
| 3 | `includeOverrides` | `bool` | no | `True` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `isInSpellBook` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_SpellBook.IsSpellInSpellBook(spellID, optional spellBank, optional includeOverrides)`

System: `SpellBook` · Namespace: `C_SpellBook`
