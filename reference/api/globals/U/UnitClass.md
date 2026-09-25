<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# UnitClass

```lua
className, classFilename, classID = UnitClass(unit)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unit` | `UnitToken` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `className` | `cstring` | no |  |
| 2 | `classFilename` | `cstring` | no |  |
| 3 | `classID` | `number` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretWhenUnitIdentityRestricted` | `true` |
| return `className` | `ConditionalSecret` | `true` |

Blizzard's own rendering: `UnitClass(unit)`

System: `Unit`
