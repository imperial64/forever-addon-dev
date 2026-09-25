<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_SpellDiminish.ShouldTrackSpellDiminishCategory

```lua
isTracked = C_SpellDiminish.ShouldTrackSpellDiminishCategory(category, ruleset)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `category` | `SpellDiminishCategory` | no |  |
| 2 | `ruleset` | `SpellDiminishRuleset` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `isTracked` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `RequiresSpellDiminishUI` | `true` |
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretReturns` | `true` |

Blizzard's own rendering: `C_SpellDiminish.ShouldTrackSpellDiminishCategory(category, ruleset)`

System: `SpellDiminishUI` · Namespace: `C_SpellDiminish`
