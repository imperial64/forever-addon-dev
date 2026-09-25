<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_CombatLogSecure.CreateCombatLogMessage

> **RESTRICTED — Blizzard flag.** This function carries `HasRestrictions` in the client's own documentation, meaning it is gated on a hardware event or refuses to run from a script.

```lua
C_CombatLogSecure.CreateCombatLogMessage(message, colorR, colorG, colorB, order)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `message` | `string` | no |  |
| 2 | `colorR` | `number` | no |  |
| 3 | `colorG` | `number` | no |  |
| 4 | `colorB` | `number` | no |  |
| 5 | `order` | `CombatLogMessageOrder` | no |  |

**Returns**

_None._

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_CombatLogSecure.CreateCombatLogMessage(message, colorR, colorG, colorB, order)`

System: `CombatLogSecure` · Namespace: `C_CombatLogSecure`
