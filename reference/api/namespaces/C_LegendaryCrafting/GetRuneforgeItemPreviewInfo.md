<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_LegendaryCrafting.GetRuneforgeItemPreviewInfo

```lua
info = C_LegendaryCrafting.GetRuneforgeItemPreviewInfo(baseItem, runeforgePowerID, modifiers)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `baseItem` | `ItemLocation (ItemLocationMixin)` | no |  |
| 2 | `runeforgePowerID` | `number` | yes |  |
| 3 | `modifiers` | `table&lt;number&gt;` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `info` | `RuneforgeItemPreviewInfo` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_LegendaryCrafting.GetRuneforgeItemPreviewInfo(baseItem, optional runeforgePowerID, optional modifiers)`

System: `LegendaryCrafting` · Namespace: `C_LegendaryCrafting`
