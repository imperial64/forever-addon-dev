<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_KeyBindings.GetBindingByKey

```lua
binding = C_KeyBindings.GetBindingByKey(action, context)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `action` | `cstring` | no |  |
| 2 | `context` | `BindingContext` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `binding` | `cstring` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_KeyBindings.GetBindingByKey(action, optional context)`

System: `KeyBindings` · Namespace: `C_KeyBindings`
