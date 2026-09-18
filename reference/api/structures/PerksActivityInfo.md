<!-- GENERATED from Blizzard_APIDocumentation, client build unknown. Do not edit; edit the generator. -->

# PerksActivityInfo

_Structure_

**Fields**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `ID` | `number` | no |  |
| 2 | `activityName` | `cstring` | no |  |
| 3 | `description` | `string` | no |  |
| 4 | `thresholdContributionAmount` | `number` | no |  |
| 5 | `completed` | `bool` | no |  |
| 6 | `inProgress` | `bool` | no |  |
| 7 | `tracked` | `bool` | no |  |
| 8 | `supersedes` | `number` | no |  |
| 9 | `uiPriority` | `number` | no |  |
| 10 | `areAllConditionsMet` | `bool` | no |  |
| 11 | `conditions` | `table&lt;PerksActivityCondition&gt;` | no |  |
| 12 | `eventName` | `cstring` | yes |  |
| 13 | `eventStartTime` | `time_t` | yes |  |
| 14 | `eventEndTime` | `time_t` | yes |  |
| 15 | `requirementsList` | `table&lt;CriteriaRequirement&gt;` | no |  |
| 16 | `criteriaList` | `table&lt;CriteriaRequiredValue&gt;` | no |  |
| 17 | `tagNames` | `table&lt;string&gt;` | no |  |

System: `PerksActivities`
