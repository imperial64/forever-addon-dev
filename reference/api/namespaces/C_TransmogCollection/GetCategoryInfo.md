<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_TransmogCollection.GetCategoryInfo

```lua
name, isWeapon, canHaveIllusions, canMainHand, canOffHand, canRanged = C_TransmogCollection.GetCategoryInfo(category)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `category` | `TransmogCollectionType` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `name` | `cstring` | no |  |
| 2 | `isWeapon` | `bool` | no | `False` |
| 3 | `canHaveIllusions` | `bool` | no | `False` |
| 4 | `canMainHand` | `bool` | no | `False` |
| 5 | `canOffHand` | `bool` | no | `False` |
| 6 | `canRanged` | `bool` | no | `False` |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_TransmogCollection.GetCategoryInfo(category)`

System: `TransmogrifyCollection` · Namespace: `C_TransmogCollection`
