<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_ClassTalents.GetHeroTalentSpecsForClassSpec

```lua
subTreeIDs, requiredPlayerLevel = C_ClassTalents.GetHeroTalentSpecsForClassSpec(configID, classSpecID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `configID` | `number` | yes |  |
| 2 | `classSpecID` | `number` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `subTreeIDs` | `table&lt;number&gt;` | yes |  |
| 2 | `requiredPlayerLevel` | `number` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_ClassTalents.GetHeroTalentSpecsForClassSpec(optional configID, optional classSpecID)`

System: `ClassTalents` · Namespace: `C_ClassTalents`
