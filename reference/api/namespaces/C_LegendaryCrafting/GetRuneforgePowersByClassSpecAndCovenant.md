<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_LegendaryCrafting.GetRuneforgePowersByClassSpecAndCovenant

```lua
runeforgePowerIDs = C_LegendaryCrafting.GetRuneforgePowersByClassSpecAndCovenant(classID, specID, covenantID, filter)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `classID` | `number` | yes |  |
| 2 | `specID` | `number` | yes |  |
| 3 | `covenantID` | `number` | yes |  |
| 4 | `filter` | `RuneforgePowerFilter` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `runeforgePowerIDs` | `table&lt;number&gt;` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_LegendaryCrafting.GetRuneforgePowersByClassSpecAndCovenant(optional classID, optional specID, optional covenantID, optional filter)`

System: `LegendaryCrafting` · Namespace: `C_LegendaryCrafting`
