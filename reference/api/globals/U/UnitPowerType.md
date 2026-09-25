<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# UnitPowerType

```lua
powerType, powerTypeToken, rgbX, rgbY, rgbZ = UnitPowerType(unit, index)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unit` | `UnitTokenPvPRestrictedForAddOns` | no |  |
| 2 | `index` | `number` | no | `0` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `powerType` | `PowerType` | no |  |
| 2 | `powerTypeToken` | `string` | no |  |
| 3 | `rgbX` | `number` | no |  |
| 4 | `rgbY` | `number` | no |  |
| 5 | `rgbZ` | `number` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `UnitPowerType(unit, optional index)`

System: `Unit`
