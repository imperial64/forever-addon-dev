<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_DelvesUI.GetCurioLink

```lua
curioLink = C_DelvesUI.GetCurioLink(spellID, rarity)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `spellID` | `SpellIdentifier` | no |  |
| 2 | `rarity` | `CurioRarity` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `curioLink` | `cstring` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenTainted"` |
| argument `rarity` | `NeverSecret` | `true` |

Blizzard's own rendering: `C_DelvesUI.GetCurioLink(spellID, rarity)`

System: `DelvesUI` · Namespace: `C_DelvesUI`
