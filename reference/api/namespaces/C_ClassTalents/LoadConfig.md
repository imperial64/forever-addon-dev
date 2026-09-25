<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_ClassTalents.LoadConfig

```lua
result, changeError, newLearnedNodeIDs = C_ClassTalents.LoadConfig(configID, autoApply)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `configID` | `number` | no |  |
| 2 | `autoApply` | `bool` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `result` | `LoadConfigResult` | no |  |
| 2 | `changeError` | `string` | yes |  |
| 3 | `newLearnedNodeIDs` | `table&lt;number&gt;` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_ClassTalents.LoadConfig(configID, autoApply)`

System: `ClassTalents` · Namespace: `C_ClassTalents`
