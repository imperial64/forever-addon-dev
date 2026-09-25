<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_VignetteInfo.GetVignettePosition

```lua
vignettePosition, vignetteFacing = C_VignetteInfo.GetVignettePosition(vignetteGUID, uiMapID)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `vignetteGUID` | `WOWGUID` | no |  |
| 2 | `uiMapID` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `vignettePosition` | `vector2 (Vector2DMixin)` | no |  |
| 2 | `vignetteFacing` | `number` | yes |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_VignetteInfo.GetVignettePosition(vignetteGUID, uiMapID)`

System: `Vignette` · Namespace: `C_VignetteInfo`
