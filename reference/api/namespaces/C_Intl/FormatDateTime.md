<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Intl.FormatDateTime

```lua
result = C_Intl.FormatDateTime(unixTimeSeconds, dateStyle, timeStyle, timeZone)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unixTimeSeconds` | `number` | no |  |
| 2 | `dateStyle` | `DateTimeStyle` | no |  |
| 3 | `timeStyle` | `DateTimeStyle` | no |  |
| 4 | `timeZone` | `cstring` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `result` | `string` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenTainted"` |

Blizzard's own rendering: `C_Intl.FormatDateTime(unixTimeSeconds, dateStyle, timeStyle, timeZone)`

System: `Intl` · Namespace: `C_Intl`
