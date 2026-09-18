<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# C_TransmogCollection.GetValidAppearanceSourcesForClass

```lua
sources = C_TransmogCollection.GetValidAppearanceSourcesForClass(appearanceID, classID, categoryType, transmogLocation)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `appearanceID` | `number` | no |  |
| 2 | `classID` | `number` | no |  |
| 3 | `categoryType` | `TransmogCollectionType` | yes |  |
| 4 | `transmogLocation` | `TransmogLocation (TransmogLocationMixin)` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `sources` | `table&lt;AppearanceSourceInfo&gt;` | no |  |

Blizzard's own rendering: `C_TransmogCollection.GetValidAppearanceSourcesForClass(appearanceID, classID, optional categoryType, optional transmogLocation)`

System: `TransmogrifyCollection` · Namespace: `C_TransmogCollection`
