<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_TooltipInfo.GetLFGDungeonShortageReward

```lua
data = C_TooltipInfo.GetLFGDungeonShortageReward(dungeonID, shortageSeverity, lootIndex)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `dungeonID` | `number` | no |  |
| 2 | `shortageSeverity` | `luaIndex` | no |  |
| 3 | `lootIndex` | `luaIndex` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `data` | `TooltipData` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_TooltipInfo.GetLFGDungeonShortageReward(dungeonID, shortageSeverity, lootIndex)`

System: `TooltipInfo` · Namespace: `C_TooltipInfo`
