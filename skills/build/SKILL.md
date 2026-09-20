---
name: build
description: >
  Write, structure, scaffold and debug World of Warcraft Forever addons - .toc files and
  load order, frames and event handling, SavedVariables, slash commands, secure templates,
  and the client behaviours measured on the Forever beta (interface 16001) that a working
  addon has to be written around. Use when starting a new addon, writing or reviewing addon
  Lua for WoW Forever,
  asking how to do something in an addon, or debugging one that loads wrongly, silently
  does nothing, or dies mid-run. For one function's exact signature use the api skill; for
  whether a call is forbidden, secret or throttled use the restrictions skill.
---

# Building a Forever addon

Forever runs **Retail's API on interface 16001**, product folder `_classic_beta_`. If you
know Retail addon development you know most of this. What follows is what is different,
and every item cost real debugging time to find.

## The five things that will bite you

Put these in any addon you write for this client, before anything else.

### 1. An unknown event aborts the whole file

`RegisterEvent` on an event this client does not have **raises**, and an error in the main
chunk stops the rest of the file loading. One stale event name silently removes every
command your addon defines, and the addon looks like it simply is not there.

```lua
local function safeRegister(frame, event)
    local ok = pcall(frame.RegisterEvent, frame, event)
    return ok
end
```

This is *not* the same as a forbidden registration, which does not raise at all — see the
restrictions skill.

### 2. Secret values survive `tostring()`

A secret value converted with `tostring()` returns a **secret string**. A `pcall` around
the read reports success, and the value detonates later wherever that string is next
indexed — in a print, in a `format`, far from the read. A secret string written into
SavedVariables takes the entire flush with it.

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

Route every value read out of the game through something like this before printing,
comparing or storing it.

### 3. SavedVariables are written but never read back

On this build the client writes your saved file on logout and **never loads it**. Your
addon starts from defaults every launch. Outbound works fine — an external process can
read the file — but the in-client round trip is broken.

If you need settings to persist, the working pattern is an external process writing a
`.lua` file into your addon folder that the client executes as addon code at load.

### 4. `ReloadUI()` is protected

Your addon cannot reload the UI. A human types `/reload`. Design any refresh loop around
that; there is no unattended version.

### 5. The version-check trap

Almost every Retail addon tests `select(4, GetBuildInfo()) >= 100000` to mean "modern
client". Forever answers **16001**, so those addons take their Classic code path or refuse
to load. If you are porting, find that idiom and fix it.

## A minimal addon that is correct for this client

`MyAddon.toc`:

```
## Interface: 16001
## Title: My Addon
## Notes: Does a thing.
## SavedVariables: MyAddonDB

MyAddon.lua
```

`MyAddon.lua`:

```lua
local ADDON, ns = ...

MyAddonDB = MyAddonDB or {}
local db = MyAddonDB

local function plain(v)
    if issecretvalue and issecretvalue(v) then return "<SECRET>" end
    local ok, str = pcall(tostring, v)
    if not ok then return "<UNPRINTABLE>" end
    if issecretvalue and issecretvalue(str) then return "<SECRET>" end
    local okCut, cut = pcall(string.sub, str, 1, 200)
    return okCut and cut or "<SECRET>"
end

local function out(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff44ddffMyAddon|r " .. plain(msg))
end

-- Every registration goes through here: an unknown event raises and takes the
-- rest of this file with it.
local function safeRegister(frame, event)
    return (pcall(frame.RegisterEvent, frame, event))
end

local frame = CreateFrame("Frame")
safeRegister(frame, "PLAYER_LOGIN")
frame:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LOGIN" then
        out("loaded.")
    end
end)

SLASH_MYADDON1 = "/myaddon"
SlashCmdList.MYADDON = function(arg)
    out("you said: " .. plain(arg))
end
```

Install it to `<WoW>/_classic_beta_/Interface/AddOns/MyAddon/`, enable it at the character
screen, and `/reload`.

## Checking your work

```bash
python tools/lint_addon.py path/to/YourAddon/
```

Checks source against the measured ground truth: calls to functions this client lacks,
subscriptions to refused events, reads that come back secret, protected actions, the
`tostring()`-on-a-secret trap, unguarded `RegisterEvent`, and the version-check trap. Each
finding cites the evidence section it comes from.

Point it at the **folder**, not just the Lua: it lints the `.toc` too, for the two header
mistakes that cost other porters a day — a blank line inside the header silently dropping
every directive after it, and no `16001` among the declared interface versions. It also
flags an unconditional file-scope assignment to a declared saved global, and any attempt
to detect this client with `WOW_PROJECT_ID`. See `reference/guides/packaging.md`.

It is a **regex linter, not a Lua parser** — it cannot follow aliases, table lookups or
dynamic calls, so a clean run is not a proof of correctness. It says so on every run.

If your addon does something restricted deliberately, suppress it with a reason:

```lua
UseAction(1)  -- lint-allow: forbidden-call - measuring the refusal on purpose
```

A suppression with no reason is itself reported, because it is indistinguishable from a
mistake.

Before writing against any function, two habits worth keeping:

1. **Check it exists on this build** — the api skill. A missing reference page means the
   symbol is not on this client, reliably.
2. **Check you are allowed to call it** — the restrictions skill. Blizzard documenting a
   function says nothing about whether the client will let an addon use it, and on this
   build the answer is often no.

## Guides

Longer form, written for someone who has not read the research:

- `reference/guides/getting-started.md` — first addon, .toc, installing, enabling
- `reference/guides/pitfalls.md` — the five above in detail, plus two `.toc` traps, the
  CVar enable-flag trap and the three failure shapes
- `reference/guides/savedvariables.md` — persistence, and moving data in and out
- `reference/guides/packaging.md` — the `.toc` header, why the interface is 16001, and
  why `WOW_PROJECT_ID` cannot detect this client
- `reference/guides/performance.md` — measured per-call costs, and the two traps in
  measuring them yourself

## Two recipes worth knowing before you design

- **Auction House data: browse is the source, not `ReplicateItems`.** One
  `C_AuctionHouse.SendBrowseQuery` returns the complete item-key market in about three
  seconds, unthrottled and repeatable. `ReplicateItems` is the optional per-listing deep
  read, it is throttled, and a throttled call returns an *empty market* rather than an
  error — so any addon that calls it has to track its own scan timing. `research/findings.md`
  P.15–P.17.
- **Reading player position is a garbage problem, not a time problem.**
  `C_Map.GetPlayerMapPosition` returns an object with `GetXY()` and allocates **1864 bytes
  per call** — about 218 KB/s polled every frame at 120 fps, against 18 KB/s on a 10 Hz
  accumulator. Time is not the constraint; nothing measured here costs more than a few
  microseconds. Two traps in measuring it yourself: `OnUpdate` `elapsed` is quantised to
  1 ms on this client, so it cannot profile anything smaller, and an allocation measurement
  needs `collectgarbage("stop")` first or a collection mid-loop reads as "allocates
  nothing". `reference/guides/performance.md`, `research/findings.md` Q.2-Q.6.
- **Moving data in and out of the client.** The inbound channel is a generated `.lua` file
  the `.toc` lists and the client executes at load; the outbound channel is SavedVariables
  read from disk; the cost is a manual `/reload` per refresh, because `ReloadUI()` is
  protected. `reference/guides/savedvariables.md`, `research/findings.md` P.9.

## When an addon "does nothing"

In this order:

1. Is it enabled at the character screen? New addons are not enabled by default.
2. Did the main chunk abort? An unknown event registration is the usual cause, and it is
   silent — the addon loads, defines nothing, and reports no error.
3. Did a call get refused? A forbidden action fires an event rather than raising. Install
   the probe addon and run `/fprobe blocked`, which names the call.
4. Is a read returning a secret rather than nil? They look identical in a print.
5. Does the function exist on this build at all?
