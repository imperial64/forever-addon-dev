# Ten things that will bite you

Each of the first six cost real debugging time against a live client. Items 7 and 8 cost
another developer their addon's saved data and a wrong code path respectively, and are
credited in `research/findings.md` §10 and §11. Items 9 and 10 come from a second addon
measured on the same client and are credited in §Q.9 and §P.22. They are in the order you
are likely to hit them.

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
can lose all of its saved data to one unguarded read. Now that 70009 reads SavedVariables
back, that is data a user would otherwise have kept.

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

## 3. SavedVariables arrive after your file scope, and replace what you put there

On build 70009, SavedVariables are read back, account-wide and per-character, across
`/reload` and a full relaunch (`research/findings.md` §P.30). What bites now is **when**
they arrive.

By default the client restores at `ADDON_LOADED`, *after* your files have run, and it
**replaces** the global rather than filling in your table. So this common idiom loses every
write from the second launch on, silently:

```lua
MyAddonDB = MyAddonDB or {}
local db = MyAddonDB      -- points at a table the client throws away at ADDON_LOADED
```

`## LoadSavedVariablesFirst: 1` moves the restore ahead of file scope. The idiom above is
then fine, and an unconditional `MyAddonDB = { ... }` is what destroys saved data instead.
The idiom that is safe under both orders is to bind inside `ADDON_LOADED` and only mutate
the table. Measured side by side in two addons differing by that one line (§P.31).
`guides/savedvariables.md` has the table and the code.

**On 69913 it was worse.** The account-wide file was never read back, per-character survived
only a `/reload`, and a `/reload` before running anything wrote an empty table over the last
session's data. If you installed a workaround for that (ForeverSVFix, WTFix, svshim, a
`.toc` link line, or a symbolic link into `WTF`), remove it on 70009. See
`guides/savedvariables.md`.

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

## 7. A blank line in the `.toc` header silently drops everything after it

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

## 8. You cannot detect this client with `WOW_PROJECT_ID`

There is no `WOW_PROJECT_*` constant for Forever. It reports `WOW_PROJECT_MAINLINE`, the
same value retail reports, so a check for mainline is true on both and a check for classic
is false on a Classic-line client. Anything branching on it takes the wrong path on one
client or the other.

Bracket the interface version instead — `>= 16000 and < 20000` — or, better, test for the
capability you actually need rather than for the client. The linter flags
`WOW_PROJECT_ID` comparisons as `project-id-detection`. See `guides/packaging.md`.

## 9. `GetSubZoneText()` is not an indoor/outdoor test

`IsIndoors()` and `IsOutdoors()` are present and return correct, complementary booleans. The
subzone name does not track them, and the two disagree across a **band** rather than at a
line.

Walking into the Northshire chapel, logged on change:

```
Northshire Valley                    outdoors
Northshire Valley  [indoors]         on the steps - the disagreement
Main Hall          [indoors]
Hall of Arms       [indoors]
Library Wing       [indoors]
Main Hall          [indoors]
Northshire Valley  [indoors]         on the way out, again
Northshire Valley                    outdoors
```

Anything using the subzone name as its indoor/outdoor signal flips part-way through a
building, in both directions. Two more traps in the same corner:

- **Subzone names are reported outdoors too.** The presence of a name cannot mean "inside".
- **A building shares its x,y with the ground under it.** A map coordinate cannot express
  "indoors" either.

`IsIndoors()` is the only signal that carries it. Use it, and treat the subzone name as what
it is — a label for display. Nothing here is refused; this is a correctness trap, and it
cost a real addon a bug. `research/findings.md` §Q.9.

Related, and worth knowing before you reach for a position read: walking indoors does **not**
break `C_Map.GetPlayerMapPosition`. Inside the chapel it returns an ordinary point on the
parent map with the uiMapID unchanged. The retail caveat about instances is a different case
— see `guides/performance.md`.

## 10. There is no global `GetCVarInfo`

It is `C_CVar.GetCVarInfo`, with the documented seven-value shape. The bare global does not
exist on this build.

This is worth its own line because of *how* it fails. A retail-shaped addon reaches for the
global, gets `nil`, and — if it guarded the call — silently skips its lock-flag check rather
than erroring. You get an addon that believes it verified a CVar was writable and in fact
verified nothing.

```lua
local info = C_CVar.GetCVarInfo(name)   -- not GetCVarInfo(name)
```

The generated reference is already correct about this: `reference/api/` has a page for
`C_CVar.GetCVarInfo` and none for a global of that name. If a symbol you expect has no page,
that absence is itself the answer.

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
5. Was it a secure snippet run in combat? `frame:Execute` on a header made before combat
   returns normally and does nothing, and only an `ADDON_ACTION_BLOCKED` event records the
   refusal. See `restrictions/protected-actions.md`.
6. Does the function exist on this build at all? Check `reference/api/`.
