<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_SocialQueue.RequestToJoin

```lua
requestSuccessful = C_SocialQueue.RequestToJoin(groupGUID, applyAsTank, applyAsHealer, applyAsDamage)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `groupGUID` | `WOWGUID` | no |  |
| 2 | `applyAsTank` | `bool` | no | `False` |
| 3 | `applyAsHealer` | `bool` | no | `False` |
| 4 | `applyAsDamage` | `bool` | no | `False` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `requestSuccessful` | `bool` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_SocialQueue.RequestToJoin(groupGUID, optional applyAsTank, optional applyAsHealer, optional applyAsDamage)`

System: `SocialQueue` · Namespace: `C_SocialQueue`
