<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# C_SocialQueue.GetAllGroups

```lua
groupGUIDs = C_SocialQueue.GetAllGroups(allowNonJoinable, allowNonQueuedGroups)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `allowNonJoinable` | `bool` | no | `False` |
| 2 | `allowNonQueuedGroups` | `bool` | no | `False` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `groupGUIDs` | `table&lt;WOWGUID&gt;` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `C_SocialQueue.GetAllGroups(optional allowNonJoinable, optional allowNonQueuedGroups)`

System: `SocialQueue` · Namespace: `C_SocialQueue`
