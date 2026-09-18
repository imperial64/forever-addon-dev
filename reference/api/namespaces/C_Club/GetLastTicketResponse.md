<!-- GENERATED from Blizzard_APIDocumentation, client build unknown. Do not edit; edit the generator. -->

# C_Club.GetLastTicketResponse

> **RESTRICTED — Blizzard flag.** This function carries `HasRestrictions` in the client's own documentation, meaning it is gated on a hardware event or refuses to run from a script.

```lua
error, info, showError = C_Club.GetLastTicketResponse(ticket)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `ticket` | `string` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `error` | `ClubErrorType` | no |  |
| 2 | `info` | `ClubInfo` | yes |  |
| 3 | `showError` | `bool` | no |  |

Blizzard's own rendering: `C_Club.GetLastTicketResponse(ticket)`

System: `Club` · Namespace: `C_Club`
