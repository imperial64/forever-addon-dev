<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# C_UnitAuras.GetGroupBuffVisualAlerts

> **SECRET — measured, in combat only.** Aura reads RAISE in combat. They do not return nil.
> Measured 2026-09-20 on build 69913. Evidence: §P.18, §P.19 in [findings](../../../../research/findings.md).
> 
> _Workaround:_ Read before the pull and hold the value, or hand a duration object to a Cooldown widget before combat starts and let it keep ticking.

```lua
visualAlerts = C_UnitAuras.GetGroupBuffVisualAlerts()
```

**Arguments**

_None._

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `visualAlerts` | `table&lt;GroupBuffVisualAlertInfo&gt;` | no |  |

Blizzard's own rendering: `C_UnitAuras.GetGroupBuffVisualAlerts()`

System: `UnitAuras` · Namespace: `C_UnitAuras`
