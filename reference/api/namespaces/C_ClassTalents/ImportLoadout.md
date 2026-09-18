<!-- GENERATED from Blizzard_APIDocumentation, client build unknown. Do not edit; edit the generator. -->

# C_ClassTalents.ImportLoadout

```lua
success, importError = C_ClassTalents.ImportLoadout(configID, entries, name, importString)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `configID` | `number` | no |  |
| 2 | `entries` | `table&lt;ImportLoadoutEntryInfo&gt;` | no |  |
| 3 | `name` | `string` | no |  |
| 4 | `importString` | `string` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `success` | `bool` | no |  |
| 2 | `importError` | `cstring` | no |  |

Blizzard's own rendering: `C_ClassTalents.ImportLoadout(configID, entries, name, optional importString)`

System: `ClassTalents` · Namespace: `C_ClassTalents`
