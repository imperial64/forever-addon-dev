<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_MythicPlus.GetRunHistory

```lua
runs = C_MythicPlus.GetRunHistory(includePreviousWeeks, includeIncompleteRuns, currentSeasonOnly)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `includePreviousWeeks` | `bool` | no | `False` |
| 2 | `includeIncompleteRuns` | `bool` | no | `False` |
| 3 | `currentSeasonOnly` | `bool` | no | `False` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `runs` | `table&lt;MythicPlusRunInfo&gt;` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_MythicPlus.GetRunHistory(optional includePreviousWeeks, optional includeIncompleteRuns, optional currentSeasonOnly)`

System: `MythicPlusInfo` · Namespace: `C_MythicPlus`
