<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Secrets.ShouldSpellBookItemCooldownBeSecret

```lua
isCooldownSecret = C_Secrets.ShouldSpellBookItemCooldownBeSecret(spellBookItemSlotIndex, spellBookItemSpellBank)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `spellBookItemSlotIndex` | `luaIndex` | no |  |
| 2 | `spellBookItemSpellBank` | `SpellBookSpellBank` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `isCooldownSecret` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_Secrets.ShouldSpellBookItemCooldownBeSecret(spellBookItemSlotIndex, spellBookItemSpellBank)`

System: `SecretUtil` · Namespace: `C_Secrets`
