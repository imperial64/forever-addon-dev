<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_GuildInfo.SetPreferredPlaySettings

```lua
startedSuccessfully = C_GuildInfo.SetPreferredPlaySettings(preferredLocaleID, preferredDatacenterLocalityID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `preferredLocaleID` | `number` | no | `0` |
| 2 | `preferredDatacenterLocalityID` | `number` | no | `0` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `startedSuccessfully` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_GuildInfo.SetPreferredPlaySettings(optional preferredLocaleID, optional preferredDatacenterLocalityID)`

System: `GuildInfo` · Namespace: `C_GuildInfo`
