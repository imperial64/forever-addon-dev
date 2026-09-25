<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_PartyInfo.IsGUIDInGroup

```lua
isInGroup = C_PartyInfo.IsGUIDInGroup(guid, category)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `guid` | `WOWGUID` | no |  |
| 2 | `category` | `luaIndex` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `isInGroup` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_PartyInfo.IsGUIDInGroup(guid, optional category)`

System: `PartyInfo` · Namespace: `C_PartyInfo`
