<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_TooltipInfo.GetMountBySpellID

```lua
data = C_TooltipInfo.GetMountBySpellID(spellID, checkIndoors)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `spellID` | `SpellIdentifier` | no |  |
| 2 | `checkIndoors` | `bool` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `data` | `TooltipData` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenTainted"` |
| argument `checkIndoors` | `NeverSecret` | `true` |

Blizzard's own rendering: `C_TooltipInfo.GetMountBySpellID(spellID, optional checkIndoors)`

System: `TooltipInfo` · Namespace: `C_TooltipInfo`
