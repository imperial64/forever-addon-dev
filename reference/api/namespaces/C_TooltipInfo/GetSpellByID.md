<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

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

Blizzard's own rendering: `C_TooltipInfo.GetSpellByID(spellID, optional isPet, optional showSubtext, optional dontOverride, optional difficultyID, optional isLink)`

System: `TooltipInfo` · Namespace: `C_TooltipInfo`
