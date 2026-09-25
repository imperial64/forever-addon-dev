# Protected and forbidden actions

Some calls are refused. Which ones, and when, splits three ways.

| Call | Out of combat | In combat | How it refuses |
|---|---|---|---|
| `CastSpellByName` | allowed | allowed | — |
| `UseAction` | **FORBIDDEN** | **FORBIDDEN** | `ADDON_ACTION_FORBIDDEN` |
| `ReloadUI` | **FORBIDDEN** | **FORBIDDEN** | protected |
| `EditMacro` | allowed | **BLOCKED** | `ADDON_ACTION_BLOCKED` |
| `SetOverrideBindingClick` | allowed | **BLOCKED** | `ADDON_ACTION_BLOCKED` |
| `SecureActionButton:SetAttribute` | allowed | *allowed?* | see below |
| Secure snippet, `frame:Execute` on a header made before combat | runs (70009) | **BLOCKED, silently** | `ADDON_ACTION_BLOCKED`, no error |
| Secure snippet, `frame:Execute` on a header made in combat | — | **raises** | "Header frame must be explicitly protected" |

## Forbidden versus blocked

**Forbidden** means at all times, and `UseAction` is the notable one: on Retail it is merely
protected in combat, here it is refused outright.

**Blocked** means combat only, which is Retail's long-standing behaviour and unremarkable.
Macro editing and binding overrides work fine while you are standing around.

Neither raises a Lua error. Both fire an event and show the player a dialog. **A `pcall`
around either reports success**, so testing whether a call "worked" by wrapping it is
always wrong on this client — you have to watch for `ADDON_ACTION_BLOCKED` and
`ADDON_ACTION_FORBIDDEN`.

## `ReloadUI` and what it costs you

An addon cannot reload the UI; a human types `/reload`. This is the binding constraint on
any scheme that feeds data into the client from outside, because the inbound channel is a
generated `.lua` file read at load. There is no unattended refresh.

## The one to re-test before trusting

`SecureActionButton:SetAttribute` **succeeded in combat** when measured. Retail
protects exactly that, and it is the mechanism every action-bar addon depends on.

Our evidence is that the call raised no error and fired no block event — which is weaker
than the attribute actually taking effect, and this client has already demonstrated that a
refusal can be completely silent. It is recorded as `caution` rather than as a capability.
**Do not build on it without re-testing.**

Build 70009 makes the doubt sharper, not weaker. The snippet test below caught the client
refusing an insecure `SetAttribute` on a protected frame in combat, and the only trace was
an `ADDON_ACTION_BLOCKED` event (`research/findings.md` §P.32).

## Secure snippets: working on 70009, refused in combat

Measured 2026-09-25 on build 70009 (`research/findings.md` §P.32). Out of combat, a frame
made from `SecureHandlerBaseTemplate` or `SecureHandlerAttributeTemplate` runs
`frame:Execute("self:SetAttribute('fbok', 42)")`, and the attribute reads back 42.

**Detect support by running one, not by looking for a global.** `loadstring_untainted` is
still `nil` on 70009, where snippets run. Earlier builds were reported to break snippets,
and this repo never measured that. Code that decides "snippets are broken" from
`type(loadstring_untainted) == "nil"` gets the wrong answer on 70009:

```lua
-- Out of combat, once. Cache the answer for the session.
local function snippetsWork()
    if InCombatLockdown() then return nil end   -- cannot tell in combat; see below
    local ok, header = pcall(CreateFrame, "Frame", nil, UIParent, "SecureHandlerBaseTemplate")
    if not ok or not header then return false end
    pcall(header.Execute, header, "self:SetAttribute('probe', 42)")
    return header:GetAttribute("probe") == 42
end
```

**In combat, `Execute` is refused two different ways:**

- On a header created **before** combat, `Execute` **returns normally** and does nothing.
  The attribute keeps its old value, and the only trace is two `ADDON_ACTION_BLOCKED`
  events naming `SecureHandlersUpdateFrame:SetAttribute()`. A `pcall` reports success.
- On a header created **during** combat, `Execute` **raises**
  `SecureHandlers.lua:690: Header frame must be explicitly protected`.

That looks like retail's ordinary lockdown rather than a Forever-specific rule, but no
retail client was measured. The practical rule is the retail one: build and configure every
secure header out of combat, check `InCombatLockdown()` before `Execute`, and treat a normal
return in combat as a failure unless the attribute actually changed. Only `Execute` was
measured. `WrapScript`, state drivers, action-bar paging and click-casting were not run on
70009.

## Auction House posting

All seven of Retail's restricted auction functions are present and carry Blizzard's
`HasRestrictions` flag: `PostItem`, `PostCommodity`, `ConfirmPostItem`,
`ConfirmPostCommodity`, `PlaceBid`, `StartCommoditiesPurchase`, `CancelAuction`.

`HasRestrictions` means gated on a hardware event: computable in advance, but a human clicks
once per action. 274 functions across the client carry that flag, and the reference shows it
as a banner on each one.

## Detecting a refusal

```lua
local watcher = CreateFrame("Frame")
pcall(watcher.RegisterEvent, watcher, "ADDON_ACTION_BLOCKED")
pcall(watcher.RegisterEvent, watcher, "ADDON_ACTION_FORBIDDEN")
watcher:SetScript("OnEvent", function(_, event, addon, func)
    if addon == "MyAddon" then
        -- `func` is often UNKNOWN(); correlate with what you were doing instead
    end
end)
```

The client frequently does not name the function in the payload, so record what your addon
was attempting and correlate. The probe addon in this repo does exactly that, and
`/fprobe blocked` prints the result.

## Evidence

Measured 2026-09-18 on client 1.60.1 build 69913. `research/findings.md` P.4 (out of
combat) and P.20 (the combat delta). Secure snippets: 2026-09-25 on build 70009, P.32.
