<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# PVPScoreInfo

_Structure_

**Fields**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `name` | `string` | no |  |
| 2 | `guid` | `WOWGUID` | no |  |
| 3 | `killingBlows` | `number` | no |  |
| 4 | `honorableKills` | `number` | no |  |
| 5 | `deaths` | `number` | no |  |
| 6 | `honorGained` | `number` | no |  |
| 7 | `faction` | `number` | no |  |
| 8 | `raceName` | `string` | no |  |
| 9 | `className` | `string` | no |  |
| 10 | `classToken` | `string` | no |  |
| 11 | `damageDone` | `number` | no |  |
| 12 | `healingDone` | `number` | no |  |
| 13 | `rating` | `number` | no |  |
| 14 | `ratingChange` | `number` | no |  |
| 15 | `prematchMMR` | `number` | no |  |
| 16 | `mmrChange` | `number` | no |  |
| 17 | `postmatchMMR` | `number` | no |  |
| 18 | `talentSpec` | `string` | no |  |
| 19 | `honorLevel` | `number` | no |  |
| 20 | `roleAssigned` | `number` | no |  |
| 21 | `stats` | `table&lt;PVPStatInfo&gt;` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| field `name` | `NeverSecret` | `true` |
| field `faction` | `NeverSecret` | `true` |
| field `raceName` | `NeverSecret` | `true` |
| field `className` | `NeverSecret` | `true` |
| field `classToken` | `NeverSecret` | `true` |

System: `PvpInfo`
