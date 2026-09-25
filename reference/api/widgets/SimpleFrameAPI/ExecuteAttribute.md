<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# SimpleFrameAPI:ExecuteAttribute

```lua
success, returns = SimpleFrameAPI:ExecuteAttribute(attributeName, arguments)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `attributeName` | `cstring` | no |  |
| 2 | `arguments` | `cstring` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `success` | `bool` | no |  |
| 2 | `returns` | `cstring` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretReturnsForAspect` | `{ 1 }` |

Blizzard's own rendering: `ExecuteAttribute(attributeName, optional arguments)`

System: `SimpleFrameAPI` · Widget methods
