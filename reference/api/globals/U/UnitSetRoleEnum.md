<!-- GENERATED from Blizzard_APIDocumentation, client build unknown. Do not edit; edit the generator. -->

# UnitSetRoleEnum

> **RESTRICTED — Blizzard flag.** This function carries `HasRestrictions` in the client's own documentation, meaning it is gated on a hardware event or refuses to run from a script.

```lua
result = UnitSetRoleEnum(unit, role)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unit` | `UnitToken` | no |  |
| 2 | `role` | `LFGRole` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `result` | `bool` | no |  |

Blizzard's own rendering: `UnitSetRoleEnum(unit, optional role)`

System: `UnitRole`
