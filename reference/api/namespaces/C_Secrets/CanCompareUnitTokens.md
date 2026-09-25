<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Secrets.CanCompareUnitTokens

```lua
isUnitComparisonPermitted = C_Secrets.CanCompareUnitTokens(unit1, unit2)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unit1` | `UnitToken` | no |  |
| 2 | `unit2` | `UnitToken` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `isUnitComparisonPermitted` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_Secrets.CanCompareUnitTokens(unit1, unit2)`

System: `SecretUtil` · Namespace: `C_Secrets`
