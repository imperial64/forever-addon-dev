<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_AuctionHouse.MakeItemKey

```lua
itemKey = C_AuctionHouse.MakeItemKey(itemID, itemLevel, itemSuffix, battlePetSpeciesID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `itemID` | `number` | no |  |
| 2 | `itemLevel` | `number` | no | `0` |
| 3 | `itemSuffix` | `number` | no | `0` |
| 4 | `battlePetSpeciesID` | `number` | no | `0` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `itemKey` | `ItemKey` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_AuctionHouse.MakeItemKey(itemID, optional itemLevel, optional itemSuffix, optional battlePetSpeciesID)`

System: `AuctionHouse` · Namespace: `C_AuctionHouse`
