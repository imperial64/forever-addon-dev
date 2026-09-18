---
name: build
description: >
  Write, structure, scaffold and debug World of Warcraft Forever addons - .toc files and
  load order, frames and event handling, SavedVariables, slash commands, secure templates,
  plus the Auction House and economy recipes measured on the Forever beta (interface
  16001). Use when starting a new addon, writing or reviewing addon Lua for WoW Forever,
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
`.lua` file into your addon folder that the client executes as addon code at load. That is
also the whole inbound half of a Claude Code bridge.

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

Before writing against any function, two habits worth keeping:

1. **Check it exists on this build** — the api skill. A missing reference page means the
   symbol is not on this client, reliably.
2. **Check you are allowed to call it** — the restrictions skill. Blizzard documenting a
   function says nothing about whether the client will let an addon use it, and on this
   build the answer is often no.

## Recipes

- Auction House and economy addons: **browse is the data source, not `ReplicateItems`.**
  One browse query returns the complete item-key market in about three seconds,
  unthrottled and repeatable. `ReplicateItems` is the optional deep read, it is throttled,
  and a throttled call returns an empty market rather than an error — so track your own
  scan timing. Measurements and design consequences:
  `research/auction-addon-architecture.md` section 9, `research/findings.md` P.15–P.17.
- Talking to an external process: the inbound channel is a generated `.lua` file executed
  at load, the outbound channel is SavedVariables read from disk, and the cost is a manual
  `/reload` per refresh. `research/findings.md` P.9 and
  `research/auction-addon-architecture.md` section 5.

## When an addon "does nothing"

In this order:

1. Is it enabled at the character screen? New addons are not enabled by default.
2. Did the main chunk abort? An unknown event registration is the usual cause, and it is
   silent — the addon loads, defines nothing, and reports no error.
3. Did a call get refused? A forbidden action fires an event rather than raising. Install
   the probe addon and run `/fprobe blocked`, which names the call.
4. Is a read returning a secret rather than nil? They look identical in a print.
5. Does the function exist on this build at all?
