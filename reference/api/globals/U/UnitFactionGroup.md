<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# UnitFactionGroup

```lua
factionGroupTag, localized = UnitFactionGroup(unitName, checkDisplayRace)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unitName` | `cstring` | no |  |
| 2 | `checkDisplayRace` | `bool` | no | `False` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `factionGroupTag` | `cstring` | no |  |
| 2 | `localized` | `cstring` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `UnitFactionGroup(unitName, optional checkDisplayRace)`

System: `Unit`
