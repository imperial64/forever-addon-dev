<!-- GENERATED from Blizzard_APIDocumentation, client build 70009. Do not edit; edit the generator. -->

# SimpleMovieAPI:StartMovieByName

```lua
success, returnCode = SimpleMovieAPI:StartMovieByName(movieName, looping, resolution)
```

**Arguments**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `movieName` | `cstring` | no |  |
| 2 | `looping` | `bool` | no | `False` |
| 3 | `resolution` | `number` | no | `0` |

**Returns**

| # | Name | Type | Nilable | Default |
|---|---|---|---|---|
| 1 | `success` | `bool` | no |  |
| 2 | `returnCode` | `number` | no |  |

**Secrecy and restriction keys**

Verbatim from Blizzard's documentation for this build, as the client loads it (an `Enum` reference is its number); not interpreted here.

| Applies to | Key | Value |
|---|---|---|
| this function | `SecretArguments` | `"AllowedWhenUntainted"` |

Blizzard's own rendering: `StartMovieByName(movieName, optional looping, optional resolution)`

System: `SimpleMovieAPI` · Widget methods
