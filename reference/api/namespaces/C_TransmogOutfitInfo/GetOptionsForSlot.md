<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_TransmogOutfitInfo.GetOptionsForSlot

```lua
options, artifactOptions = C_TransmogOutfitInfo.GetOptionsForSlot(slot)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `slot` | `TransmogOutfitSlot` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `options` | `table&lt;TransmogOutfitOptionInfo&gt;` | no |  |
| 2 | `artifactOptions` | `table&lt;TransmogOutfitOptionInfo&gt;` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_TransmogOutfitInfo.GetOptionsForSlot(slot)`

System: `TransmogOutfitInfo` · Namespace: `C_TransmogOutfitInfo`
