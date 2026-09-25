<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_ClubFinder.PostClub

> **RESTRICTED — Blizzard flag.** This function carries `HasRestrictions` in the client's own documentation, meaning it is gated on a hardware event or refuses to run from a script.

```lua
succesful = C_ClubFinder.PostClub(clubId, itemLevelRequirement, name, description, avatarId, specs, type, crossFaction)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `clubId` | `ClubId` | no |  |
| 2 | `itemLevelRequirement` | `number` | no |  |
| 3 | `name` | `string` | no |  |
| 4 | `description` | `string` | no |  |
| 5 | `avatarId` | `number` | no |  |
| 6 | `specs` | `table&lt;number&gt;` | no |  |
| 7 | `type` | `ClubFinderRequestType` | no |  |
| 8 | `crossFaction` | `bool` | no | `False` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `succesful` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_ClubFinder.PostClub(clubId, itemLevelRequirement, name, description, avatarId, specs, type, optional crossFaction)`

System: `ClubFinderInfo` · Namespace: `C_ClubFinder`
