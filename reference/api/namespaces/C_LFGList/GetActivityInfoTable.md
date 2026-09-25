<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_LFGList.GetActivityInfoTable

```lua
activityInfo = C_LFGList.GetActivityInfoTable(activityID, questID, showWarmode)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `activityID` | `number` | no |  |
| 2 | `questID` | `number` | yes |  |
| 3 | `showWarmode` | `bool` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `activityInfo` | `GroupFinderActivityInfo` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_LFGList.GetActivityInfoTable(activityID, optional questID, optional showWarmode)`

System: `LFGList` · Namespace: `C_LFGList`
