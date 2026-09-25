<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_PaperDollInfo.GetInventorySlotInfo

```lua
invSlot, slotTexture, checkRelic = C_PaperDollInfo.GetInventorySlotInfo(slotName)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `slotName` | `cstring` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `invSlot` | `number` | no |  |
| 2 | `slotTexture` | `fileID` | no |  |
| 3 | `checkRelic` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_PaperDollInfo.GetInventorySlotInfo(slotName)`

System: `PaperDollInfo` · Namespace: `C_PaperDollInfo`
