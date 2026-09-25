<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# UnitCastingInfo

```lua
name, displayName, textureID, startTimeMs, endTimeMs, isTradeskill, castID, notInterruptible, castingSpellID, castBarID, delayTimeMs = UnitCastingInfo(unit)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unit` | `UnitTokenPvPRestrictedForAddOns` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `name` | `cstring` | no |  |
| 2 | `displayName` | `string` | no |  |
| 3 | `textureID` | `fileID` | no |  |
| 4 | `startTimeMs` | `number` | no |  |
| 5 | `endTimeMs` | `number` | no |  |
| 6 | `isTradeskill` | `bool` | no |  |
| 7 | `castID` | `WOWGUID` | no |  |
| 8 | `notInterruptible` | `bool` | yes |  |
| 9 | `castingSpellID` | `number` | no |  |
| 10 | `castBarID` | `UnitCastBarID` | yes |  |
| 11 | `delayTimeMs` | `number` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretWhenUnitSpellCastRestricted` | `true` |
| return `isTradeskill` | `NeverSecret` | `true` |
| return `castBarID` | `NeverSecret` | `true` |
| return `delayTimeMs` | `NeverSecret` | `true` |

Blizzard's own rendering: `UnitCastingInfo(unit)`

System: `Unit`
