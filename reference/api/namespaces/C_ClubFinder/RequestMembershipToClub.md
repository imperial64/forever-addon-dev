<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_ClubFinder.RequestMembershipToClub

> **RESTRICTED — Blizzard flag.** This function carries `HasRestrictions` in the client's own documentation, meaning it is gated on a hardware event or refuses to run from a script.

```lua
C_ClubFinder.RequestMembershipToClub(clubFinderGUID, comment, specIDs)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `clubFinderGUID` | `WOWGUID` | no |  |
| 2 | `comment` | `string` | no |  |
| 3 | `specIDs` | `table&lt;number&gt;` | no |  |

**Returns**

_None._

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_ClubFinder.RequestMembershipToClub(clubFinderGUID, comment, specIDs)`

System: `ClubFinderInfo` · Namespace: `C_ClubFinder`
