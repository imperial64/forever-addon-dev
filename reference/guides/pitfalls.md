# Seven things that will bite you

Each of the first five cost real debugging time while building the probe this reference
was measured with. The last two cost another developer their addon's saved data and a
wrong code path respectively, and are credited in `research/findings.md` §10 and §11.
They are in the order you are likely to hit them.

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

Two more, measured 2026-09-20, that make a secret harder to spot than it sounds:

- **`type()` reports `"number"` on a secret number.** A type check is not a secrecy check.
- **Equality throws.** `value == value` raises, which means `if value == nil then` — the
  guard people write precisely because they are being careful — is itself unsafe.
- **Concatenation does *not* throw.** `"" .. value` succeeds and hands back a secret
  string. Comparison, arithmetic and equality are loud; `tostring()` and `..` are silent,
  and those two are how the taint reaches a `print` far from the read.

`issecretvalue()` is the only safe test. Not `type()`, not a comparison against nil.

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

## 3. Account-wide SavedVariables are written but never read back

On this build the client writes `## SavedVariables` to disk on logout or `/reload` and
**never loads it**. Your addon starts from defaults every launch.

**`## SavedVariablesPerCharacter` survives a `/reload`** — but not a logout, so it is not
a settings story either. Measured side by side in one addon with identical binding code.
Nothing about your binding idiom matters here; two published "fixes" claimed otherwise and
both were tested and refuted. See `guides/savedvariables.md`.

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

## 6. A blank line in the `.toc` header silently drops everything after it

The header ends at the first line that is not a `##` directive. Put a blank line above
`## SavedVariables` and the directive is never read, so the addon has no saved variables at
all — which presents as *all settings wiped at login*, with no error anywhere.

```
## Interface: 16001
## Title: My Addon
                          <- this blank line ends the header
## SavedVariables: MyDB   <- never read
```

Keep every directive contiguous, and put comments and the file list below them. The linter
reports this as `toc-header-break`. Full header guidance: `guides/packaging.md`.

## 7. You cannot detect this client with `WOW_PROJECT_ID`

There is no `WOW_PROJECT_*` constant for Forever. It reports `WOW_PROJECT_MAINLINE`, the
same value retail reports, so a check for mainline is true on both and a check for classic
is false on a Classic-line client. Anything branching on it takes the wrong path on one
client or the other.

Bracket the interface version instead — `>= 16000 and < 20000` — or, better, test for the
capability you actually need rather than for the client. The linter flags
`WOW_PROJECT_ID` comparisons as `project-id-detection`. See `guides/packaging.md`.

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
