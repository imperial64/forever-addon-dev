<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# LuaDurationObjectAPI:FormatElapsedDuration

```lua
formatted = LuaDurationObjectAPI:FormatElapsedDuration(formatter, modifier)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `formatter` | `NumericFormatter` | no |  |
| 2 | `modifier` | `DurationTimeModifier` | no | `RealTime` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `formatted` | `string` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretWhenNumericFormatterSecret` | `true` |

Blizzard's own rendering: `FormatElapsedDuration(formatter, optional modifier)`

System: `LuaDurationObjectAPI` · Widget methods
