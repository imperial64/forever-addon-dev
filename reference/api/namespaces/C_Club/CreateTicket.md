<!-- GENERATED from Blizzard_APIDocumentation, client build unknown. Do not edit; edit the generator. -->

# C_Club.CreateTicket

> **RESTRICTED — Blizzard flag.** This function carries `HasRestrictions` in the client's own documentation, meaning it is gated on a hardware event or refuses to run from a script.

```lua
C_Club.CreateTicket(clubId, allowedRedeemCount, duration, defaultStreamId, isCrossFaction)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `clubId` | `ClubId` | no |  |
| 2 | `allowedRedeemCount` | `number` | yes |  |
| 3 | `duration` | `number` | yes |  |
| 4 | `defaultStreamId` | `ClubStreamId` | yes |  |
| 5 | `isCrossFaction` | `bool` | yes |  |

**Returns**

_None._

Blizzard's own rendering: `C_Club.CreateTicket(clubId, optional allowedRedeemCount, optional duration, optional defaultStreamId, optional isCrossFaction)`

System: `Club` · Namespace: `C_Club`
