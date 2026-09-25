<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Container.UseContainerItem

```lua
C_Container.UseContainerItem(containerIndex, slotIndex, unitToken, bankType, reagentBankOpen)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `containerIndex` | `BagIndex` | no |  |
| 2 | `slotIndex` | `luaIndex` | no |  |
| 3 | `unitToken` | `UnitToken` | yes |  |
| 4 | `bankType` | `BankType` | yes |  |
| 5 | `reagentBankOpen` | `bool` | no | `False` |

**Returns**

_None._

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_Container.UseContainerItem(containerIndex, slotIndex, optional unitToken, optional bankType, optional reagentBankOpen)`

System: `Container` · Namespace: `C_Container`
