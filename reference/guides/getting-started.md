# Your first Forever addon

Forever runs **Retail's API on interface 16001**. If you have written a Retail addon, most
of what you know applies. If you have written a Classic addon, be careful: the Classic-era
globals are gone, and `reference/guides/aliases.md` maps the common ones to their
replacements.

## Where addons live

```
<WoW>/_classic_beta_/Interface/AddOns/MyAddon/
    MyAddon.toc
    MyAddon.lua
```

The product folder is `_classic_beta_` during the beta, not `_retail_` or `_classic_`.

## The .toc

```
## Interface: 16001
## Title: My Addon
## Notes: Does a thing.
## SavedVariables: MyAddonDB

MyAddon.lua
```

`## Interface:` must be `16001`. If it is wrong the addon shows as out of date and will not
load unless the player ticks **Load out of date AddOns** at the character screen. Files
listed at the bottom load in order, top to bottom.

## A first addon that is correct for this client

```lua
local ADDON, ns = ...

-- Bound in ADDON_LOADED below, never at file scope: by default the client
-- replaces the saved global at ADDON_LOADED, so a reference taken here would
-- point at a table it throws away. See guides/savedvariables.md.
local db

-- Anything read out of the game goes through here before it is printed, compared
-- or stored. See restrictions/secret-values.md for why.
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

-- An event this client does not have RAISES, and an error in the main chunk
-- stops the rest of this file loading. See guides/pitfalls.md.
local function safeRegister(frame, event)
    return (pcall(frame.RegisterEvent, frame, event))
end

local frame = CreateFrame("Frame")
safeRegister(frame, "ADDON_LOADED")
safeRegister(frame, "PLAYER_LOGIN")
frame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON then
        MyAddonDB = MyAddonDB or {}
        db = MyAddonDB              -- mutate this table from here on; never reassign it
    elseif event == "PLAYER_LOGIN" then
        out("loaded.")
    end
end)

SLASH_MYADDON1 = "/myaddon"
SlashCmdList.MYADDON = function(arg)
    out("you said: " .. plain(arg))
end
```

## Loading it

1. Copy the folder into `Interface/AddOns/`.
2. At the character select screen, click **AddOns** and tick yours. **New addons are not
   enabled by default** — this is the most common reason a new addon appears to do
   nothing.
3. Log in. `/reload` after any code change; you do not need to restart the client unless
   you added a *new* addon folder.

## Checking it

```bash
python tools/lint_addon.py Interface/AddOns/MyAddon/
```

Flags calls this client does not have, refused events, secret reads, protected actions and
the version-check trap.

## What to read next

- `guides/pitfalls.md` — the six things that will bite you, all measured
- `guides/savedvariables.md` — persistence: fixed on 70009, and the load-order trap that
  remains
- `guides/packaging.md` — the `.toc`, the interface number, and shipping it
- `guides/performance.md` — what calls cost, and why position polling is a garbage
  problem rather than a time one
- `restrictions/` — what the client will refuse, and how it refuses
- `reference/api/` — every function, generated from the client's own documentation
