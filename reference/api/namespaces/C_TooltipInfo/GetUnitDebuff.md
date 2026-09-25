<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_TooltipInfo.GetUnitDebuff

```lua
data = C_TooltipInfo.GetUnitDebuff(unitToken, index, filter)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unitToken` | `UnitTokenRestrictedForAddOns` | no |  |
| 2 | `index` | `luaIndex` | no |  |
| 3 | `filter` | `AuraFilters` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `data` | `TooltipData` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `RequiresUnitAuraAccess` | `true` |
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretWhenUnitAuraRestricted` | `true` |

Blizzard's own rendering: `C_TooltipInfo.GetUnitDebuff(unitToken, index, optional filter)`

System: `TooltipInfo` · Namespace: `C_TooltipInfo`
