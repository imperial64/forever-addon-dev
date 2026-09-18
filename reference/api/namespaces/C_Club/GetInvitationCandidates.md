<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# C_Club.GetInvitationCandidates

```lua
candidates = C_Club.GetInvitationCandidates(filter, maxResults, cursorPosition, allowFullMatch, clubId)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `filter` | `string` | yes |  |
| 2 | `maxResults` | `number` | yes |  |
| 3 | `cursorPosition` | `number` | yes |  |
| 4 | `allowFullMatch` | `bool` | yes |  |
| 5 | `clubId` | `ClubId` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `candidates` | `table&lt;ClubInvitationCandidateInfo&gt;` | no |  |

Blizzard's own rendering: `C_Club.GetInvitationCandidates(optional filter, optional maxResults, optional cursorPosition, optional allowFullMatch, clubId)`

System: `Club` · Namespace: `C_Club`
