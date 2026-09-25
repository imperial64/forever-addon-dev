<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_Bank.UpdateBankTabSettings

```lua
C_Bank.UpdateBankTabSettings(bankType, tabID, tabName, tabIcon, depositFlags)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `bankType` | `BankType` | no |  |
| 2 | `tabID` | `BagIndex` | no |  |
| 3 | `tabName` | `cstring` | no |  |
| 4 | `tabIcon` | `cstring` | no |  |
| 5 | `depositFlags` | `BagSlotFlags` | no |  |

**Returns**

_None._

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_Bank.UpdateBankTabSettings(bankType, tabID, tabName, tabIcon, depositFlags)`

System: `Bank` · Namespace: `C_Bank`
