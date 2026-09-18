<!-- GENERATED from Blizzard_APIDocumentation, client build 69913. Do not edit; edit the generator. -->

# C_Garrison.GetTalentTreeTalentPointResearchInfo

```lua
goldCost, currencyCosts, durationSecs = C_Garrison.GetTalentTreeTalentPointResearchInfo(garrTalentID, researchRank, garrTalentTreeID, talentPointIndex, isRespec)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `garrTalentID` | `number` | no |  |
| 2 | `researchRank` | `number` | no |  |
| 3 | `garrTalentTreeID` | `number` | no |  |
| 4 | `talentPointIndex` | `number` | no |  |
| 5 | `isRespec` | `bool` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `goldCost` | `number` | no |  |
| 2 | `currencyCosts` | `table&lt;GarrisonTalentCurrencyCostInfo&gt;` | no |  |
| 3 | `durationSecs` | `number` | no |  |

Blizzard's own rendering: `C_Garrison.GetTalentTreeTalentPointResearchInfo(garrTalentID, researchRank, garrTalentTreeID, talentPointIndex, isRespec)`

System: `GarrisonInfo` · Namespace: `C_Garrison`
