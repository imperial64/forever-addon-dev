<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# SimpleFrameAPI:IsEventRegistered

```lua
isRegistered, units = SimpleFrameAPI:IsEventRegistered(eventName)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `eventName` | `cstring` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `isRegistered` | `bool` | no |  |
| 2 | `units` | `UnitTokenType` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `ChecksForbiddenAspects` | `{ { Argument = "self", Aspect = 16 } }` |
| this function | `ConstSecretAccessor` | `true` |
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `IsEventRegistered(eventName)`

System: `SimpleFrameAPI` · Widget methods
