# The combat log

**Addons may not subscribe to it. Either form. At any time.**

```lua
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")  -- refused
frame:RegisterEvent("COMBAT_LOG_EVENT")             -- refused
```

## How it refuses

The client fires `ADDON_ACTION_FORBIDDEN`, shows the player the "blocked from an action
only available to the Blizzard UI" dialog, and **the registration quietly does not happen**.

Nothing is raised. A `pcall` around the registration reports success. Your frame simply
never receives the event, which is indistinguishable from a quiet combat log — this is the
most misleading failure on the client.

The restriction holds at a second, independent level: **`CombatLogGetCurrentEventInfo` is
absent** from the client entirely. Even a frame that somehow held a subscription would have
nothing to read it with.

## This is not combat-scoped

Measured at load, out of combat, standing in a field with no target. Unlike the
`C_Secrets` value gates, this one is **always on**.

## The rule is narrow

Every other event tried is **permitted**:

`UNIT_AURA`, `UNIT_COMBAT`, `UNIT_HEALTH`, `UNIT_POWER_UPDATE`, `UNIT_SPELLCAST_START`,
`UNIT_SPELLCAST_SUCCEEDED`, `UNIT_THREAT_LIST_UPDATE`, `PLAYER_REGEN_DISABLED`,
`PLAYER_REGEN_ENABLED`, `CHAT_MSG_ADDON`, `PLAYER_MONEY`, `BAG_UPDATE`,
`AUCTION_HOUSE_SHOW`, `AUCTION_HOUSE_THROTTLED_SYSTEM_READY`.

So the rule is **"no combat log"**, not "no combat information". An addon may still know it
is in combat, watch auras change, and see units cast. What it cannot have is the log.

Note `PLAYER_REGEN_DISABLED` / `PLAYER_REGEN_ENABLED` in that list: you can still tell
whether you are in combat, which is what lets an addon defer work to a safe moment rather
than discovering a restriction mid-task.

## What to do instead

Blizzard ships **`C_DamageMeter`** (8 functions) as the first-party replacement for damage
numbers. There is no addon-side substitute for parsing the log itself — this is the one
capability with no workaround.

## Evidence

Measured 2026-09-18 on client 1.60.1 build 69913. `research/findings.md` P.1 (the refusal)
and P.12 (the boundary — which events *are* permitted).
