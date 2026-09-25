<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# UnitName

```lua
unitName, unitServer = UnitName(unit)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unit` | `UnitToken` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unitName` | `cstring` | no |  |
| 2 | `unitServer` | `cstring` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenTainted"` |
| this function | `SecretWhenUnitNameIdentityRestricted` | `true` |

Blizzard's own rendering: `UnitName(unit)`

System: `Unit`
