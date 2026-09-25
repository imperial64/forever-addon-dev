<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_LFGList.Search

> **RESTRICTED — Blizzard flag.** This function carries `HasRestrictions` in the client's own documentation, meaning it is gated on a hardware event or refuses to run from a script.

```lua
C_LFGList.Search(categoryID, filter, preferredFilters, languageFilter, searchCrossFactionListings, advancedFilter, activityIDsFilter)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `categoryID` | `number` | no |  |
| 2 | `filter` | `number` | no | `0` |
| 3 | `preferredFilters` | `number` | no | `0` |
| 4 | `languageFilter` | `WowLocale` | yes |  |
| 5 | `searchCrossFactionListings` | `bool` | yes | `False` |
| 6 | `advancedFilter` | `AdvancedFilterOptions` | yes |  |
| 7 | `activityIDsFilter` | `table&lt;number&gt;` | yes |  |

**Returns**

_None._

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_LFGList.Search(categoryID, optional filter, optional preferredFilters, optional languageFilter, optional searchCrossFactionListings, optional advancedFilter, optional activityIDsFilter)`

System: `LFGList` · Namespace: `C_LFGList`
