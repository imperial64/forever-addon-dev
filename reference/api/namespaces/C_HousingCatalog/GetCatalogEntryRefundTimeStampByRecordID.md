<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_HousingCatalog.GetCatalogEntryRefundTimeStampByRecordID

```lua
refundTimeStamp = C_HousingCatalog.GetCatalogEntryRefundTimeStampByRecordID(entryType, recordID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `entryType` | `HousingCatalogEntryType` | no |  |
| 2 | `recordID` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `refundTimeStamp` | `time_t` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_HousingCatalog.GetCatalogEntryRefundTimeStampByRecordID(entryType, recordID)`

System: `HousingCatalogUI` · Namespace: `C_HousingCatalog`
