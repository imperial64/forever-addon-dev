# Persistence, and moving data in and out

On beta builds up to 69913 these were one topic, because the mechanism that gets data *in*
was also the only way around a SavedVariables bug. **On build 70009 that bug is gone.**
SavedVariables work, and this page now covers them first and the data channel second.

## What works, measured

| Direction | 70009 | 69913 and earlier |
|---|---|---|
| Addon → disk | **Works.** Written on `/reload` and logout | Works |
| Disk → addon, `## SavedVariables` | **Works.** Across `/reload` and a full relaunch | Never read back |
| Disk → addon, `## SavedVariablesPerCharacter` | **Works.** Across `/reload` and a full relaunch | Survived a `/reload`, not a logout |
| Disk → addon, via a generated `.lua` | Works. The client executes it as addon code at load | Works |
| Addon reloading itself | **Forbidden.** `ReloadUI()` is protected | Forbidden |

The 70009 column was measured on 2026-09-25. A marker was seeded into twelve saved globals
across two test addons, account-wide and per-character. The client was then fully exited and
relaunched through Battle.net, and the marker came back in every one of them
(`research/findings.md` §P.30). This page has an expiry: re-check on every new build.

## The one thing that bites on 70009: when the restore happens

Saved data now arrives. The question is **when**. The answer depends on one `.toc`
directive.

**By default, the client restores after your file scope.** While your addon's files run,
every saved global is `nil`. At `ADDON_LOADED` the client **replaces** the global with the
restored table, and whatever your file put there is thrown away. That is retail's order.

**With `## LoadSavedVariablesFirst: 1`, the client restores before it.** Your saved globals
already hold last session's tables when file-scope code runs.

Both were measured side by side, in two addons identical apart from that one line, across a
`/reload` and a cold start, with the same result both times (§P.31). What each idiom does:

| At file scope | Default | With `## LoadSavedVariablesFirst: 1` |
|---|---|---|
| `MyAddonDB = { ... }` | Saved data survives, because the client replaces your table at `ADDON_LOADED`. Your table is lost | **Saved data is destroyed.** Your fresh table replaces it and is what gets written at exit |
| `MyAddonDB = MyAddonDB or {}` then `local db = MyAddonDB` | **Writes are lost.** `db` points at a table the client discarded at `ADDON_LOADED`. Nothing errors | Works |
| Nothing at file scope, bind on `ADDON_LOADED` | Works | Works |

The middle row is the dangerous one. It is the idiom most addons use, and it looks safe. It
also passes a first test. On an addon's very first launch there is no file on disk, so the
client leaves the file-scope table alone. The orphan only appears from the second launch
onwards. The probe addon in this repo was built that way and needed a guard added before
this measurement to keep its own data.

**Write the idiom that is safe under either order:**

```lua
local db

local frame = CreateFrame("Frame")
pcall(frame.RegisterEvent, frame, "ADDON_LOADED")
frame:SetScript("OnEvent", function(_, event, addon)
    if event == "ADDON_LOADED" and addon == "MyAddon" then
        MyAddonDB = MyAddonDB or {}
        db = MyAddonDB
        db.profile = db.profile or {}   -- fill gaps, never replace the table
    end
end)
```

Take your reference *after* `ADDON_LOADED`, and from then on only mutate that table. Declare
`## LoadSavedVariablesFirst: 1` only if you genuinely need saved values while your files
are still loading. If you do, never assign the global unconditionally. An addon cannot ask
which order it is in: `C_AddOns.GetAddOnMetadata` returns `nil` for the directive.

The linter flags an unconditional file-scope assignment to a declared saved global as
`sv-file-scope-init`, and the file-scope `local db = MyAddonDB` reference, the one that
actually loses data under the default order, as `sv-file-scope-alias`. With the directive
set, it flags that reference only when the global is given a new table later in the same
file. It stays quiet when the local is re-pointed further down, which it takes to mean the
swap is handled. It is a regex check, so an alias taken in another file is not seen.

Only the standard paths are read: `WTF\Account\<account>\SavedVariables\` and the
per-character folder under it. The two alternative paths other developers named,
`WTF\Account\SavedVariables\` and `WTF\SavedVariables\`, are still neither read nor written
on 70009 (§P.33).

## If you installed a SavedVariables workaround on 69913, remove it

Several workarounds circulated while the bug was live. They include the ForeverSVFix and
WTFix tools, the svshim watcher, a hand-added `.toc` line such as
`SavedVariablesLink.lua` pointing at the SV file, and symbolic links or directory junctions
from an addon folder into `WTF`. On 70009 the client restores the file itself, so each of
these is now a second mechanism writing the same global. Depending on the order, it either
repeats the restore or overwrites it with an older copy. That is reasoning from the measured
load order. None of those tools was measured here.

On 70009 and later:

1. **Remove the workaround addon or tool.** Disabling is not enough for tools that edited
   other addons' `.toc` files. Stop any watcher process or scheduled task it installed.
2. **Delete leftover `.toc` lines** that list a SavedVariables file, or a link to one, as
   addon code. Reinstalling the affected addon from a clean copy also removes them.
3. **Remove symbolic links and junctions** under `WTF` and `Interface\AddOns`. Remove the
   link itself (`Remove-Item <link>`), not the file it points at.

To find them from PowerShell, with `$beta` set to your `_classic_beta_` folder:

```powershell
Get-ChildItem "$beta\WTF\Account", "$beta\Interface\AddOns" -Recurse -Force -Attributes ReparsePoint -ErrorAction SilentlyContinue | Select-Object FullName, LinkType, Target
```

### What 69913 did, briefly

On 69913 the account-wide file was written and never read back. The per-character file
survived a `/reload` but not a restart (§P.23, §P.27). The flush was destructive: a table
that starts `nil` every session means a `/reload` before running anything writes an empty
table over the last session's data. The rule then was **collect, then reload**, because the
client's `.bak` holds exactly one generation (§P.21). On 70009 your table starts as last
session's, so that rule only still matters if your addon discards the restored table
itself, as in the table above.

## The inbound channel

The sandbox is intact — `io`, `os`, `loadfile` and `dofile` are all absent, so an addon
cannot read a file. The door the sandbox leaves open is that your `.toc` lists files and
the client *executes* them:

```
## Interface: 16001
## Title: My Addon
## SavedVariables: MyAddonDB

Data.lua        <- written from outside, executed as code
MyAddon.lua
```

`Data.lua` is generated by an external process and looks like this:

```lua
MyAddon_Inbox = MyAddon_Inbox or {}
MyAddon_Inbox[#MyAddon_Inbox + 1] = { tag = "prices", when = 1789735367, payload = "..." }
```

Your addon reads `MyAddon_Inbox` out of memory at load. It works because the file is code
being executed, not data being read, which is the only door the sandbox leaves open.

**The cost is a `/reload` per refresh**, and because `ReloadUI()` is protected, a person
has to type it. There is no polling and no push.

## Payloads

`C_EncodingUtil` is present with JSON and CBOR in both directions, base64, hex, and string
compression. That is worth knowing before hand-rolling a format: both ends can agree on
JSON and compress it, rather than emitting Lua literals.

```lua
local data = C_EncodingUtil.DeserializeJSON(payload)
```

## The round trip, end to end

1. An external process writes `Data.lua` into the addon folder.
2. The player types `/reload`.
3. The addon reads its inbox at load and does the work.
4. The addon writes results into SavedVariables.
5. `/reload` or logout flushes them; the external process reads the file.

Both halves are measured working. The only thing missing is automation of step 2, and that
is by design on Blizzard's part.

## What not to use

- **Addon messages as a sideband.** `C_ChatInfo.SendAddonMessage` exists, but
  `AreOutgoingAddonChatMessagesRestricted()` returns true in and out of combat. What that
  restricts in practice has not been measured — treat it as a flag to check, not a channel
  to build on.
- **CVars as storage.** `C_CVar` has full read/write including `RegisterCVar`, and it does
  persist. It is a small, global, shared namespace though, and abusing it will collide with
  other addons.
