<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_HousingLayout.HasValidConnection

```lua
canPlace = C_HousingLayout.HasValidConnection(roomGUID, componentID, roomId)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `roomGUID` | `WOWGUID` | no |  |
| 2 | `componentID` | `number` | no |  |
| 3 | `roomId` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `canPlace` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_HousingLayout.HasValidConnection(roomGUID, componentID, roomId)`

System: `HousingLayoutUI` · Namespace: `C_HousingLayout`
