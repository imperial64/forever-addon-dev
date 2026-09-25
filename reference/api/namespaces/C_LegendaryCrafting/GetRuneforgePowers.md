<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_LegendaryCrafting.GetRuneforgePowers

```lua
primaryRuneforgePowerIDs, otherRuneforgePowerIDs = C_LegendaryCrafting.GetRuneforgePowers(baseItem, filter)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `baseItem` | `ItemLocation (ItemLocationMixin)` | yes |  |
| 2 | `filter` | `RuneforgePowerFilter` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `primaryRuneforgePowerIDs` | `table&lt;number&gt;` | no |  |
| 2 | `otherRuneforgePowerIDs` | `table&lt;number&gt;` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_LegendaryCrafting.GetRuneforgePowers(optional baseItem, optional filter)`

System: `LegendaryCrafting` · Namespace: `C_LegendaryCrafting`
