<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# GetMovieDownloadProgress

```lua
inProgress, downloaded, total = GetMovieDownloadProgress(movieId)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `movieId` | `number` | no |  |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `inProgress` | `bool` | no |  |
| 2 | `downloaded` | `BigUInteger` | no |  |
| 3 | `total` | `BigUInteger` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `GetMovieDownloadProgress(movieId)`

System: `Movie`
