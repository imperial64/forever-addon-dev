<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# C_Club.CreateClub

> **RESTRICTED — Blizzard flag.** This function carries `HasRestrictions` in the client's own documentation, meaning it is gated on a hardware event or refuses to run from a script.

```lua
C_Club.CreateClub(name, shortName, description, clubType, avatarId, isCrossFaction)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `name` | `string` | no |  |
| 2 | `shortName` | `string` | yes |  |
| 3 | `description` | `string` | no |  |
| 4 | `clubType` | `ClubType` | no |  |
| 5 | `avatarId` | `number` | no |  |
| 6 | `isCrossFaction` | `bool` | yes |  |

**Returns**

_None._

Blizzard's own rendering: `C_Club.CreateClub(name, optional shortName, description, clubType, avatarId, optional isCrossFaction)`

System: `Club` · Namespace: `C_Club`
