<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_AuctionHouse.GetItemKeyInfo

```lua
itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(itemKey, restrictQualityToFilter)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `itemKey` | `ItemKey` | no |  |
| 2 | `restrictQualityToFilter` | `bool` | no | `False` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `itemKeyInfo` | `ItemKeyInfo` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_AuctionHouse.GetItemKeyInfo(itemKey, optional restrictQualityToFilter)`

System: `AuctionHouse` · Namespace: `C_AuctionHouse`
