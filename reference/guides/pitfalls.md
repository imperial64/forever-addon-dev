# Six things that will bite you

Each of these cost real debugging time against a live client. They are in the order you are
likely to hit them.

## 1. An unknown event aborts the whole file

`RegisterEvent` on an event this client does not have **raises**. An error in an addon's
main chunk stops the rest of that file loading, so a single stale event name silently
removes every command your addon defines — and the addon looks like it simply is not
installed.

```lua
local function safeRegister(frame, event)
    return (pcall(frame.RegisterEvent, frame, event))
end
```

This is **not** the same as a *forbidden* registration, which does not raise at all. See
`restrictions/combat-log.md`.

## 2. `tostring()` does not launder a secret

A secret value converted with `tostring()` returns a **secret string**. The taint survives
conversion. So a `pcall` around the read reports success, and the value detonates later —
wherever that string is next indexed, usually in a print or a `format`, far from the read.

A secret string written into SavedVariables takes the **entire flush** with it, so an addon
can lose all of its saved data to one unguarded read.

```lua
local function plain(v)
    if issecretvalue and issecretvalue(v) then return "<SECRET>" end
    local ok, str = pcall(tostring, v)
    if not ok then return "<UNPRINTABLE>" end
    if issecretvalue and issecretvalue(str) then return "<SECRET>" end
    local okCut, cut = pcall(string.sub, str, 1, 200)
    return okCut and cut or "<SECRET>"
end
```

Full detail: `restrictions/secret-values.md`.

## 3. SavedVariables are written but never read back

On this build the client writes your saved file on logout or `/reload` and **never loads
it**. Your addon starts from defaults every launch.

This is reported as a beta bug rather than a policy decision, but you have to design around
it today. See `guides/savedvariables.md`.

## 4. `ReloadUI()` is protected

An addon cannot reload the UI. A human types `/reload`. Any refresh loop needs a person in
it; there is no unattended version.

## 5. The version-check trap

Almost every Retail addon contains some form of:

```lua
if select(4, GetBuildInfo()) >= 100000 then  -- "modern client"
```

Forever answers **16001**, so that test is false and the addon takes its Classic code path
or refuses to start — while running on a client whose API is Retail's. If you are porting
something, find this idiom first. The linter flags it.

## 6. A CVar's value does not tell you whether it is in effect

The slider value and the enable flag are **separate CVars**. Measured with the client
running uncapped at 273.7 fps:

```
maxFPS    = 120      useMaxFPS    = 0
targetFPS = 60       useTargetFPS = 0
```

`maxFPS` keeps the last slider position whether or not the limit is applied, so an addon
reading it alone concludes the client is capped at 120 while it is running at more than
twice that — and nothing errors, because nothing failed. `HDRBrightness`/`useHDRBrightness`
pairs the same way.

Two known instances is a pattern to check for, not a proven rule: read the paired
`use<Name>` with `GetCVarBool` before trusting a value, and use `ConsoleGetAllCommands()` to
find out whether a flag exists rather than assuming one does. See `research/findings.md`
§Q.1.

## Three shapes of failure

When something does not work, it failed in one of three ways, and only the first is
obvious:

| Shape | Looks like | Example |
|---|---|---|
| **Raises** | A Lua error you can see | aura reads in combat |
| **Returns a secret** | A normal-looking value that explodes later | `UnitPower` |
| **Returns nil or nothing** | Success with no data | cast info, a throttled auction scan |

A throttled `C_AuctionHouse.ReplicateItems` is the nastiest case: it returns true, fires no
event, and reports zero auctions — indistinguishable from an auction house with nothing on
it.

## When an addon "does nothing"

1. Is it enabled at the character screen? New addons are not enabled by default.
2. Did the main chunk abort? An unknown event registration is the usual cause, and it is
   silent.
3. Did a call get refused? Forbidden actions fire `ADDON_ACTION_FORBIDDEN` or
   `ADDON_ACTION_BLOCKED` rather than raising.
4. Is a read returning a secret rather than nil? They look identical in a print.
5. Does the function exist on this build at all? Check `reference/api/`.
