<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_VoiceChat.SpeakText

```lua
C_VoiceChat.SpeakText(voiceID, text, rate, volume, overlap)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `voiceID` | `number` | no |  |
| 2 | `text` | `cstring` | no |  |
| 3 | `rate` | `number` | no |  |
| 4 | `volume` | `number` | no |  |
| 5 | `overlap` | `bool` | no | `False` |

**Returns**

_None._

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenTainted"` |
| argument `voiceID` | `NeverSecret` | `true` |
| argument `text` | `ConditionalSecret` | `true` |
| argument `rate` | `NeverSecret` | `true` |
| argument `volume` | `NeverSecret` | `true` |
| argument `overlap` | `NeverSecret` | `true` |

Blizzard's own rendering: `C_VoiceChat.SpeakText(voiceID, text, rate, volume, optional overlap)`

System: `VoiceChat` · Namespace: `C_VoiceChat`
