<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_ItemUpgrade.GetItemUpgradeEffect

```lua
outBaseEffect, outUpgradedEffect = C_ItemUpgrade.GetItemUpgradeEffect(effectIndex, numUpgradeLevels)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `effectIndex` | `number` | no |  |
| 2 | `numUpgradeLevels` | `number` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `outBaseEffect` | `string` | no |  |
| 2 | `outUpgradedEffect` | `string` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_ItemUpgrade.GetItemUpgradeEffect(effectIndex, optional numUpgradeLevels)`

System: `ItemUpgrade` · Namespace: `C_ItemUpgrade`
