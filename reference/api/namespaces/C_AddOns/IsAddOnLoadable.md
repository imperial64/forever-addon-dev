<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

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

Blizzard's own rendering: `C_AddOns.IsAddOnLoadable(name, optional character, optional demandLoaded)`

System: `AddOns` · Namespace: `C_AddOns`
