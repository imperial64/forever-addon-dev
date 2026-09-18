<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# C_AddOns.GetAddOnInfo

```lua
name, title, notes, loadable, reason, security = C_AddOns.GetAddOnInfo(name)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `name` | `uiAddon` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `name` | `cstring` | no |  |
| 2 | `title` | `cstring` | no |  |
| 3 | `notes` | `cstring` | no |  |
| 4 | `loadable` | `bool` | no |  |
| 5 | `reason` | `cstring` | no |  |
| 6 | `security` | `cstring` | no |  |

Blizzard's own rendering: `C_AddOns.GetAddOnInfo(name)`

System: `AddOns` · Namespace: `C_AddOns`
