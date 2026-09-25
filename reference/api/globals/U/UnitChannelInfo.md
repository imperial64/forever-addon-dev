<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# UnitChannelInfo

```lua
name, displayName, textureID, startTimeMs, endTimeMs, isTradeskill, notInterruptible, spellID, isEmpowered, numEmpowerStages, castBarID = UnitChannelInfo(unit)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unit` | `UnitTokenPvPRestrictedForAddOns` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `name` | `cstring` | no |  |
| 2 | `displayName` | `cstring` | no |  |
| 3 | `textureID` | `fileID` | no |  |
| 4 | `startTimeMs` | `number` | no |  |
| 5 | `endTimeMs` | `number` | no |  |
| 6 | `isTradeskill` | `bool` | no |  |
| 7 | `notInterruptible` | `bool` | yes |  |
| 8 | `spellID` | `number` | no |  |
| 9 | `isEmpowered` | `bool` | no |  |
| 10 | `numEmpowerStages` | `number` | no |  |
| 11 | `castBarID` | `UnitCastBarID` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretWhenUnitSpellCastRestricted` | `true` |
| return `isTradeskill` | `NeverSecret` | `true` |
| return `isEmpowered` | `NeverSecret` | `true` |
| return `numEmpowerStages` | `NeverSecret` | `true` |
| return `castBarID` | `NeverSecret` | `true` |

Blizzard's own rendering: `UnitChannelInfo(unit)`

System: `Unit`
