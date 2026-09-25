<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Secrets.ShouldUnitAuraInstanceBeSecret

```lua
isAuraSecret = C_Secrets.ShouldUnitAuraInstanceBeSecret(unit, auraInstanceID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unit` | `UnitToken` | no |  |
| 2 | `auraInstanceID` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `isAuraSecret` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_Secrets.ShouldUnitAuraInstanceBeSecret(unit, auraInstanceID)`

System: `SecretUtil` · Namespace: `C_Secrets`
