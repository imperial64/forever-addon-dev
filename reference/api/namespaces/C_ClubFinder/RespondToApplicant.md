<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_ClubFinder.RespondToApplicant

> **RESTRICTED — Blizzard flag.** This function carries `HasRestrictions` in the client's own documentation, meaning it is gated on a hardware event or refuses to run from a script.

```lua
C_ClubFinder.RespondToApplicant(clubFinderGUID, playerGUID, shouldAccept, requestType, playerName, forceAccept, reported)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `clubFinderGUID` | `WOWGUID` | no |  |
| 2 | `playerGUID` | `WOWGUID` | no |  |
| 3 | `shouldAccept` | `bool` | no |  |
| 4 | `requestType` | `ClubFinderRequestType` | no |  |
| 5 | `playerName` | `string` | no |  |
| 6 | `forceAccept` | `bool` | no |  |
| 7 | `reported` | `bool` | yes |  |

**Returns**

_None._

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_ClubFinder.RespondToApplicant(clubFinderGUID, playerGUID, shouldAccept, requestType, playerName, forceAccept, optional reported)`

System: `ClubFinderInfo` · Namespace: `C_ClubFinder`
