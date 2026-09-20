# Persistence, and moving data in and out

These are the same topic on this client, because the mechanism that gets data *in* is the
same one that works around the bug in getting data *back*.

## What works, measured

| Direction | State |
|---|---|
| Addon → disk | **Works.** The client writes SavedVariables on `/reload` and logout |
| Disk → addon, via `## SavedVariablesPerCharacter` | **Survives a `/reload`, not a logout.** |
| Disk → addon, via `## SavedVariables` | **Broken on this build.** Never read back at all |
| Disk → addon, via a generated `.lua` | **Works.** The client executes it as addon code at load |
| Addon reloading itself | **Forbidden.** `ReloadUI()` is protected |

## There is no persistence across sessions — but `/reload` is survivable

Take this in two parts, because the obvious summary ("SavedVariables are broken on
Forever") is right about the thing that matters and wrong about the details.

**Across a logout or client restart: nothing survives, on either directive.** There is no
way to keep user settings between play sessions on this build. Measured on a cold start
with a populated file sitting on disk (`research/findings.md` §P.27).

**Across a `/reload` inside one session: per-character survives, account-wide does not.**

```
## SavedVariablesPerCharacter: MyAddonDB
```

Measured with the cleanest control available: one addon declared two globals, bound them
with identical code in the same `ADDON_LOADED` handler, and differed only in which
directive declared them. The per-character one came back across a `/reload` carrying a
token from an earlier pass; the account-wide one came back empty.

So if your addon needs to carry state across a `/reload` — a multi-pass measurement, a
capture being assembled in stages, anything a person interrupts with a reload — use the
per-character directive and it will be there. Do not promise your users that their
settings will still be there tomorrow.

The two exotic WTF paths other developers named (`WTF\Account\SavedVariables\`,
`WTF\SavedVariables\`) are neither read nor written; files seeded there before a cold
start were untouched afterwards. There is no folder that works.

## The account-wide SavedVariables bug

Declare `## SavedVariables: MyAddonDB` and the client will write
`WTF/Account/<account>/SavedVariables/MyAddon.lua` faithfully. It will not load it again.
Your global comes back `nil` on every launch, so an addon relying on account-wide settings
starts from defaults forever. Use the per-character directive above instead.

Verified three ways for the account-wide path: a pre-seeded file whose global was nil from
main chunk to logout, a load counter that never leaves 1 across sessions, and —
2026-09-20 — globals watched by table address across four load phases, none of which ever
arrived. Per-character differs only across a `/reload`; see above.

**What still works:** everything outbound. If your goal is getting data *out* of the
client for something else to read, SavedVariables is fine and needs no workaround.

### The flush is destructive: collect, then reload — never reload first

This is the operational consequence of "never read back", and it is sharper than that
phrasing sounds. Three facts that compose badly:

1. Your saved table starts **`nil`** every session, because nothing is read back.
2. A `/reload` or logout writes **whatever the current session built**.
3. That write **replaces** the file. It does not merge into it.

So the reload that saves your data and the reload that destroys it are the same command in a
different order. Reload *before* running anything and you have just written an empty table
over the previous session's results.

The client keeps a `.bak` beside the file, and that is the only recovery. It holds one
generation: a second flush overwrites it too, so a session where you reload twice while
working out what went wrong is a session where the backup is gone as well.

On 2026-09-18 this destroyed five completed measurement runs in a sister repository,
recovered from `.bak` only because it had not yet been overwritten a second time.

If your addon collects anything you would mind losing, the order is: run it, confirm it
reported what you expected, *then* `/reload`. `research/findings.md` §P.21.

### It is a tracked bug, and it is not your addon's fault

**It is filed, not intended.** `forever-bugs#34` is open against this build with no
Blizzard acknowledgement, so this page has an expiry. Re-check it on every new build.

**It is not an addon-side mistake.** This was worth checking, because two published
explanations said it was. One held that Forever restores saved variables *before*
executing addon Lua and that a file-scope initialiser therefore throws the restored table
away; addons that persist correctly, it said, "bind the TOC global on `ADDON_LOADED` and
only mutate that table".

Measured 2026-09-20 (`research/findings.md` §P.23): **no.** Four saved globals were bound
four different ways in one addon — including that exact `ADDON_LOADED` idiom — and every
one of them was `nil` when its handler first looked. There is nothing to clobber, because
nothing is ever restored. Saved variables are also *not* loaded before addon Lua: at file
scope, the earliest moment addon code can look, all four are `nil`. Per-character saved
variables are written and never read back either, so `## SavedVariablesPerCharacter` is
not a workaround.

Answered, and the answer is no: seeds placed at both before a cold start were never read
and were still sitting there untouched afterwards.

The load order turned out to be retail's, not the reported one, so **write the idiom that
is safe under either**, because it costs nothing and it is what you want the day the bug
is fixed:

```lua
-- Wrong everywhere: an unconditional assignment discards whatever was restored.
MyAddonDB = { profile = {} }

-- Correct only if saved variables are restored BEFORE this file runs. They are
-- not, on this client or on retail, so `db` can end up pointing at an orphan the
-- moment the bug is fixed and the client starts swapping the global again.
MyAddonDB = MyAddonDB or {}
local db = MyAddonDB

-- Safe under both. Bind inside ADDON_LOADED, mutate in place, never reassign.
local db
frame:SetScript("OnEvent", function(_, event, addon)
    if event == "ADDON_LOADED" and addon == "MyAddon" then
        MyAddonDB = MyAddonDB or {}
        db = MyAddonDB
        db.profile = db.profile or {}   -- fill gaps, never replace the table
    end
end)
```

The rule that makes it safe is the second line of the handler: take your reference *after*
`ADDON_LOADED`, and from then on only ever mutate that table. The linter flags an
unconditional file-scope assignment to a declared saved global as `sv-file-scope-init`.

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
