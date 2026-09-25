<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_LFGList.DoesEntryTitleMatchPrebuiltTitle

```lua
matches = C_LFGList.DoesEntryTitleMatchPrebuiltTitle(activityID, groupID, playstyle, generalPlaystyle)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `activityID` | `number` | no |  |
| 2 | `groupID` | `number` | no |  |
| 3 | `playstyle` | `LFGEntryPlaystyle` | yes |  |
| 4 | `generalPlaystyle` | `LFGEntryGeneralPlaystyle` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `matches` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_LFGList.DoesEntryTitleMatchPrebuiltTitle(activityID, groupID, optional playstyle, optional generalPlaystyle)`

System: `LFGList` · Namespace: `C_LFGList`
