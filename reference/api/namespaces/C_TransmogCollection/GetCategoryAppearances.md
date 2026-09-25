<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_TransmogCollection.GetCategoryAppearances

```lua
appearances = C_TransmogCollection.GetCategoryAppearances(category, transmogLocation, option)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `category` | `TransmogCollectionType` | no |  |
| 2 | `transmogLocation` | `TransmogLocation (TransmogLocationMixin)` | yes |  |
| 3 | `option` | `TransmogOutfitSlotOption` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `appearances` | `table&lt;TransmogCategoryAppearanceInfo&gt;` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_TransmogCollection.GetCategoryAppearances(category, optional transmogLocation, optional option)`

System: `TransmogrifyCollection` · Namespace: `C_TransmogCollection`
