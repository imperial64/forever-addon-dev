<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_AddOns.GetAddOnEnableState

```lua
state = C_AddOns.GetAddOnEnableState(name, character)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `name` | `uiAddon` | no |  |
| 2 | `character` | `cstring` | no | `0` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `state` | `AddOnEnableState` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_AddOns.GetAddOnEnableState(name, optional character)`

System: `AddOns` · Namespace: `C_AddOns`
