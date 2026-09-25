<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Map.GetMapLevels

```lua
playerMinLevel, playerMaxLevel, petMinLevel, petMaxLevel = C_Map.GetMapLevels(uiMapID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `uiMapID` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `playerMinLevel` | `number` | no |  |
| 2 | `playerMaxLevel` | `number` | no |  |
| 3 | `petMinLevel` | `number` | no | `0` |
| 4 | `petMaxLevel` | `number` | no | `0` |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_Map.GetMapLevels(uiMapID)`

System: `MapUI` · Namespace: `C_Map`
