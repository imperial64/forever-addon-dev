<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# FrameAPICharacterModelBase:SetUnit

```lua
success = FrameAPICharacterModelBase:SetUnit(unit, blend, useNativeForm)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `unit` | `UnitToken` | no |  |
| 2 | `blend` | `bool` | no | `True` |
| 3 | `useNativeForm` | `bool` | yes |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `success` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `RequiresDeclassifiedUnitIdentity` | `true` |
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `SetUnit(unit, optional blend, optional useNativeForm)`

System: `FrameAPICharacterModelBase` · Widget methods
