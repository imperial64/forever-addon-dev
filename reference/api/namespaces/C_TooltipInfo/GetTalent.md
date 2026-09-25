<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_TooltipInfo.GetTalent

```lua
data = C_TooltipInfo.GetTalent(talentID, isInspect, groupIndex)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `talentID` | `number` | no |  |
| 2 | `isInspect` | `bool` | yes |  |
| 3 | `groupIndex` | `luaIndex` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `data` | `TooltipData` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_TooltipInfo.GetTalent(talentID, optional isInspect, optional groupIndex)`

System: `TooltipInfo` · Namespace: `C_TooltipInfo`
