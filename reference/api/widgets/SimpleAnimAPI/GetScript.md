<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# SimpleAnimAPI:GetScript

```lua
script = SimpleAnimAPI:GetScript(scriptTypeName, bindingType)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `scriptTypeName` | `ScriptTypeName` | no |  |
| 2 | `bindingType` | `ScriptBindingType` | no | `Extrinsic` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `script` | `LuaFunctionReference` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `ChecksForbiddenAspects` | `{ { Argument = "self", Aspect = 2 } }` |
| this function | `ConstSecretAccessor` | `true` |
| this function | `RequiresSupportedScript` | `true` |
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `GetScript(scriptTypeName, optional bindingType)`

System: `SimpleAnimAPI` · Widget methods
