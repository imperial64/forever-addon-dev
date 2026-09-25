<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_ActionBar.GetActionCooldown

```lua
cooldownInfo = C_ActionBar.GetActionCooldown(actionID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `actionID` | `luaIndex` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `cooldownInfo` | `SpellCooldownInfo` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `RequiresValidActionSlot` | `true` |
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretWhenCooldownsRestricted` | `true` |

Blizzard's own rendering: `C_ActionBar.GetActionCooldown(actionID)`

System: `ActionBar` · Namespace: `C_ActionBar`
