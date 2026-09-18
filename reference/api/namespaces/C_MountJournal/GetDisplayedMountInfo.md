<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# C_MountJournal.GetDisplayedMountInfo

```lua
name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected, mountID, isSteadyFlight = C_MountJournal.GetDisplayedMountInfo(displayIndex)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `displayIndex` | `luaIndex` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `name` | `cstring` | no |  |
| 2 | `spellID` | `number` | no |  |
| 3 | `icon` | `fileID` | no |  |
| 4 | `isActive` | `bool` | no |  |
| 5 | `isUsable` | `bool` | no |  |
| 6 | `sourceType` | `number` | no |  |
| 7 | `isFavorite` | `bool` | no |  |
| 8 | `isFactionSpecific` | `bool` | no |  |
| 9 | `faction` | `PvPFaction` | yes |  |
| 10 | `shouldHideOnChar` | `bool` | no |  |
| 11 | `isCollected` | `bool` | no |  |
| 12 | `mountID` | `number` | no |  |
| 13 | `isSteadyFlight` | `bool` | no |  |

Blizzard's own rendering: `C_MountJournal.GetDisplayedMountInfo(displayIndex)`

System: `MountJournal` · Namespace: `C_MountJournal`
