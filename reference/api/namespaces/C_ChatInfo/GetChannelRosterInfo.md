<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_ChatInfo.GetChannelRosterInfo

```lua
name, owner, moderator, guid = C_ChatInfo.GetChannelRosterInfo(channelIndex, rosterIndex)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `channelIndex` | `luaIndex` | no |  |
| 2 | `rosterIndex` | `luaIndex` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `name` | `string` | no |  |
| 2 | `owner` | `bool` | no |  |
| 3 | `moderator` | `bool` | no |  |
| 4 | `guid` | `WOWGUID` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_ChatInfo.GetChannelRosterInfo(channelIndex, rosterIndex)`

System: `ChatInfo` · Namespace: `C_ChatInfo`
