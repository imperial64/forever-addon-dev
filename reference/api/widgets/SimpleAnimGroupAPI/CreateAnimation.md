<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# SimpleAnimGroupAPI:CreateAnimation

```lua
anim = SimpleAnimGroupAPI:CreateAnimation(animationType, name, templateName)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `animationType` | `cstring` | yes |  |
| 2 | `name` | `cstring` | yes |  |
| 3 | `templateName` | `cstring` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `anim` | `SimpleAnim` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `ChecksForbiddenAspects` | `{ { Argument = "self", Aspect = 16384 } }` |
| this function | `SecretArguments` | `"NotAllowed"` |

Blizzard's own rendering: `CreateAnimation(optional animationType, optional name, optional templateName)`

System: `SimpleAnimGroupAPI` · Widget methods
