<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_UnitAuras.AddPrivateAuraAnchor

> **SECRET — measured, in combat only.** Aura reads RAISE in combat. They do not return nil.
> Measured 2026-09-20 on build 69913. Evidence: §P.18, §P.19 in [findings](../../../../research/findings.md).
> 
> _Workaround:_ Read before the pull and hold the value, or hand a duration object to a Cooldown widget before combat starts and let it keep ticking.

```lua
anchorID = C_UnitAuras.AddPrivateAuraAnchor(args)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `args` | `AddPrivateAuraAnchorArgs` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `anchorID` | `number` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_UnitAuras.AddPrivateAuraAnchor(args)`

System: `UnitAuras` · Namespace: `C_UnitAuras`
