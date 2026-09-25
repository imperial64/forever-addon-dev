<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# SimpleFrameAPI:RegisterUnitEvent

```lua
registered = SimpleFrameAPI:RegisterUnitEvent(eventName, units)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `eventName` | `cstring` | no |  |
| 2 | `units` | `UnitTokenType` | no |  |

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

Blizzard's own rendering: `RegisterUnitEvent(eventName, units)`

System: `SimpleFrameAPI` · Widget methods
