<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# C_Club.EditStream

> **RESTRICTED — Blizzard flag.** This function carries `HasRestrictions` in the client's own documentation, meaning it is gated on a hardware event or refuses to run from a script.

```lua
C_Club.EditStream(clubId, streamId, name, subject, leadersAndModeratorsOnly)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `clubId` | `ClubId` | no |  |
| 2 | `streamId` | `ClubStreamId` | no |  |
| 3 | `name` | `string` | yes |  |
| 4 | `subject` | `string` | yes |  |
| 5 | `leadersAndModeratorsOnly` | `bool` | yes |  |

**Returns**

_None._

Blizzard's own rendering: `C_Club.EditStream(clubId, streamId, optional name, optional subject, optional leadersAndModeratorsOnly)`

System: `Club` · Namespace: `C_Club`
