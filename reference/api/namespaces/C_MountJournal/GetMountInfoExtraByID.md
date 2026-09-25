<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_MountJournal.GetMountInfoExtraByID

```lua
creatureDisplayInfoID, description, source, isSelfMount, mountTypeID, uiModelSceneID, animID, spellVisualKitID, disablePlayerMountPreview = C_MountJournal.GetMountInfoExtraByID(mountID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `mountID` | `number` | no |  |

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

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_MountJournal.GetMountInfoExtraByID(mountID)`

System: `MountJournal` · Namespace: `C_MountJournal`
