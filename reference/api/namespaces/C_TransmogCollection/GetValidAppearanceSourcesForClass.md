<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

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

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_TransmogCollection.GetValidAppearanceSourcesForClass(appearanceID, classID, optional categoryType, optional transmogLocation)`

System: `TransmogrifyCollection` · Namespace: `C_TransmogCollection`
