<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# C_PlayerInteractionManager.InteractUnit

> **RESTRICTED — Blizzard flag.** This function carries `HasRestrictions` in the client's own documentation, meaning it is gated on a hardware event or refuses to run from a script.

```lua
success = C_PlayerInteractionManager.InteractUnit(unit, exactMatch, looseTargeting)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unit` | `string` | no |  |
| 2 | `exactMatch` | `bool` | no | `False` |
| 3 | `looseTargeting` | `bool` | no | `True` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `success` | `bool` | no |  |

Blizzard's own rendering: `C_PlayerInteractionManager.InteractUnit(unit, optional exactMatch, optional looseTargeting)`

System: `PlayerInteractionManager` · Namespace: `C_PlayerInteractionManager`
