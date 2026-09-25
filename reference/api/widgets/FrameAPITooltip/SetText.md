<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# FrameAPITooltip:SetText

```lua
FrameAPITooltip:SetText(text, colorR, colorG, colorB, alpha, wrap)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `text` | `cstring` | no |  |
| 2 | `colorR` | `number` | no |  |
| 3 | `colorG` | `number` | no |  |
| 4 | `colorB` | `number` | no |  |
| 5 | `alpha` | `number` | no | `1` |
| 6 | `wrap` | `bool` | no | `False` |

**Returns**

_None._

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenTainted"` |
| this function | `SecretArgumentsAddAspect` | `{ 8 }` |
| argument `text` | `ConditionalSecret` | `true` |
| argument `alpha` | `ConditionalSecret` | `true` |
| argument `wrap` | `ConditionalSecret` | `true` |

Blizzard's own rendering: `SetText(text, colorR, colorG, colorB, optional alpha, optional wrap)`

System: `FrameAPITooltip` · Widget methods
