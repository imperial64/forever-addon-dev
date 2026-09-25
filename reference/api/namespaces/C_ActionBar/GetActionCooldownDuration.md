<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_ActionBar.GetActionCooldownDuration

```lua
duration = C_ActionBar.GetActionCooldownDuration(actionID, ignoreGCD)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `actionID` | `luaIndex` | no |  |
| 2 | `ignoreGCD` | `bool` | no | `False` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `duration` | `LuaDurationObject` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `RequiresValidActionSlot` | `true` |
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_ActionBar.GetActionCooldownDuration(actionID, optional ignoreGCD)`

System: `ActionBar` · Namespace: `C_ActionBar`
