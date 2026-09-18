<!-- GENERATED from Blizzard_APIDocumentation, client build unknown. Do not edit; edit the generator. -->

# C_LegendaryCrafting.GetRuneforgeModifierInfo

```lua
name, description = C_LegendaryCrafting.GetRuneforgeModifierInfo(baseItem, powerID, addedModifierIndex, modifiers)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `baseItem` | `ItemLocation (ItemLocationMixin)` | no |  |
| 2 | `powerID` | `number` | yes |  |
| 3 | `addedModifierIndex` | `luaIndex` | no |  |
| 4 | `modifiers` | `table&lt;number&gt;` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `name` | `string` | no |  |
| 2 | `description` | `table&lt;string&gt;` | no |  |

Blizzard's own rendering: `C_LegendaryCrafting.GetRuneforgeModifierInfo(baseItem, optional powerID, addedModifierIndex, modifiers)`

System: `LegendaryCrafting` · Namespace: `C_LegendaryCrafting`
