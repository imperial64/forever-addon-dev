<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_LootJournal.GetItemSets

```lua
itemSets = C_LootJournal.GetItemSets(classID, specID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `classID` | `number` | yes |  |
| 2 | `specID` | `number` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `itemSets` | `table&lt;LootJournalItemSetInfo&gt;` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_LootJournal.GetItemSets(optional classID, optional specID)`

System: `LootJournal` · Namespace: `C_LootJournal`
