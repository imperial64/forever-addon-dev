<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# SimpleFrameAPI:RegisterEventCallback

```lua
registered = SimpleFrameAPI:RegisterEventCallback(eventName, cb)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `eventName` | `cstring` | no |  |
| 2 | `cb` | `FrameEventCallbackType` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `registered` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `ChecksForbiddenAspects` | `{ { Argument = "self", Aspect = 16 } }` |
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `RegisterEventCallback(eventName, cb)`

System: `SimpleFrameAPI` · Widget methods
