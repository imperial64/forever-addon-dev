<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_TooltipInfo.GetSpellByID

```lua
data = C_TooltipInfo.GetSpellByID(spellID, isPet, showSubtext, dontOverride, difficultyID, isLink)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `spellID` | `SpellIdentifier` | no |  |
| 2 | `isPet` | `bool` | yes |  |
| 3 | `showSubtext` | `bool` | yes |  |
| 4 | `dontOverride` | `bool` | yes |  |
| 5 | `difficultyID` | `number` | yes |  |
| 6 | `isLink` | `bool` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `data` | `TooltipData` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenTainted"` |
| argument `isPet` | `NeverSecret` | `true` |
| argument `showSubtext` | `NeverSecret` | `true` |
| argument `dontOverride` | `NeverSecret` | `true` |
| argument `difficultyID` | `NeverSecret` | `true` |
| argument `isLink` | `NeverSecret` | `true` |

Blizzard's own rendering: `C_TooltipInfo.GetSpellByID(spellID, optional isPet, optional showSubtext, optional dontOverride, optional difficultyID, optional isLink)`

System: `TooltipInfo` · Namespace: `C_TooltipInfo`
