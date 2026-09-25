<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_CombatAudioAlert.SpeakText

```lua
utteranceID = C_CombatAudioAlert.SpeakText(text, category, allowOverlap)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `text` | `string` | no |  |
| 2 | `category` | `CombatAudioAlertCategory` | no |  |
| 3 | `allowOverlap` | `bool` | no | `True` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `utteranceID` | `number` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_CombatAudioAlert.SpeakText(text, category, optional allowOverlap)`

System: `CombatAudioAlert` · Namespace: `C_CombatAudioAlert`
