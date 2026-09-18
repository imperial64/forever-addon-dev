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
combat) and P.20 (the combat delta).
