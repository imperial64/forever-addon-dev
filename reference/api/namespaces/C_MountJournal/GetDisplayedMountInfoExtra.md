<!-- GENERATED from Blizzard_APIDocumentation, client build unknown. Do not edit; edit the generator. -->

# C_MountJournal.GetDisplayedMountInfoExtra

```lua
creatureDisplayInfoID, description, source, isSelfMount, mountTypeID, uiModelSceneID, animID, spellVisualKitID, disablePlayerMountPreview = C_MountJournal.GetDisplayedMountInfoExtra(mountIndex)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `mountIndex` | `luaIndex` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `creatureDisplayInfoID` | `number` | yes |  |
| 2 | `description` | `cstring` | no |  |
| 3 | `source` | `cstring` | no |  |
| 4 | `isSelfMount` | `bool` | no |  |
| 5 | `mountTypeID` | `number` | no |  |
| 6 | `uiModelSceneID` | `number` | no |  |
| 7 | `animID` | `number` | no |  |
| 8 | `spellVisualKitID` | `number` | no |  |
| 9 | `disablePlayerMountPreview` | `bool` | no |  |

Blizzard's own rendering: `C_MountJournal.GetDisplayedMountInfoExtra(mountIndex)`

System: `MountJournal` · Namespace: `C_MountJournal`
