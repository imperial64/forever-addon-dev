<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_ActionBar.HasSpellActionButtons

```lua
hasSpellActionButtons = C_ActionBar.HasSpellActionButtons(spellID, setToSearch)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `spellID` | `SpellIdentifier` | no |  |
| 2 | `setToSearch` | `ActionBarSet` | no | `All` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `hasSpellActionButtons` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenTainted"` |
| argument `setToSearch` | `NeverSecret` | `true` |

Blizzard's own rendering: `C_ActionBar.HasSpellActionButtons(spellID, optional setToSearch)`

System: `ActionBar` · Namespace: `C_ActionBar`
