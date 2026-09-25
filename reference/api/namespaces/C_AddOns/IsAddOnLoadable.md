<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_AddOns.IsAddOnLoadable

```lua
loadable, reason = C_AddOns.IsAddOnLoadable(name, character, demandLoaded)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `name` | `uiAddon` | no |  |
| 2 | `character` | `cstring` | no | `0` |
| 3 | `demandLoaded` | `bool` | no | `False` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `loadable` | `bool` | no |  |
| 2 | `reason` | `cstring` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_AddOns.IsAddOnLoadable(name, optional character, optional demandLoaded)`

System: `AddOns` · Namespace: `C_AddOns`
