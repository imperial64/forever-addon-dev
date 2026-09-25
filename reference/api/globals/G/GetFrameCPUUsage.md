<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# GetFrameCPUUsage

```lua
call_time, call_count = GetFrameCPUUsage(frame, includeChildren)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `frame` | `SimpleFrame` | no |  |
| 2 | `includeChildren` | `bool` | no | `False` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `call_time` | `number` | no |  |
| 2 | `call_count` | `number` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `GetFrameCPUUsage(frame, optional includeChildren)`

System: `PerformanceScript`
