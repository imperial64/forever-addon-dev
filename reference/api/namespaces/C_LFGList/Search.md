<!-- GENERATED from Blizzard_APIDocumentation, client build unknown. Do not edit; edit the generator. -->

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

Blizzard's own rendering: `C_LFGList.Search(categoryID, optional filter, optional preferredFilters, optional languageFilter, optional searchCrossFactionListings, optional advancedFilter, optional activityIDsFilter)`

System: `LFGList` · Namespace: `C_LFGList`
