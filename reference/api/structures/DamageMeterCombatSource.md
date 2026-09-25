<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# DamageMeterCombatSource

_Structure_

**Fields**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `sourceGUID` | `WOWGUID` | yes |  |
| 2 | `sourceCreatureID` | `number` | yes |  |
| 3 | `name` | `cstring` | no |  |
| 4 | `classFilename` | `cstring` | no |  |
| 5 | `specIconID` | `fileID` | no |  |
| 6 | `totalAmount` | `number` | no |  |
| 7 | `amountPerSecond` | `number` | no |  |
| 8 | `isLocalPlayer` | `bool` | no |  |
| 9 | `deathRecapID` | `number` | no |  |
| 10 | `deathTimeSeconds` | `number` | no |  |
| 11 | `classification` | `cstring` | no |  |
| 12 | `sourceDisplayType` | `DamageMeterSourceDisplayType` | no |  |
| 13 | `factionGroup` | `cstring` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| field `sourceGUID` | `ConditionalSecret` | `true` |
| field `name` | `ConditionalSecret` | `true` |
| field `classFilename` | `NeverSecret` | `true` |
| field `specIconID` | `NeverSecret` | `true` |
| field `isLocalPlayer` | `NeverSecret` | `true` |
| field `deathRecapID` | `NeverSecret` | `true` |
| field `classification` | `NeverSecret` | `true` |

System: `DamageMeter`
