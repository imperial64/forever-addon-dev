<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_PartyInfo.ConfirmRequestInviteFromUnit

```lua
C_PartyInfo.ConfirmRequestInviteFromUnit(targetName, tank, healer, dps)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `targetName` | `cstring` | no |  |
| 2 | `tank` | `bool` | yes |  |
| 3 | `healer` | `bool` | yes |  |
| 4 | `dps` | `bool` | yes |  |

**Returns**

_None._

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `RequiresValidInviteTarget` | `true` |
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_PartyInfo.ConfirmRequestInviteFromUnit(targetName, optional tank, optional healer, optional dps)`

System: `PartyInfo` · Namespace: `C_PartyInfo`
