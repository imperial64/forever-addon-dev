<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_PingSecure.SetHitTestPingTarget

> **RESTRICTED — Blizzard flag.** This function carries `HasRestrictions` in the client's own documentation, meaning it is gated on a hardware event or refuses to run from a script.

```lua
state = C_PingSecure.SetHitTestPingTarget(mousePosX, mousePosY, forcePointPing)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `mousePosX` | `number` | no |  |
| 2 | `mousePosY` | `number` | no |  |
| 3 | `forcePointPing` | `bool` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `state` | `PingSetTargetState` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_PingSecure.SetHitTestPingTarget(mousePosX, mousePosY, optional forcePointPing)`

System: `PingManagerSecure` · Namespace: `C_PingSecure`
