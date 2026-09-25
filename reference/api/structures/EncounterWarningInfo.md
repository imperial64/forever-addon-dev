<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# EncounterWarningInfo

_Structure_

**Fields**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `text` | `cstring` | no |  |
| 2 | `casterGUID` | `WOWGUID` | no |  |
| 3 | `casterName` | `cstring` | no |  |
| 4 | `targetGUID` | `WOWGUID` | no |  |
| 5 | `targetName` | `cstring` | no |  |
| 6 | `iconFileID` | `number` | no |  |
| 7 | `tooltipSpellID` | `number` | no |  |
| 8 | `isDeadly` | `bool` | no |  |
| 9 | `color` | `colorRGBA (ColorMixin)` | no |  |
| 10 | `duration` | `Seconds` | no |  |
| 11 | `severity` | `EncounterEventSeverity` | no |  |
| 12 | `shouldPlaySound` | `bool` | no |  |
| 13 | `shouldShowChatMessage` | `bool` | no |  |
| 14 | `shouldShowWarning` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| field `text` | `SecretValue` | `true` |
| field `casterGUID` | `SecretValue` | `true` |
| field `casterName` | `SecretValue` | `true` |
| field `targetGUID` | `SecretValue` | `true` |
| field `targetName` | `SecretValue` | `true` |
| field `iconFileID` | `SecretValue` | `true` |
| field `tooltipSpellID` | `SecretValue` | `true` |
| field `isDeadly` | `SecretValue` | `true` |
| field `color` | `SecretValue` | `true` |

System: `EncounterWarnings`
