<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_ActionBar.IsActionInRange

```lua
isInRange = C_ActionBar.IsActionInRange(actionID, target)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `actionID` | `luaIndex` | no |  |
| 2 | `target` | `UnitToken` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `isInRange` | `bool` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `RequiresValidActionSlot` | `true` |
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_ActionBar.IsActionInRange(actionID, optional target)`

System: `ActionBar` · Namespace: `C_ActionBar`
