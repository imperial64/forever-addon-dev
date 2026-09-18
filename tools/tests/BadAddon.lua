-- A deliberately wrong addon. Every line here should produce exactly one
-- finding, and tools/tests/expected.txt records which. A linter that goes quiet
-- is indistinguishable from a linter that works, so this file is how we tell.
--
-- Not installable, not loaded by anything. It exists to be linted.

local frame = CreateFrame("Frame")

-- Blizzard's own UI reads this fine. An addon may not even subscribe.
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

-- Exists on this client, but an unknown event name here would abort the whole
-- file, so it wants a pcall.
frame:RegisterEvent("PLAYER_LOGIN")

-- Forbidden at all times, not merely protected in combat.
UseAction(1)

-- An addon cannot reload itself; a human types /reload.
ReloadUI()

-- Permitted out of combat, blocked in it.
EditMacro(1, nil, nil, "/cast Attack")

-- Secret at all times - the one thing the published doctrine promises is safe.
local power = UnitPower("player")

-- Secret in combat, and this one throws rather than returning nil.
local aura = C_UnitAuras.GetAuraDataByIndex("target", 1, "HARMFUL")

-- tostring() does not launder a secret: it returns a secret STRING that throws
-- wherever it is next indexed.
print(tostring(UnitPower("player")))

-- Succeeds and returns an empty market when throttled, with no error.
C_AuctionHouse.ReplicateItems()

-- Forever answers 16001, so this sends the addon down its Classic path.
if select(4, GetBuildInfo()) >= 100000 then
    local modern = true
end

-- Not on this client at all.
C_AuctionHouse.QueryAuctionItems("list")

-- A suppression with no reason is itself a finding.
UseAction(2)  -- lint-allow: forbidden-call
