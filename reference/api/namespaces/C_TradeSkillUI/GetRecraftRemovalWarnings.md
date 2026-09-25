<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_TradeSkillUI.GetRecraftRemovalWarnings

```lua
warnings = C_TradeSkillUI.GetRecraftRemovalWarnings(itemGUID, replacedReagents)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `itemGUID` | `WOWGUID` | no |  |
| 2 | `replacedReagents` | `table&lt;CraftingReagent&gt;` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `warnings` | `table&lt;cstring&gt;` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_TradeSkillUI.GetRecraftRemovalWarnings(itemGUID, replacedReagents)`

System: `TradeSkillUI` · Namespace: `C_TradeSkillUI`
