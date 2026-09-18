<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# C_PingSecure.SendUnitPing

> **RESTRICTED — Blizzard flag.** This function carries `HasRestrictions` in the client's own documentation, meaning it is gated on a hardware event or refuses to run from a script.

```lua
result = C_PingSecure.SendUnitPing(target, type, isPlayerResource)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `target` | `WOWGUID` | no |  |
| 2 | `type` | `PingSubjectType` | yes |  |
| 3 | `isPlayerResource` | `bool` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `result` | `SendPingResult` | no |  |

Blizzard's own rendering: `C_PingSecure.SendUnitPing(target, optional type, optional isPlayerResource)`

System: `PingManagerSecure` · Namespace: `C_PingSecure`
