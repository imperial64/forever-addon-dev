<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_ItemSocketInfo.GetExistingSocketInfo

```lua
name, icon, gemMatchesSocket = C_ItemSocketInfo.GetExistingSocketInfo(index)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `index` | `luaIndex` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `name` | `string` | yes |  |
| 2 | `icon` | `fileID` | yes |  |
| 3 | `gemMatchesSocket` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_ItemSocketInfo.GetExistingSocketInfo(index)`

System: `ItemSocketInfo` · Namespace: `C_ItemSocketInfo`
