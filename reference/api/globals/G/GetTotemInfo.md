<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# GetTotemInfo

```lua
haveTotem, totemName, startTime, duration, icon, modRate, spellID = GetTotemInfo(slot)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `slot` | `luaIndex` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `haveTotem` | `bool` | no |  |
| 2 | `totemName` | `cstring` | no |  |
| 3 | `startTime` | `number` | no |  |
| 4 | `duration` | `number` | no |  |
| 5 | `icon` | `fileID` | no |  |
| 6 | `modRate` | `number` | no |  |
| 7 | `spellID` | `number` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretWhenTotemSlotSecret` | `true` |

Blizzard's own rendering: `GetTotemInfo(slot)`

System: `Totem`
