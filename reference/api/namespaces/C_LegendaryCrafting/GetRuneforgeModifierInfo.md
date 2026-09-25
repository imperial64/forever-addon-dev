<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

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

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_LegendaryCrafting.GetRuneforgeModifierInfo(baseItem, optional powerID, addedModifierIndex, modifiers)`

System: `LegendaryCrafting` · Namespace: `C_LegendaryCrafting`
