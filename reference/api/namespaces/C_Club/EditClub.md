<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# C_Club.EditClub

> **RESTRICTED — Blizzard flag.** This function carries `HasRestrictions` in the client's own documentation, meaning it is gated on a hardware event or refuses to run from a script.

```lua
C_Club.EditClub(clubId, name, shortName, description, avatarId, broadcast, crossFaction)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `clubId` | `ClubId` | no |  |
| 2 | `name` | `string` | yes |  |
| 3 | `shortName` | `string` | yes |  |
| 4 | `description` | `string` | yes |  |
| 5 | `avatarId` | `number` | yes |  |
| 6 | `broadcast` | `string` | yes |  |
| 7 | `crossFaction` | `bool` | yes |  |

**Returns**

_None._

Blizzard's own rendering: `C_Club.EditClub(clubId, optional name, optional shortName, optional description, optional avatarId, optional broadcast, optional crossFaction)`

System: `Club` · Namespace: `C_Club`
