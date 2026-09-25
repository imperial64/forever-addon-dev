<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# CANCEL_PLAYER_COUNTDOWN

**Payload**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `initiatedBy` | `WOWGUID` | no |  |
| 2 | `informChat` | `bool` | no |  |
| 3 | `initiatedByName` | `string` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this event | `SecretInChatMessagingLockdown` | `true` |

System: `WorldStateInfo`
