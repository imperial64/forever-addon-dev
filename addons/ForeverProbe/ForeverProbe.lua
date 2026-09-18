-- Forever Probe
--
-- Records the addon API surface of WoW Forever.
--
-- Primary job (2026-09-17 onwards): decide the two live plans - does an Auction
-- House API exist (the economy addon, which is the goal), and is there any channel
-- across the client boundary (the Claude Code bridge). The out-of-combat run
-- answers both on its own.
--
-- Secondary job: the combat delta. The rotation helper is shelved, since Tim Jones
-- said Forever has parity with retail on the INFORMATION addons can access, so the
-- combat run is now a kill-check (and a collateral-damage check for the two live
-- plans) rather than the point of the addon.
--
-- Measured against build 1.60.1.69893 (interface 16001, WOW_PROJECT_MAINLINE):
-- this is the Retail API set, so the Classic globals this probe used to reach for
-- (UnitAura, GetSpellCooldown, GetSpellInfo, CombatLogGetCurrentEventInfo) are
-- simply absent, registering an event the client does not know THROWS and aborts
-- the file, and a secret value throws on tostring() as readily as on arithmetic.
-- Everything below is written defensively for those three facts.
--
--   /fprobe          static surface scan + action tests out of combat
--   /fprobe combat   re-run the action tests while actually in combat
--   /fprobe report   print the out-of-combat vs in-combat delta
--   /fprobe ah       Auction House detail, standing at an auction house
--   /fprobe ah scan  fire a full ReplicateItems scan (burns the 15 min throttle)
--   /fprobe bridge   inbound BridgeData.lua and outbound SavedVariables flush
--
-- Results persist to WTF/Account/<ACCT>/SavedVariables/ForeverProbe.lua on
-- /reload or logout.
--
-- Blocked actions do NOT always raise a Lua error. They frequently fire
-- ADDON_ACTION_BLOCKED or ADDON_ACTION_FORBIDDEN instead, so pcall alone would
-- report a false "allowed". Both events are captured and correlated with
-- whichever test was running.

local ADDON, ns = ...

ForeverProbeDB = ForeverProbeDB or {}
local db = ForeverProbeDB

-- Inbound bridge channel ------------------------------------------------------
-- This is the mechanism every serious auction addon uses to get out-of-game data
-- into the client, and TradeSkillMaster_AppHelper is the reference implementation:
-- an external process overwrites a .lua file inside the addon folder, the client
-- executes it as ADDON CODE at load, and the addon reads it back out of memory.
-- There is no polling and no push - new data costs a /reload. It works because the
-- file is code being run, not data being read, which is the only door the sandbox
-- leaves open. See docs/auction-addon-architecture.md section 5.
--
-- BridgeData.lua is that file. It ships with a known default so an untouched
-- install is distinguishable from a successful external write.
local bridgeInbox = {}

function ns.LoadBridgeData(tag, ...)
    bridgeInbox[tag] = bridgeInbox[tag] or {}
    table.insert(bridgeInbox[tag], { ... })
end

local function out(msg) DEFAULT_CHAT_FRAME:AddMessage("|cff44ddffFProbe|r " .. tostring(msg)) end

-- Block capture ---------------------------------------------------------------
-- Declared up here rather than next to the watcher frame because safeRegister
-- below needs to attribute blocks to the registration that caused them, and a
-- local declared later would leave it writing to a nil global instead.
local activeTest, blockLog = nil, {}

local function blocksFor(test)
    local hits = {}
    for _, b in ipairs(blockLog) do
        if b.test == test then hits[#hits + 1] = b.event .. ":" .. tostring(b.func) end
    end
    return hits
end

-- Event registration ----------------------------------------------------------
-- Two separate things can go wrong here, and they look nothing alike:
--
--   1. The event does not exist on this client. RegisterEvent RAISES, and an
--      error in the main chunk aborts the rest of the file - which would silently
--      remove /fprobe entirely.
--   2. The event exists but addons are not allowed to have it. Nothing is raised.
--      The client fires ADDON_ACTION_FORBIDDEN, pops the "blocked from an action
--      only available to the Blizzard UI" dialog, and the registration quietly
--      does not happen. Observed at load on 2026-09-18.
--
-- (2) is the exact trap CLAUDE.md warns about: a pcall alone reports success.
-- So each registration is wrapped AND attributed, and the result of both paths is
-- recorded, because which events an addon may not even listen to is a finding in
-- its own right.
local registerFailures, registerBlocked = {}, {}
local function safeRegister(frame, event)
    local tag = "RegisterEvent:" .. event
    activeTest = tag
    local ok, err = pcall(frame.RegisterEvent, frame, event)
    activeTest = nil
    if not ok then
        registerFailures[#registerFailures + 1] = event .. " (" .. tostring(err):sub(1, 60) .. ")"
        return false
    end
    local blocked = blocksFor(tag)
    if #blocked > 0 then
        registerBlocked[event] = blocked[1]
        return false
    end
    return true
end

local watcher = CreateFrame("Frame")
safeRegister(watcher, "ADDON_ACTION_BLOCKED")
safeRegister(watcher, "ADDON_ACTION_FORBIDDEN")
safeRegister(watcher, "PLAYER_LOGIN")
watcher:SetScript("OnEvent", function(_, event, addon, func)
    if event == "PLAYER_LOGIN" then
        -- Outbound half of the bridge. db is whatever was restored from disk, so a
        -- token written during the LAST session is sitting right here if the flush
        -- on /reload or logout actually happened.
        db.bridge = db.bridge or {}
        db.bridge.tokenFromPreviousSession = db.bridge.tokenWrittenThisSession
        db.bridge.tokenWrittenThisSession = nil
        db.bridge.loads = (db.bridge.loads or 0) + 1
        out("loaded. /fprobe out of combat, then /fprobe combat mid-fight.")
        -- The forbidden-action dialog can appear before the player types anything,
        -- so point at the command that explains it rather than leaving the popup
        -- looking like a fault. Deferred one tick so the block log is settled.
        if C_Timer and C_Timer.After then
            C_Timer.After(1, function()
                if #blockLog > 0 then
                    out(("|cffffaa00%d blocked/forbidden action(s) at load|r - press Ignore on the popup,")
                        :format(#blockLog))
                    out("  then |cffffffff/fprobe blocked|r to see which call it was. This is data, not a fault.")
                end
            end)
        end
        return
    end
    if addon == "ForeverProbe" or activeTest then
        blockLog[#blockLog + 1] = {
            event = event, addon = addon, func = func,
            test = activeTest or "AT LOAD, no test running",
        }
        -- Straight to the DB, not at the end of a run: a block that happens at
        -- load is the one most likely never to reach SavedVariables otherwise.
        db.blockLog = blockLog
    end
end)

-- Combat log monitor ----------------------------------------------------------
-- The doctrine says addons can no longer parse combat events in real time. That
-- could mean the event stops firing, fires with fields stripped, or fires only
-- out of combat. Passively count events and keep a sample of each so the shape
-- of any restriction is visible rather than guessed at.
local clog = { count = 0, inCombatCount = 0, eventFired = 0, samples = {}, subevents = {} }

local clogFrame = CreateFrame("Frame")
clog.registered = safeRegister(clogFrame, "COMBAT_LOG_EVENT_UNFILTERED")
-- CombatLogGetCurrentEventInfo is absent on the measured beta build, so the event
-- can fire with nothing on the other side to read it. Record the distinction:
-- "event never fires" and "event fires but is unreadable" are different answers.
clog.readerPresent = CombatLogGetCurrentEventInfo ~= nil
clogFrame:SetScript("OnEvent", function()
    clog.eventFired = (clog.eventFired or 0) + 1
    if not CombatLogGetCurrentEventInfo then return end
    local ok, a, b, c, d, e, f, g, h, i, j, k, l = pcall(CombatLogGetCurrentEventInfo)
    if not ok then
        clog.error = tostring(a):sub(1, 120)
        return
    end
    clog.count = clog.count + 1
    if InCombatLockdown and InCombatLockdown() then
        clog.inCombatCount = clog.inCombatCount + 1
    end
    local sub = tostring(d)
    if not clog.subevents[sub] then
        clog.subevents[sub] = 0
        if #clog.samples < 12 then
            clog.samples[#clog.samples + 1] = {
                inCombat = InCombatLockdown and InCombatLockdown() or false,
                subevent = sub, sourceGUID = tostring(e), sourceName = tostring(f),
                destGUID = tostring(i), destName = tostring(j),
                arg11 = tostring(k), arg12 = tostring(l),
            }
        end
    end
    clog.subevents[sub] = clog.subevents[sub] + 1
end)

-- Presence scanning -----------------------------------------------------------
local function lookup(path)
    local obj = _G
    for part in path:gmatch("[^%.]+") do
        if type(obj) ~= "table" then return nil end
        obj = obj[part]
        if obj == nil then return nil end
    end
    return obj
end

local function scan(list)
    local found, missing = {}, {}
    for _, path in ipairs(list) do
        if lookup(path) ~= nil then found[#found + 1] = path else missing[#missing + 1] = path end
    end
    return found, missing
end

-- What a rotation helper READS. Expect some of this to be restricted: the
-- read side is what Blizzard has said it is restricting. Presence alone proves
-- nothing here - a black box keeps the function and returns nil or a masked
-- value, so the read tests compare VALUES across combat states.
local READ_SURFACE = {
    "GetSpellCooldown", "C_Spell.GetSpellCooldown", "GetSpellCharges", "C_Spell.GetSpellCharges",
    "IsUsableSpell", "C_Spell.IsSpellUsable", "IsSpellInRange", "C_Spell.IsSpellInRange",
    "GetSpellInfo", "C_Spell.GetSpellInfo", "IsCurrentSpell", "GetSpellPowerCost",
    "UnitPower", "UnitPowerMax", "UnitPowerType", "UnitHealth", "UnitHealthMax",
    "UnitAura", "UnitBuff", "UnitDebuff", "C_UnitAuras.GetAuraDataByIndex",
    "C_UnitAuras.GetPlayerAuraBySpellID", "AuraUtil.FindAuraByName",
    "UnitCastingInfo", "UnitChannelInfo", "UnitGUID", "UnitClassification", "UnitThreatSituation",
    "GetTime", "C_Timer.After", "C_Timer.NewTicker",
    "CombatLogGetCurrentEventInfo", "GetCombatRatingBonus", "GetHaste",
    "GetActionInfo", "GetActionCooldown", "GetActionTexture", "IsActionInRange",
    "GetInventoryItemCooldown", "GetItemCooldown", "C_Item.GetItemCooldown",
    "GetTalentInfo", "GetSpecialization", "C_SpecializationInfo.GetSpecialization",
    "GetNumTalents", "GetShapeshiftForm", "GetWeaponEnchantInfo", "GetSpellBookItemInfo",
}

-- What a rotation helper would need to EXECUTE an ability. Retail protects all of
-- this in combat. Presence means nothing on its own; the action tests decide.
local EXECUTE_SURFACE = {
    "CastSpellByName", "CastSpellByID", "UseAction", "UseInventoryItem", "UseItemByName",
    "RunMacro", "RunMacroText", "EditMacro", "SetMacroSpell", "PickupMacro",
    "SetBinding", "SetOverrideBinding", "SetOverrideBindingClick", "ClearOverrideBindings",
    "TargetUnit", "AssistUnit", "PetAttack", "StartAttack",
}

-- The sanctioned escape hatch in retail: precompute out of combat and let
-- Blizzard's own secure code do the switching. Also worth checking whether
-- Forever ships retail's assisted-combat API, which would make the whole
-- question moot in a different way.
local SECURE_SURFACE = {
    "SecureActionButtonTemplate", "SecureHandlerWrapScript", "SecureHandlerExecute",
    "SecureHandlerSetFrameRef", "RegisterStateDriver", "RegisterAttributeDriver",
    "SecureCmdOptionParse", "InCombatLockdown", "issecure", "issecurevariable",
    "hooksecurefunc", "forceinsecure",
    "C_AssistedCombat", "C_AssistedCombat.GetNextCastSpell", "AssistedCombatManager",
}

-- The two live plans: the economy addon and the notification bridge. This is now
-- the highest-value section of the scan - it decides both, out of combat.
--
-- The bridge half is deliberately broad. It is general-purpose tooling for talking
-- to Claude Code from inside the game, not a WoW feature, so anything that moves
-- bytes across the client boundary in either direction counts: file access, addon
-- messages, and whatever else the global dump turns up.
-- The Auction House half lives in its own section below; this is the bridge half.
local PLAN_SURFACE = {
    "C_ChatInfo.SendAddonMessage", "SendAddonMessage", "C_ChatInfo.RegisterAddonMessagePrefix",
    "io", "os", "loadstring", "require", "debug", "package",
    "C_AddOns.GetAddOnMetadata", "C_AddOns.GetAddOnLocalTable", "ReloadUI",
    "C_CVar.GetCVar", "C_CVar.SetCVar", "C_CVar.RegisterCVar", "C_CVar.SetTempCVar",
    "GetScreenWidth", "CreateFrame", "C_Timer.NewTicker",
    -- Payload handling. C_EncodingUtil is the single most useful thing the measured
    -- client turned up for this plan: JSON and CBOR both ways, base64, hex, and
    -- string compression, all in the sandbox. It turns the inbound .lua file and
    -- the outbound SavedVariables blob from ad-hoc Lua literals into a real wire
    -- format, and it is what makes an addon-message sideband worth considering.
    "C_EncodingUtil.SerializeJSON", "C_EncodingUtil.DeserializeJSON",
    "C_EncodingUtil.SerializeCBOR", "C_EncodingUtil.DeserializeCBOR",
    "C_EncodingUtil.EncodeBase64", "C_EncodingUtil.DecodeBase64",
    "C_EncodingUtil.CompressString", "C_EncodingUtil.DecompressString",
    -- Restriction probes on the outbound chat path, new in this API set.
    "C_ChatInfo.AreOutgoingAddonChatMessagesRestricted", "C_ChatInfo.InChatMessagingLockdown",
    "CopyToClipboard", "C_System.GetFrameStack",
}

-- Secrecy gates ---------------------------------------------------------------
-- C_Secrets is Blizzard's own switch for the black box, which makes it a far
-- cheaper answer to "combat-only or always-on" than inferring it from masked
-- values: ask the client directly, in both combat states, and read the gate.
-- Nothing in the 27-function secrecy surface touches the Auction House, CVars or
-- addon messages, so a true here is expected to be irrelevant to both live plans
-- - this section is the collateral-damage check, and it is the whole reason the
-- combat run still exists.
local SECRECY_CHECKS = {
    "HasSecretRestrictions", "ShouldAurasBeSecret", "ShouldCooldownsBeSecret",
    "ShouldActionCooldownBeSecret", "ShouldUnitIdentityBeSecret",
    "ShouldUnitHealthMaxBeSecret", "ShouldUnitPowerBeSecret", "ShouldUnitStatsBeSecret",
    "ShouldUnitThreatStateBeSecret", "ShouldUnitThreatValuesBeSecret",
    "ShouldUnitSpellCastBeSecret", "CanCompareUnitTokens",
}

local function probeSecrecy(label)
    local s = { inCombat = InCombatLockdown and InCombatLockdown() or false, gates = {} }
    if not C_Secrets then
        out("|cffffaa00C_Secrets ABSENT|r - this build has no secrecy gate")
        s.absent = true
    else
        local parts = {}
        for _, name in ipairs(SECRECY_CHECKS) do
            local fn = C_Secrets[name]
            if fn then
                local ok, v = pcall(function() return tostring(fn()) end)
                s.gates[name] = ok and v or ("ERR:" .. tostring(v):sub(1, 50))
                parts[#parts + 1] = (name:gsub("^Should", ""):gsub("BeSecret$", "")) .. "=" .. s.gates[name]
            end
        end
        out("|cff44ddffSECRECY|r " .. table.concat(parts, " "):sub(1, 400))
    end
    local function ask(where, fname, key)
        local tbl = _G[where]
        local fn = tbl and tbl[fname]
        if not fn then return end
        local ok, v = pcall(function() return tostring(fn()) end)
        s[key] = ok and v or ("ERR:" .. tostring(v):sub(1, 50))
        out(("  %-22s %s"):format(key, s[key]))
    end
    ask("C_CombatLog", "IsCombatLogRestricted", "combatLogRestricted")
    ask("C_RestrictedActions", "GetAddOnRestrictionState", "addonRestrictionState")
    ask("C_RestrictedActions", "IsAddOnRestrictionActive", "addonRestrictionActive")
    ask("C_ChatInfo", "AreOutgoingAddonChatMessagesRestricted", "addonMessagesRestricted")
    ask("C_ChatInfo", "InChatMessagingLockdown", "chatMessagingLockdown")
    db.secrecy = db.secrecy or {}
    db.secrecy[label] = s
    return s
end

-- Blizzard's own rotation assist. Present on the measured build with four
-- functions, which is watch trigger 4. MEASURED ONLY - this records what the API
-- returns and nothing more; the rotation helper stays shelved until Efe says
-- otherwise, and no design work hangs off this.
local function probeAssistedCombat()
    if not C_AssistedCombat then return nil end
    local a = { functions = {} }
    for _, name in ipairs({ "IsAvailable", "GetRotationSpells", "GetNextCastSpell", "GetActionSpell" }) do
        a.functions[name] = C_AssistedCombat[name] ~= nil
    end
    -- Only the no-argument reads are called. GetNextCastSpell/GetActionSpell want
    -- arguments and would be a combat-decision read, which is not what this probe
    -- is for.
    if C_AssistedCombat.IsAvailable then
        local ok, v = pcall(function() return tostring(C_AssistedCombat.IsAvailable()) end)
        a.isAvailable = ok and v or ("ERR:" .. tostring(v):sub(1, 60))
    end
    if C_AssistedCombat.GetRotationSpells then
        local ok, v = pcall(C_AssistedCombat.GetRotationSpells)
        a.rotationSpells = ok and (type(v) == "table" and #v or tostring(v)) or ("ERR:" .. tostring(v):sub(1, 60))
    end
    out(("|cffffaa00C_AssistedCombat PRESENT|r isAvailable=%s rotationSpells=%s")
        :format(tostring(a.isAvailable), tostring(a.rotationSpells)))
    out("  Blizzard ships its own rotation assist here. Recorded, not acted on.")
    db.assistedCombat = a
    return a
end

-- Auction House ---------------------------------------------------------------
-- The economy addon is the goal, so this decides the project. Checks come from
-- docs/auction-addon-architecture.md section 9.
--
-- PRESENCE ONLY. Nothing in here posts, bids, buys or cancels. The seven
-- restricted functions are scanned for existence and never called - calling them
-- would list or buy real items, which is the same reasoning that removed the
-- SendChatMessage tests. The one live request, ReplicateItems, is a read, and it
-- is still opt-in via /fprobe ah scan because it burns a 15 minute throttle.

-- Retail's C_AuctionHouse read surface (mainline 8.3.0+, Cataclysm Classic 4.4.2+).
local AH_MODERN = {
    "C_AuctionHouse.SendBrowseQuery", "C_AuctionHouse.RequestMoreBrowseResults",
    "C_AuctionHouse.GetBrowseResults", "C_AuctionHouse.SendSearchQuery",
    "C_AuctionHouse.SendSellSearchQuery",
    "C_AuctionHouse.GetNumItemSearchResults", "C_AuctionHouse.GetItemSearchResultInfo",
    "C_AuctionHouse.GetItemKeyInfo", "C_AuctionHouse.QueryOwnedAuctions",
    "C_AuctionHouse.GetOwnedAuctionInfo", "C_AuctionHouse.CalculateItemDeposit",
    "C_AuctionHouse.IsThrottledMessageSystemReady",
}

-- The commodity half of the 8.3 split. A Classic+ game could plausibly ship the
-- modern namespace WITHOUT it, in which case every stackable good is an
-- individually listed stack again and the whole pricing model changes.
local AH_COMMODITY = {
    "C_AuctionHouse.GetItemCommodityStatus",
    "C_AuctionHouse.GetNumCommoditySearchResults",
    "C_AuctionHouse.GetCommoditySearchResultInfo",
    "C_AuctionHouse.GetCommoditySearchResultsQuantity",
    "C_AuctionHouse.CalculateCommodityDeposit",
}

-- Bulk read. 15 minute account-wide throttle in retail, and anonymised since 9.0.2.
local AH_REPLICATE = {
    "C_AuctionHouse.ReplicateItems", "C_AuctionHouse.GetNumReplicateItems",
    "C_AuctionHouse.GetReplicateItemInfo",
}

-- Legacy Classic API. Not an either/or: MoP Classic carries both this and the
-- modern namespace, so scan for both and report the overlap.
local AH_LEGACY = {
    "QueryAuctionItems", "CanSendAuctionQuery", "GetNumAuctionItems",
    "GetAuctionItemInfo", "GetAuctionItemLink", "SortAuctionItems",
    "GetAuctionSellItemInfo", "GetAuctionItemTimeLeft",
}

-- The seven functions retail flags HasRestrictions, meaning #hwevent + #noscript:
-- computable in advance, but a human has to click once per action. Scanned, never
-- called. A shorter list here is interesting; a longer one would be astonishing.
local AH_RESTRICTED = {
    "C_AuctionHouse.PostItem", "C_AuctionHouse.PostCommodity",
    "C_AuctionHouse.ConfirmPostItem", "C_AuctionHouse.ConfirmPostCommodity",
    "C_AuctionHouse.PlaceBid", "C_AuctionHouse.StartCommoditiesPurchase",
    "C_AuctionHouse.CancelAuction",
}

-- Legacy equivalents of the same actions. Also never called.
local AH_LEGACY_ACTIONS = { "PlaceAuctionBid", "StartAuction", "PostAuction", "CancelAuction" }

local function packReturns(...)
    local n = select("#", ...)
    local t = { n = n }
    for i = 1, n do t[i] = (select(i, ...)) end
    return t
end

local function probeAuctionHouse()
    local ah = {}
    local function section(name, list)
        local found, missing = scan(list)
        ah[name] = { present = found, absent = missing }
        out(("  %-13s %d/%d"):format(name, #found, #found + #missing))
        return #found, #found + #missing
    end

    out("|cff44ddffAUCTION HOUSE|r")
    local nModern    = section("modern", AH_MODERN)
    local nCommodity = section("commodity", AH_COMMODITY)
    local nReplicate = section("replicate", AH_REPLICATE)
    local nLegacy    = section("legacy", AH_LEGACY)
    local nRestricted, totalRestricted = section("restricted", AH_RESTRICTED)
    section("legacyAction", AH_LEGACY_ACTIONS)

    -- 1. Which API ships, and whether the two coexist as they do in MoP Classic.
    if nModern > 0 and nLegacy > 0 then
        ah.api = "both"
        out("  |cff44ff44API|r  both - modern C_AuctionHouse AND the legacy query API, like MoP Classic")
    elseif nModern > 0 then
        ah.api = "retail"
        out("  |cff44ff44API|r  modern C_AuctionHouse only - retail AH code largely ports")
    elseif nLegacy > 0 then
        ah.api = "classic"
        out("  |cffffaa00API|r  legacy QueryAuctionItems only - paginated, ~0.3s throttle, 15min getAll")
    else
        ah.api = "none"
        out("  |cffff4444API|r  no Auction House API at all - economy plan dead as designed")
    end

    -- 2. Bulk reads. Without one of these there is no market snapshot at all,
    -- only per-item searches.
    ah.hasReplicate = nReplicate > 0
    ah.hasLegacyGetAll = lookup("CanSendAuctionQuery") ~= nil
    if not ah.hasReplicate and not ah.hasLegacyGetAll then
        out("  |cffff4444no bulk read|r - no ReplicateItems and no getAll; per-item queries only")
    end

    -- 5. The commodity split.
    ah.hasCommodities = nCommodity > 0
    if nModern > 0 and nCommodity == 0 then
        out("  |cffffaa00modern API without commodities|r - every stack is its own listing; pricing model changes")
    end

    -- 1 (continued). Compare the restricted set against retail's seven.
    ah.restrictedCount = nRestricted
    if nRestricted > 0 and nRestricted < totalRestricted then
        out("  restricted set differs from retail - absent: " ..
            table.concat(ah.restricted.absent, ", "):sub(1, 200))
    end

    ah.perPage = NUM_AUCTION_ITEMS_PER_PAGE
    ah.frames = {
        modern = lookup("AuctionHouseFrame") ~= nil,
        legacy = lookup("AuctionFrame") ~= nil,
    }

    db.auctionHouse = db.auctionHouse or {}
    for k, v in pairs(ah) do db.auctionHouse[k] = v end
    out("  stand at an auction house and run |cffffffff/fprobe ah|r for the live half")
    return ah.api
end

-- Live half. Everything below needs an open auction house window.
local ahScanFrame = CreateFrame("Frame")
local ahScan = nil

-- Retail strips owner names from replicate results (hotfixed in 9.0.2) while
-- keeping the fields, so this is a VALUE check, not a presence check. Position
-- 14/15 in the retail tuple, but a Classic+ client could return a different shape
-- entirely - keep the raw tuple so the shape can be read off it afterwards rather
-- than trusting the index.
local function sampleReplicate(limit)
    local get = C_AuctionHouse and C_AuctionHouse.GetReplicateItemInfo
    local num = C_AuctionHouse and C_AuctionHouse.GetNumReplicateItems
    if not get or not num then return 0, {}, 0, 0 end
    local ok, total = pcall(num)
    total = (ok and total) or 0
    local samples, withOwner, withoutOwner = {}, 0, 0
    local stringFields = {}
    local last = total
    if limit < last then last = limit end
    for i = 0, last - 1 do
        local gotInfo, info = pcall(function() return packReturns(get(i)) end)
        if gotInfo then
            -- 14/15 is the RETAIL tuple position for owner and ownerFullName. A
            -- Classic+ client can return a different shape entirely, so the index
            -- check is only a first guess: every string field is also recorded, and
            -- the raw tuple is kept so the real shape can be read off afterwards
            -- rather than trusted.
            local owner, ownerFull = info[14], info[15]
            local strIdx = {}
            for k = 1, info.n do
                if type(info[k]) == "string" then strIdx[#strIdx + 1] = k end
            end
            stringFields[table.concat(strIdx, ",")] = (stringFields[table.concat(strIdx, ",")] or 0) + 1
            if owner ~= nil or ownerFull ~= nil then
                withOwner = withOwner + 1
            else
                withoutOwner = withoutOwner + 1
            end
            if #samples < 5 then
                local parts = {}
                for k = 1, info.n do parts[k] = k .. "=" .. tostring(info[k]) end
                samples[#samples + 1] = {
                    index = i, returns = info.n,
                    owner = tostring(owner), ownerFullName = tostring(ownerFull),
                    tuple = table.concat(parts, " "):sub(1, 400),
                }
            end
        end
    end
    return total, samples, withOwner, withoutOwner, stringFields
end

local function finishReplicateScan()
    if not ahScan or ahScan.done then return end
    ahScan.done = true
    ahScanFrame:UnregisterEvent("REPLICATE_ITEM_LIST_UPDATE")

    local total, samples, withOwner, withoutOwner, stringFields = sampleReplicate(500)
    ahScan.total, ahScan.samples = total, samples
    ahScan.ownersPresent, ahScan.ownersNil = withOwner, withoutOwner
    ahScan.stringFieldLayouts = stringFields

    db.auctionHouse = db.auctionHouse or {}
    db.auctionHouse.scan = ahScan

    if total == 0 and ahScan.updates == 0 then
        out("  |cffff4444no update event and 0 items|r - throttled, unsupported, or the AH window was shut")
    else
        out(("  |cff44ff44replicate scan|r %d auctions, %d update events, first response %.1fs, last %.1fs")
            :format(total, ahScan.updates, ahScan.elapsed or -1, ahScan.lastUpdateAt or -1))
        local peak = 0
        for _, n in pairs(ahScan.perTenth or {}) do if n > peak then peak = n end end
        out(("  peak %d update events in one 0.1s bucket (retail caps around 2000 per frame)"):format(peak))
        out(("  owner names at retail index 14/15: %d with, %d nil (retail returns nil since 9.0.2)")
            :format(withOwner, withoutOwner))
        for layout, n in pairs(stringFields) do
            out(("  string fields at indices [%s] in %d rows"):format(layout, n))
        end
        if samples[1] then
            out(("  shape: %d returns | %s"):format(samples[1].returns, samples[1].tuple:sub(1, 150)))
        end
    end
end

ahScanFrame:SetScript("OnEvent", function(_, event)
    if event ~= "REPLICATE_ITEM_LIST_UPDATE" or not ahScan or ahScan.done then return end
    ahScan.updates = ahScan.updates + 1
    ahScan.lastUpdateAt = GetTime() - ahScan.startedAt
    -- Retail caps REPLICATE_ITEM_LIST_UPDATE at roughly 2000 per frame. Bucketing
    -- by frame time shows whether Forever does the same, which is the difference
    -- between a scan that stalls the client and one that does not.
    local bucket = math.floor(ahScan.lastUpdateAt * 10)
    ahScan.perTenth = ahScan.perTenth or {}
    ahScan.perTenth[bucket] = (ahScan.perTenth[bucket] or 0) + 1
    if ahScan.updates == 1 then ahScan.elapsed = GetTime() - ahScan.startedAt end
end)

local function ahReplicateScan()
    if not (C_AuctionHouse and C_AuctionHouse.ReplicateItems) then
        out("|cffff4444no C_AuctionHouse.ReplicateItems|r - nothing to scan. The probe deliberately does")
        out("  not fire a legacy getAll: it can disconnect the client and burns 15 minutes either way.")
        return
    end
    -- ReplicateItems does nothing useful with the window shut, and a wasted call
    -- still burns the throttle, so say so rather than reporting an empty result.
    local open = (AuctionHouseFrame and AuctionHouseFrame:IsShown())
        or (AuctionFrame and AuctionFrame:IsShown()) or false
    if not open then
        out("|cffffaa00auction house window is not open|r - open it first; a wasted call still burns the throttle")
        return
    end

    db.auctionHouse = db.auctionHouse or {}
    local history = db.auctionHouse.scanHistory or {}
    if history[#history] then
        out(("  last scan was %d seconds ago (retail throttle is 900)"):format(time() - history[#history]))
    end
    history[#history + 1] = time()
    db.auctionHouse.scanHistory = history

    ahScan = { updates = 0, startedAt = GetTime(), requestedAt = time(), done = false }
    safeRegister(ahScanFrame, "REPLICATE_ITEM_LIST_UPDATE")

    activeTest = "ReplicateItems"
    local ok, err = pcall(C_AuctionHouse.ReplicateItems)
    activeTest = nil
    local blocked = blocksFor("ReplicateItems")
    ahScan.callOk = ok
    ahScan.callErr = (not ok) and tostring(err):sub(1, 200) or nil
    ahScan.blockEvents = (#blocked > 0) and blocked or nil
    out(("  ReplicateItems() %s%s"):format(
        ok and "called" or ("ERR " .. tostring(err):sub(1, 60)),
        (#blocked > 0) and (" [" .. blocked[1] .. "]") or ""))

    if C_Timer and C_Timer.After then
        out("  waiting 12s for the list...")
        C_Timer.After(12, finishReplicateScan)
    else
        finishReplicateScan()
    end
end

local function ahLiveReads()
    local live = {}
    live.auctionFrameOpen = (AuctionHouseFrame and AuctionHouseFrame:IsShown())
        or (AuctionFrame and AuctionFrame:IsShown()) or false
    if not live.auctionFrameOpen then
        out("  |cffffaa00auction house window is not open|r - open it and run /fprobe ah again")
    end

    if CanSendAuctionQuery then
        local ok, canQuery, canQueryAll = pcall(CanSendAuctionQuery)
        if ok then
            live.canQuery, live.canQueryAll = canQuery, canQueryAll
            out(("  CanSendAuctionQuery   query=%s getAll=%s"):format(tostring(canQuery), tostring(canQueryAll)))
        end
    end
    if C_AuctionHouse and C_AuctionHouse.IsThrottledMessageSystemReady then
        local ok, ready = pcall(C_AuctionHouse.IsThrottledMessageSystemReady)
        if ok then live.throttleReady = ready end
        out("  throttleSystemReady   " .. tostring(ok and ready))
    end

    -- Legacy owner check, read off whatever page the player already has open. No
    -- query is sent, so this costs nothing and cannot disconnect anyone.
    if GetNumAuctionItems and GetAuctionItemInfo then
        local ok, batch, total = pcall(GetNumAuctionItems, "list")
        if ok then
            live.legacyBatch, live.legacyTotal = batch, total
            out(("  GetNumAuctionItems    batch=%s total=%s"):format(tostring(batch), tostring(total)))
            if (batch or 0) > 0 then
                local gotInfo, info = pcall(function() return packReturns(GetAuctionItemInfo("list", 1)) end)
                if gotInfo then
                    local parts = {}
                    for k = 1, info.n do parts[k] = k .. "=" .. tostring(info[k]) end
                    live.legacyReturns = info.n
                    live.legacySample = table.concat(parts, " "):sub(1, 400)
                    live.legacyOwner = tostring(info[14])
                    live.legacyOwnerFullName = tostring(info[15])
                    out(("  legacy owner fields   %s / %s"):format(tostring(info[14]), tostring(info[15])))
                end
            end
        end
    end

    if C_AuctionHouse and C_AuctionHouse.GetNumReplicateItems then
        local ok, n = pcall(C_AuctionHouse.GetNumReplicateItems)
        live.replicateCached = ok and n or nil
        out("  replicate cache       " .. tostring(ok and n))
    end

    live.perPage = NUM_AUCTION_ITEMS_PER_PAGE
    db.auctionHouse = db.auctionHouse or {}
    db.auctionHouse.live = live
end

-- Auction House measurement --------------------------------------------------
-- Presence is settled: docs/findings.md section 0.1 read the modern namespace off
-- a capture of this exact build. What is NOT settled is every number, and the
-- numbers are what decide the addon's data model:
--
--   * how much of the market one browse query can return, and at what cost
--   * the real ReplicateItems throttle, which retail documents as 900s
--   * whether replicate results still carry owner names (retail stripped them in
--     9.0.2) - that decides whether the addon can attribute listings at all
--   * how fast results arrive, which decides whether a scan is a background task
--     or a thing the player waits for
--
-- None of this can be inferred from a function list. All of it is a read.
-- Nothing here posts, bids, buys or cancels.

local AH_EVENTS = {
    "AUCTION_HOUSE_SHOW", "AUCTION_HOUSE_CLOSED",
    "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED", "AUCTION_HOUSE_BROWSE_RESULTS_ADDED",
    "AUCTION_HOUSE_BROWSE_FAILURE", "AUCTION_HOUSE_THROTTLED_SYSTEM_READY",
    "COMMODITY_SEARCH_RESULTS_UPDATED", "ITEM_SEARCH_RESULTS_UPDATED",
}

local ahEvents = CreateFrame("Frame")
local ahEventSupport, ahEventCount = {}, {}
for _, e in ipairs(AH_EVENTS) do
    ahEventSupport[e] = safeRegister(ahEvents, e) and true or false
end

-- Browse measurement state. Deliberately a plain table rather than a closure so
-- the whole thing lands in SavedVariables exactly as measured.
local browse = nil

local function browseCount()
    local f = C_AuctionHouse and C_AuctionHouse.GetBrowseResults
    if not f then return -1 end
    local ok, r = pcall(f)
    if not ok or type(r) ~= "table" then return -1 end
    return #r
end

local function browseIsFull()
    local f = C_AuctionHouse and C_AuctionHouse.HasFullBrowseResults
    if not f then return nil end
    local ok, v = pcall(f)
    -- Not `ok and v or nil`: a legitimate false would collapse to nil there, and
    -- "the client says the results are incomplete" is the single most important
    -- answer this whole measurement produces.
    if not ok then return nil end
    return v
end

local function browseRound(reason)
    if not browse or browse.done then return end
    local n, full = browseCount(), browseIsFull()
    browse.rounds[#browse.rounds + 1] = {
        reason = reason,
        at = GetTime() - browse.startedAt,
        results = n,
        gained = n - (browse.lastCount or 0),
        full = tostring(full),
    }
    browse.lastCount = n
    browse.full = full
end

ahEvents:SetScript("OnEvent", function(_, event)
    ahEventCount[event] = (ahEventCount[event] or 0) + 1

    -- The throttle, measured rather than assumed. Retail documents 900 seconds
    -- account-wide between successful ReplicateItems calls; this records what
    -- Forever actually does by timing the gap from the request to the client
    -- saying it is ready again. Note this only survives a /reload if the client
    -- reads SavedVariables back, which on this build it reportedly does not - so
    -- do the scan and the wait in ONE session.
    if event == "AUCTION_HOUSE_THROTTLED_SYSTEM_READY" then
        db.auctionHouse = db.auctionHouse or {}
        local t = db.auctionHouse.throttle or {}
        t.readyAt = time()
        local history = db.auctionHouse.scanHistory
        local last = history and history[#history]
        if last then
            t.secondsSinceLastScan = t.readyAt - last
            out(("|cff44ddffAH|r throttle cleared %d seconds after the last scan (retail: 900)")
                :format(t.secondsSinceLastScan))
        end
        db.auctionHouse.throttle = t
        return
    end

    if event == "AUCTION_HOUSE_BROWSE_FAILURE" then
        if browse then browse.failed = true end
        out("|cffff4444browse query FAILED|r")
        return
    end
    if event == "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED" or event == "AUCTION_HOUSE_BROWSE_RESULTS_ADDED" then
        browseRound(event == "AUCTION_HOUSE_BROWSE_RESULTS_ADDED" and "added" or "updated")
    end
end)

local function finishBrowse()
    if not browse or browse.done then return end
    browse.done = true
    browse.elapsed = GetTime() - browse.startedAt
    browse.total = browseCount()
    browse.events = {}
    for k, v in pairs(ahEventCount) do browse.events[k] = v end

    db.auctionHouse = db.auctionHouse or {}
    db.auctionHouse.browse = browse

    out(("|cff44ff44browse|r %d results in %.1fs over %d rounds, full=%s%s")
        :format(browse.total, browse.elapsed, #browse.rounds, tostring(browse.full),
                browse.failed and " |cffff4444(a query failed)|r" or ""))
    if browse.total >= 0 and browse.full == false then
        out("  |cffffaa00not complete|r - this is a per-query cap, not the size of the market")
    end
    for i, r in ipairs(browse.rounds) do
        if i <= 8 then
            out(("    round %d %-7s %.1fs  %d results (+%d) full=%s")
                :format(i, r.reason, r.at, r.results, r.gained, r.full))
        end
    end
end

-- Cheap, repeatable, and NOT the 15-minute throttle: an empty-filter browse is
-- what every modern auction addon actually uses, so its cap and cadence matter
-- more to the design than ReplicateItems does.
local function ahBrowseMeasure(rounds)
    if not (C_AuctionHouse and C_AuctionHouse.SendBrowseQuery) then
        out("|cffff4444no C_AuctionHouse.SendBrowseQuery|r")
        return
    end
    local open = (AuctionHouseFrame and AuctionHouseFrame:IsShown()) or false
    if not open then
        out("|cffffaa00auction house window is not open|r - open it first")
        return
    end

    rounds = tonumber(rounds) or 6
    browse = { startedAt = GetTime(), rounds = {}, lastCount = 0, requested = rounds }

    activeTest = "SendBrowseQuery"
    local ok, err = pcall(C_AuctionHouse.SendBrowseQuery, {
        searchString = "", sorts = {}, filters = {}, itemClassFilters = {},
    })
    activeTest = nil
    browse.callOk = ok
    browse.callErr = (not ok) and tostring(err):sub(1, 200) or nil
    local blocked = blocksFor("SendBrowseQuery")
    browse.blockEvents = (#blocked > 0) and blocked or nil
    if not ok then
        out("|cffff4444SendBrowseQuery ERR|r " .. tostring(err):sub(1, 120))
        return
    end
    out(("browse query sent, pulling %d more-result rounds..."):format(rounds))

    -- Walk RequestMoreBrowseResults on a timer. Each round is spaced enough for
    -- the server to answer, and the walk stops early once the client says the
    -- results are complete - the round it stops on IS the per-query cap.
    local i = 0
    local function step()
        i = i + 1
        if not browse or browse.done then return end
        if browse.full == true or i > rounds then return finishBrowse() end
        if C_AuctionHouse.RequestMoreBrowseResults then
            local okMore = pcall(C_AuctionHouse.RequestMoreBrowseResults)
            if not okMore then return finishBrowse() end
            browseRound("requested")
        end
        C_Timer.After(1.5, step)
    end
    C_Timer.After(1.5, step)
end

-- The one call that costs something. Retail: 15 minute account-wide throttle,
-- anonymised since 9.0.2, and a per-frame event cap around 2000.
local function ahThrottleReport()
    db.auctionHouse = db.auctionHouse or {}
    local t = db.auctionHouse.throttle or {}
    local history = db.auctionHouse.scanHistory or {}
    local last = history[#history]
    out("|cff44ddffAH throttle|r")
    out("  events supported: " .. (ahEventSupport["AUCTION_HOUSE_THROTTLED_SYSTEM_READY"]
        and "AUCTION_HOUSE_THROTTLED_SYSTEM_READY yes" or "|cffffaa00no THROTTLED_SYSTEM_READY event|r"))
    if C_AuctionHouse and C_AuctionHouse.IsThrottledMessageSystemReady then
        local ok, ready = pcall(C_AuctionHouse.IsThrottledMessageSystemReady)
        out("  ready right now:  " .. tostring(ok and ready))
    end
    if last then
        out(("  last scan:        %d seconds ago"):format(time() - last))
    else
        out("  last scan:        none this session")
    end
    if t.secondsSinceLastScan then
        out(("  |cff44ff44measured throttle: %d seconds|r (retail is 900)"):format(t.secondsSinceLastScan))
    else
        out("  measured throttle: not yet - run /fprobe ah scan, stay logged in, and watch for the")
        out("  'throttle cleared' line. It prints itself when the client says the system is ready.")
    end
    for _, e in ipairs(AH_EVENTS) do
        if not ahEventSupport[e] then out("  |cffffaa00unsupported event:|r " .. e) end
    end
    db.auctionHouse.eventCounts = ahEventCount
    db.auctionHouse.eventSupport = ahEventSupport
end

-- Shapes that decide how the addon stores what it reads. All cheap reads off
-- whatever the client already has cached.
local function ahShapes()
    local shapes = {}
    local function record(name, fn)
        local ok, v = pcall(function() return fn() end)
        if not ok then shapes[name] = "ERR: " .. tostring(v):sub(1, 80); return end
        if type(v) == "table" then
            local parts = {}
            for k, val in pairs(v) do
                parts[#parts + 1] = tostring(k) .. "=" .. tostring(val)
                if #parts >= 12 then break end
            end
            shapes[name] = table.concat(parts, " "):sub(1, 300)
        else
            shapes[name] = tostring(v)
        end
        out(("  %-22s %s"):format(name, tostring(shapes[name]):sub(1, 60)))
    end

    -- Time-left bands are the whole basis of "is this listing about to expire",
    -- and a Classic+ title could easily ship different bands from retail's four.
    if C_AuctionHouse and C_AuctionHouse.GetTimeLeftBandInfo then
        for band = 1, 5 do
            record("timeLeftBand" .. band, function() return C_AuctionHouse.GetTimeLeftBandInfo(band) end)
        end
    end
    -- Item keys are the join key for every price record the addon will ever keep.
    if C_AuctionHouse and C_AuctionHouse.GetItemKeyFromItem then
        record("itemKeyFromItem(2589)", function() return C_AuctionHouse.GetItemKeyFromItem(2589) end)
    end
    if C_AuctionHouse and C_AuctionHouse.GetAvailablePostCount then
        record("availablePostCount", function() return C_AuctionHouse.GetAvailablePostCount(2589) end)
    end
    if C_AuctionHouse and C_AuctionHouse.GetItemCommodityStatus then
        record("commodityStatus(2589)", function()
            return C_AuctionHouse.GetItemCommodityStatus(C_AuctionHouse.GetItemKeyFromItem(2589))
        end)
    end
    db.auctionHouse = db.auctionHouse or {}
    db.auctionHouse.shapes = shapes
end

-- Bridge report ---------------------------------------------------------------
local function printBridge()
    db.bridge = db.bridge or {}

    out("|cff44ddffBRIDGE inbound|r (BridgeData.lua, executed at load)")
    local tags, entries = {}, 0
    for tag, list in pairs(bridgeInbox) do
        tags[#tags + 1] = tag .. "(" .. #list .. ")"
        entries = entries + #list
    end
    table.sort(tags)
    local def = bridgeInbox["default"] and bridgeInbox["default"][1]
    local untouched = (def and def[1] == "unmodified" and entries == 1) and true or false

    if entries == 0 then
        out("  |cffff4444nothing received|r - BridgeData.lua is missing from the .toc or failed to load")
    elseif untouched then
        out("  |cffffaa00shipped default only|r - the file loads and the channel works, but nothing has")
        out("  written to it yet. Run scripts/write-bridge-data.ps1, then /reload.")
    else
        out("  |cff44ff44external write received:|r " .. table.concat(tags, " "))
        for tag, list in pairs(bridgeInbox) do
            local first = list[1]
            if first then
                local parts = {}
                for i = 1, #first do parts[i] = tostring(first[i]) end
                out(("    %s -> %s"):format(tag, table.concat(parts, ", "):sub(1, 120)))
            end
        end
    end
    db.bridge.inbox = bridgeInbox
    db.bridge.inboxEntries = entries
    db.bridge.untouched = untouched

    out("|cff44ddffBRIDGE outbound|r (SavedVariables flush)")
    -- Two different failures look identical from in here, and they have opposite
    -- consequences for the bridge:
    --   a) the client never WROTE the file           -> outbound is dead
    --   b) the client wrote it and never READ it back -> outbound is fine, and the
    --      round trip inside the client is what is broken
    -- (b) is a reported beta bug on this build, so the in-game verdict is only
    -- half the answer; collect-savedvars.ps1 looking at the file on disk is the
    -- other half, and it is the one that decides the plan.
    if db.bridge.tokenFromPreviousSession then
        out("  |cff44ff44confirmed|r - last session's token survived: " .. tostring(db.bridge.tokenFromPreviousSession))
    elseif (db.bridge.loads or 0) > 1 then
        out("  |cffff4444read-back failed|r - this DB has seen " .. tostring(db.bridge.loads) ..
            " loads but no token survived")
    else
        out("  |cffffaa00first load of this DB|r - /reload, then /fprobe bridge again.")
        out("  If the load counter is STILL 1 afterwards, the client is not reading SavedVariables")
        out("  back at all (known beta bug). Run scripts/collect-savedvars.ps1 to see whether the")
        out("  file was nonetheless written - that is what decides the outbound half.")
    end
    out("  loads recorded by this DB: " .. tostring(db.bridge.loads or 0))
    db.bridge.tokenWrittenThisSession = ("%s-%d"):format(
        date and date("%H%M%S") or tostring(time()), math.random(1000, 9999))
    out("  wrote token " .. db.bridge.tokenWrittenThisSession .. " - it should reappear after /reload")
end

local function printBlocked()
    out("|cff44ddffBLOCKED / FORBIDDEN actions captured|r")
    if #blockLog == 0 then
        out("  none this session")
    end
    for i, b in ipairs(blockLog) do
        out(("  %d. |cffff4444%s|r func=%s during: %s")
            :format(i, tostring(b.event), tostring(b.func), tostring(b.test)))
    end
    local anyReg = false
    for event, hit in pairs(registerBlocked) do
        anyReg = true
        out(("  |cffffaa00addons may not register|r %s  [%s]"):format(event, hit))
    end
    if anyReg then
        out("  ^ this is a READ restriction at the event level - the addon is not")
        out("  allowed to listen at all, which is stronger than masked return values.")
    end
    db.blockLog = blockLog
    db.registerBlocked = registerBlocked
end

local function probeSurfaces()
    local sections = {
        read = READ_SURFACE, execute = EXECUTE_SURFACE,
        secure = SECURE_SURFACE, plans = PLAN_SURFACE,
    }
    db.surfaces = {}
    for name, list in pairs(sections) do
        local found, missing = scan(list)
        db.surfaces[name] = { present = found, absent = missing }
        out(("%-8s %d/%d present"):format(name, #found, #found + #missing))
        if name == "read" and #missing > 0 then
            out("  |cffffaa00missing read APIs:|r " .. table.concat(missing, ", "):sub(1, 220))
        end
    end
    probeAssistedCombat()
    probeSecrecy("outofcombat")
    if #registerFailures > 0 then
        db.registerFailures = registerFailures
        out("|cffffaa00events this client does not have:|r " .. table.concat(registerFailures, ", "):sub(1, 200))
    end
    printBlocked()

    -- Verdicts for the two live plans, so one out-of-combat run settles them
    -- without needing the combat pass at all.
    local verdict = {}
    verdict.auctionHouse = probeAuctionHouse()

    verdict.export = {
        io = lookup("io") ~= nil, os = lookup("os") ~= nil,
        loadstring = (lookup("loadstring") or lookup("load")) ~= nil,
        addonMessage = (lookup("C_ChatInfo.SendAddonMessage") or lookup("SendAddonMessage")) ~= nil,
        cvar = (lookup("C_CVar.SetCVar") or lookup("SetCVar")) ~= nil,
    }
    out(("|cff44ddffBRIDGE|r  io=%s os=%s load=%s addonMsg=%s cvar=%s")
        :format(tostring(verdict.export.io), tostring(verdict.export.os),
                tostring(verdict.export.loadstring), tostring(verdict.export.addonMessage),
                tostring(verdict.export.cvar)))
    verdict.export.encoding = (lookup("C_EncodingUtil.SerializeJSON") ~= nil)
    verdict.export.clipboard = (lookup("CopyToClipboard") ~= nil)
    out(("           json=%s clipboard=%s reloadUI=%s")
        :format(tostring(verdict.export.encoding), tostring(verdict.export.clipboard),
                tostring(lookup("ReloadUI") ~= nil)))
    if not verdict.export.io then
        out("  outbound is SavedVariables on /reload; inbound is a generated .lua run as addon code")
    end
    -- ReloadUI exists but is reported protected on this build, which breaks an
    -- unattended loop: a human has to type /reload for every inbound refresh.
    -- Never CALLED here - calling it would reload the UI mid-probe and throw away
    -- the run. Presence plus the restriction state is all that is wanted.
    verdict.export.reloadUIPresent = lookup("ReloadUI") ~= nil

    db.planVerdict = verdict
end

-- Full global dump, for diffing against retail and Classic Era later.
local function probeGlobals()
    local funcs, namespaces, n = {}, {}, 0
    for k, v in pairs(_G) do
        if type(v) == "function" then
            funcs[#funcs + 1] = k
            n = n + 1
        elseif type(v) == "table" and type(k) == "string" and k:match("^C_") then
            local members = {}
            for mk, mv in pairs(v) do
                if type(mv) == "function" then members[#members + 1] = mk end
            end
            table.sort(members)
            namespaces[k] = members
        end
    end
    table.sort(funcs)
    db.globalFunctions, db.namespaces = funcs, namespaces
    local nsCount = 0
    for _ in pairs(namespaces) do nsCount = nsCount + 1 end
    out(("global dump: %d functions, %d C_ namespaces"):format(n, nsCount))
end

-- Action tests ----------------------------------------------------------------
-- Run identically in and out of combat. The DELTA is the answer: blocked in both
-- is a flat ban, blocked only in combat matches retail and is irrelevant to a
-- suggest-only rotation helper.
local function runActionTests()
    local inCombat = InCombatLockdown and InCombatLockdown() or false
    local label = inCombat and "incombat" or "outofcombat"
    local results = { inCombat = inCombat, secure = issecure and issecure() or nil, tests = {} }

    local function try(name, fn)
        activeTest = name
        local ok, err = pcall(fn)
        activeTest = nil
        local blocked = blocksFor(name)
        local allowed = ok and #blocked == 0
        results.tests[name] = {
            ok = ok,
            err = (not ok) and tostring(err):sub(1, 200) or nil,
            blockEvents = (#blocked > 0) and blocked or nil,
            allowed = allowed,
        }
        out(("  %-28s %s%s"):format(name,
            allowed and "|cff44ff44allowed|r" or "|cffff4444BLOCKED|r",
            (#blocked > 0) and (" [" .. blocked[1] .. "]") or
            ((not ok) and (" - " .. tostring(err):sub(1, 60)) or "")))
    end

    -- A harmless, always-known spell so the test is about permission, not validity.
    local probeSpell = nil
    do
        local ok, v = pcall(function()
            if C_Spell and C_Spell.GetSpellInfo then
                local info = C_Spell.GetSpellInfo(1)
                return info and info.name
            elseif GetSpellInfo then
                return (GetSpellInfo(1))
            end
        end)
        probeSpell = ok and v or nil
    end

    if CastSpellByName then
        try("CastSpellByName", function() CastSpellByName(probeSpell or "Attack") end)
    end
    if UseAction then
        try("UseAction(slot1)", function() UseAction(1) end)
    end
    if RunMacroText then
        try("RunMacroText(/cast)", function() RunMacroText("/cast " .. (probeSpell or "Attack")) end)
    end
    if EditMacro then
        try("EditMacro", function() EditMacro(1, nil, nil, "/cast " .. (probeSpell or "Attack")) end)
    end
    if SetOverrideBindingClick then
        try("SetOverrideBindingClick", function()
            SetOverrideBindingClick(watcher, true, "F12", "ForeverProbeSecureBtn")
        end)
    end

    -- The legitimate path: retarget a secure button the player clicks themselves.
    -- Out of combat this should succeed; retail blocks it in combat. This one test
    -- decides whether a one-button "press this next" helper is possible at all.
    if not _G.ForeverProbeSecureBtn then
        local btn = CreateFrame("Button", "ForeverProbeSecureBtn", UIParent, "SecureActionButtonTemplate")
        btn:Hide()
        btn:SetAttribute("type", "spell")
    end
    try("SecureBtn:SetAttribute", function()
        _G.ForeverProbeSecureBtn:SetAttribute("spell", probeSpell or "Attack")
    end)

    -- READ TESTS - now the crux.
    --
    -- Blizzard's disarmament doctrine describes combat state as a "black box":
    -- addons may restyle the box but not look inside, specifically losing the
    -- ability to know target auras, cooldown states, and real-time combat events.
    -- A black box does NOT throw errors. The functions stay present and return
    -- nil, zero, or masked data once combat starts. So record the actual VALUES
    -- and diff them across the two runs rather than asking whether the call
    -- succeeded, which would report a false "allowed" every time.
    local reads = {}
    local function readTest(name, fn)
        -- The conversion happens INSIDE the pcall. A secret value throws on
        -- tostring(), on comparison, and even on a boolean test, so converting
        -- outside would take the whole probe down mid-run rather than recording
        -- the restriction. Measured: in-combat aura reads throw, they do not
        -- return nil.
        local ok, v = pcall(function() return tostring(fn()) end)
        reads[name] = ok and v or ("ERR: " .. tostring(v):sub(1, 80))
        out(("  READ %-22s %s"):format(name, reads[name]:sub(1, 48)))
    end

    readTest("spellCooldownStart", function()
        local f = (C_Spell and C_Spell.GetSpellCooldown) or GetSpellCooldown
        if not f then return "NO API" end
        local r = f(probeSpell or 1)
        if type(r) == "table" then return r.startTime end
        return r
    end)
    readTest("playerPower", function() return UnitPower("player") end)
    readTest("playerAura1", function()
        if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
            local a = C_UnitAuras.GetAuraDataByIndex("player", 1, "HELPFUL")
            return a and (a.name or a.spellId) or "nil"
        elseif UnitAura then
            return (UnitAura("player", 1)) or "nil"
        end
        return "NO API"
    end)
    -- Target auras are the specific thing the doctrine names as no longer knowable.
    readTest("targetAura1", function()
        if not UnitExists or not UnitExists("target") then return "NO TARGET" end
        if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
            local a = C_UnitAuras.GetAuraDataByIndex("target", 1, "HARMFUL")
            return a and (a.name or a.spellId) or "nil"
        elseif UnitAura then
            return (UnitAura("target", 1, "HARMFUL")) or "nil"
        end
        return "NO API"
    end)
    readTest("targetHealth", function()
        return UnitExists and UnitExists("target") and UnitHealth("target") or "NO TARGET"
    end)
    readTest("targetCasting", function()
        return UnitExists and UnitExists("target") and (UnitCastingInfo("target") or "nil") or "NO TARGET"
    end)
    readTest("combatLogAPI", function()
        return CombatLogGetCurrentEventInfo and "present" or "ABSENT"
    end)
    results.reads = reads

    probeSecrecy(label)

    db.actions = db.actions or {}
    db.actions[label] = results
    db.blockLog = blockLog
    db.combatLog = clog
    out(("combat log: registered=%s reader=%s fired=%d readable=%d inCombat=%d subevents=%d")
        :format(tostring(clog.registered), tostring(clog.readerPresent),
                clog.eventFired or 0, clog.count, clog.inCombatCount, (function()
            local n = 0; for _ in pairs(clog.subevents) do n = n + 1 end; return n
        end)()))
    out(("recorded as '%s'"):format(label))
end

-- Report ----------------------------------------------------------------------
local function printReport()
    local a = db.actions or {}
    if not a.outofcombat or not a.incombat then
        out("need both runs. have: " ..
            (a.outofcombat and "out-of-combat " or "") .. (a.incombat and "in-combat" or "neither"))
        return
    end
    local flatBan, combatOnly = {}, {}
    for name, oo in pairs(a.outofcombat.tests) do
        local ic = a.incombat.tests[name]
        if ic then
            if not oo.allowed and not ic.allowed then flatBan[#flatBan + 1] = name
            elseif oo.allowed and not ic.allowed then combatOnly[#combatOnly + 1] = name end
        end
    end
    table.sort(flatBan); table.sort(combatOnly)
    out("|cffffffffACTIONS - out of combat vs in combat:|r")
    out("  blocked ONLY in combat (retail-normal): " ..
        (#combatOnly > 0 and table.concat(combatOnly, ", ") or "none"))
    out("  blocked in BOTH states: " ..
        (#flatBan > 0 and table.concat(flatBan, ", ") or "none"))

    -- The read diff is the one that decides whether a rotation helper is possible.
    -- A value that is readable out of combat and nil/blank in combat is the black
    -- box closing, which is a different and much harder restriction than a
    -- blocked action.
    local masked = {}
    for name, ooVal in pairs(a.outofcombat.reads or {}) do
        local icVal = (a.incombat.reads or {})[name]
        if icVal and icVal ~= ooVal then
            local looksMasked = (icVal == "nil" or icVal == "0" or icVal == "" or icVal:match("^ERR"))
                and not (ooVal == "nil" or ooVal == "0" or ooVal == "")
            if looksMasked then masked[#masked + 1] = name .. " (" .. ooVal:sub(1, 16) .. " -> " .. icVal:sub(1, 16) .. ")" end
        end
    end
    table.sort(masked)
    out("|cffffffffREADS - data lost on entering combat:|r")
    if #masked > 0 then
        out("  |cffff4444BLACK BOX CONFIRMED:|r " .. table.concat(masked, ", "))
        out("  |cffff4444rotation helper not viable as designed|r")
    else
        out("  |cff44ff44none - combat state stayed readable|r")
    end
    -- The secrecy delta is the direct answer to the combat-only-vs-always-on
    -- question, straight from Blizzard's own gate rather than inferred from
    -- masked values. A gate that is false out of combat and true in combat is a
    -- combat-scoped black box, which leaves both live plans untouched.
    local sOut, sIn = (db.secrecy or {}).outofcombat, (db.secrecy or {}).incombat
    if sOut and sIn and sOut.gates and sIn.gates then
        local gatesOn, alwaysOn = {}, {}
        for name, v in pairs(sOut.gates) do
            local iv = sIn.gates[name]
            if iv == "true" and v ~= "true" then gatesOn[#gatesOn + 1] = name
            elseif iv == "true" and v == "true" then alwaysOn[#alwaysOn + 1] = name end
        end
        table.sort(gatesOn); table.sort(alwaysOn)
        out("|cffffffffSECRECY - C_Secrets gates:|r")
        out("  closed only IN COMBAT: " .. (#gatesOn > 0 and table.concat(gatesOn, ", ") or "none"))
        out("  closed in BOTH states: " .. (#alwaysOn > 0 and table.concat(alwaysOn, ", ") or "none"))
        if #alwaysOn == 0 then
            out("  |cff44ff44black box is combat-scoped|r - nothing is secret out of combat")
        else
            out("  |cffff4444some gates are always on|r - re-check both live plans for collateral reads")
        end
        db.secrecyDelta = { combatOnly = gatesOn, alwaysOn = alwaysOn }
    end
    out(("  combat log: %d events, %d in combat%s"):format(
        (db.combatLog and db.combatLog.count) or 0,
        (db.combatLog and db.combatLog.inCombatCount) or 0,
        (db.combatLog and db.combatLog.error) and (" |cffff4444ERR: " .. db.combatLog.error .. "|r") or ""))

    db.delta = { combatOnly = combatOnly, flatBan = flatBan, maskedReads = masked }
end

-- Driver ----------------------------------------------------------------------
SLASH_FPROBE1 = "/fprobe"
SlashCmdList.FPROBE = function(arg)
    local cmd, sub, extra = ((arg or ""):lower()):match("^%s*(%S*)%s*(%S*)%s*(%S*)")
    cmd, sub = cmd or "", sub or ""
    if cmd == "report" then return printReport() end
    if cmd == "blocked" then return printBlocked() end
    if cmd == "bridge" then return printBridge() end
    if cmd == "ah" then
        if sub == "scan" then return ahReplicateScan() end
        if sub == "browse" then return ahBrowseMeasure(extra) end
        if sub == "throttle" then return ahThrottleReport() end
        probeAuctionHouse()
        ahLiveReads()
        out("|cff44ddffshapes|r")
        ahShapes()
        ahThrottleReport()
        out("measure the numbers:")
        out("  |cffffffff/fprobe ah browse|r    cheap, repeatable - per-query cap and cadence")
        out("  |cffffffff/fprobe ah scan|r      full ReplicateItems scan, burns the 15 min throttle")
        out("  |cffffffff/fprobe ah throttle|r  what the throttle actually turned out to be")
        return
    end
    if cmd == "combat" then
        if not (InCombatLockdown and InCombatLockdown()) then
            out("|cffffaa00not in combat - will be labelled out-of-combat|r")
        end
        runActionTests()
        printReport()
        return
    end
    db.timestamp = date and date("%Y-%m-%d %H:%M:%S") or time()
    local version, build, _, toc = GetBuildInfo()
    db.build = { version = version, build = build, tocversion = toc }
    out(("build %s (%s) toc %s"):format(tostring(version), tostring(build), tostring(toc)))
    probeSurfaces()
    probeGlobals()
    printBridge()
    out("action tests:")
    runActionTests()
    out("next: |cffffffff/fprobe ah|r at an auction house, |cffffffff/fprobe combat|r on a mob, then /reload.")
end
