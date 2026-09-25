<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_CooldownViewer.GetCooldownViewerCategorySet

```lua
cooldownIDs = C_CooldownViewer.GetCooldownViewerCategorySet(category, allowUnlearned)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `category` | `CooldownViewerCategory` | no |  |
| 2 | `allowUnlearned` | `bool` | no | `False` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `cooldownIDs` | `table&lt;number&gt;` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_CooldownViewer.GetCooldownViewerCategorySet(category, optional allowUnlearned)`

System: `CooldownViewer` · Namespace: `C_CooldownViewer`
