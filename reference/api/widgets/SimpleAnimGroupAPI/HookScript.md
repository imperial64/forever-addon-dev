<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# SimpleAnimGroupAPI:HookScript

```lua
success = SimpleAnimGroupAPI:HookScript(scriptTypeName, script, bindingType)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `scriptTypeName` | `ScriptTypeName` | no |  |
| 2 | `script` | `LuaFunctionReference` | no |  |
| 3 | `bindingType` | `ScriptBindingType` | no | `Extrinsic` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `success` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `ChecksForbiddenAspects` | `{ { Argument = "self", Aspect = 2 } }` |
| this function | `RequiresAssignableScript` | `true` |
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `HookScript(scriptTypeName, script, optional bindingType)`

System: `SimpleAnimGroupAPI` · Widget methods
