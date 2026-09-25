<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Commentator.GetTrackedSpellsByUnit

```lua
spells, result = C_Commentator.GetTrackedSpellsByUnit(unitToken, category)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unitToken` | `UnitToken` | no |  |
| 2 | `category` | `TrackedSpellCategory` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `spells` | `table&lt;number&gt;` | yes |  |
| 2 | `result` | `TrackedSpellsResult` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `RequiresActiveCommentator` | `true` |
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_Commentator.GetTrackedSpellsByUnit(unitToken, category)`

System: `CommentatorFrame` · Namespace: `C_Commentator`
