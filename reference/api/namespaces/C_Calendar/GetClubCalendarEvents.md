<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Calendar.GetClubCalendarEvents

```lua
events = C_Calendar.GetClubCalendarEvents(clubId, startTime, endTime)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `clubId` | `ClubId` | no |  |
| 2 | `startTime` | `CalendarTime` | no |  |
| 3 | `endTime` | `CalendarTime` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `events` | `table&lt;CalendarDayEvent&gt;` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |
| this function | `SecretInChatMessagingLockdown` | `true` |

Blizzard's own rendering: `C_Calendar.GetClubCalendarEvents(clubId, startTime, endTime)`

System: `Calendar` · Namespace: `C_Calendar`
