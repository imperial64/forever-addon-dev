<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# C_PartyInfo.GetInviteReferralInfo

```lua
outReferredByGuid, outReferredByName, outRelationType, outIsQuickJoin, outClubId = C_PartyInfo.GetInviteReferralInfo(inviteGUID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `inviteGUID` | `WOWGUID` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `outReferredByGuid` | `WOWGUID` | no |  |
| 2 | `outReferredByName` | `cstring` | no |  |
| 3 | `outRelationType` | `PartyRequestJoinRelation` | no |  |
| 4 | `outIsQuickJoin` | `bool` | no |  |
| 5 | `outClubId` | `ClubId` | no |  |

Blizzard's own rendering: `C_PartyInfo.GetInviteReferralInfo(inviteGUID)`

System: `PartyInfo` · Namespace: `C_PartyInfo`
