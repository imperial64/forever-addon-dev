<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# UnitPartialPower

```lua
partialPower = UnitPartialPower(unitToken, powerType, unmodified)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unitToken` | `UnitTokenPvPRestrictedForAddOns` | no |  |
| 2 | `powerType` | `PowerType` | yes |  |
| 3 | `unmodified` | `bool` | no | `False` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `partialPower` | `number` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretWhenUnitPowerRestricted` | `true` |

Blizzard's own rendering: `UnitPartialPower(unitToken, optional powerType, optional unmodified)`

System: `Unit`
