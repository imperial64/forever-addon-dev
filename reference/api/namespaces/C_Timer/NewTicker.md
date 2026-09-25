<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Timer.NewTicker

```lua
cbObject = C_Timer.NewTicker(seconds, callback, iterations)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `seconds` | `number` | no |  |
| 2 | `callback` | `TickerCallback` | no |  |
| 3 | `iterations` | `number` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `cbObject` | `TickerCallback` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_Timer.NewTicker(seconds, callback, optional iterations)`

System: `UITimer` · Namespace: `C_Timer`
