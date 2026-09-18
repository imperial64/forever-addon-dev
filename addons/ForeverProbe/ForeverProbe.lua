-- Forever Probe
--
-- Records the addon API surface of WoW Forever and measures what the client
-- actually permits: which functions exist, which of them an addon may call,
-- which events an addon may subscribe to, and which values go dark once combat
-- starts. Presence and permission are separate questions, and the probe answers
-- them separately.
--
-- Measured against build 1.60.1.69893 (interface 16001, WOW_PROJECT_MAINLINE):
-- this is the Retail API set. Three facts about it shape every line below, and
-- the code is written defensively for all three.
--
--   1. The Classic globals an addon might reach for (UnitAura, GetSpellCooldown,
--      GetSpellInfo, CombatLogGetCurrentEventInfo) are simply absent.
--   2. RegisterEvent on an event this client does not know THROWS, and an error
--      in the main chunk aborts the rest of the file.
--   3. A secret value throws on tostring() as readily as on arithmetic.
--
--   /fprobe           static surface scan + action tests out of combat
--   /fprobe combat    re-run the action tests while actually in combat
--   /fprobe report    print the out-of-combat vs in-combat delta
--   /fprobe ah        Auction House detail, standing at an auction house
--   /fprobe ah scan   fire a full ReplicateItems scan (burns the 15 min throttle)
--   /fprobe events    which events an addon may subscribe to at all
--   /fprobe blocked   captured BLOCKED/FORBIDDEN actions
--   /fprobe external  inbound ExternalData.lua and outbound SavedVariables flush
--   /fprobe video     brightness/contrast CVars - may an addon write them at all
--   /fprobe docs      Blizzard's own API documentation (dump, version)
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

-- Inbound external data channel -----------------------------------------------
-- The only way an addon gets data from outside the client: a process outside the
-- game overwrites a .lua file inside the addon folder, the client executes it as
-- ADDON CODE at load, and the addon reads it back out of memory. There is no
-- polling and no push - new data costs a /reload. It works because the file is
-- code being run, not data being read, which is the only door the sandbox leaves
-- open, and it is what any config injection or out-of-game data import is built
-- on.
--
-- ExternalData.lua is that file. It ships with a known default so an untouched
-- install is distinguishable from a successful external write.
local externalInbox = {}

function ns.LoadExternalData(tag, ...)
    externalInbox[tag] = externalInbox[tag] or {}
    table.insert(externalInbox[tag], { ... })
end

-- Secret-safe conversion ------------------------------------------------------
-- MEASURED 2026-09-18, the hard way: tostring() on a secret value returns a
-- SECRET STRING. The taint survives the conversion. So converting inside a pcall
-- is NOT protection - the pcall returns ok=true and hands back a value that blows
-- up one line later, in the print, with
--   "attempt to index field '?' (a secret string value, while execution tainted)"
-- That is what took /fprobe down mid-run on the first live pass, at playerPower.
--
-- The client provides the real predicate, and this build has the whole family:
-- issecretvalue, issecrettable, hasanysecretvalues, scrub, scrubsecretvalues,
-- canaccesssecrets, secretwrap, dropsecretaccess.
--
-- EVERYTHING read out of the game goes through plain() before it is printed,
-- formatted, compared or stored. Storage matters most: a secret string written
-- into the DB would take the entire SavedVariables flush down with it, and this
-- addon exists to produce that file.
local function plain(v)
    if issecretvalue and issecretvalue(v) then return "<SECRET>" end
    local ok, str = pcall(tostring, v)
    if not ok then return "<UNPRINTABLE>" end
    -- tostring() of a secret is itself secret, so the value has to be re-tested
    -- after conversion rather than before it only.
    if issecretvalue and issecretvalue(str) then return "<SECRET>" end
    -- Indexing is the operation that actually throws, so do it here, once, where
    -- a failure is contained.
    local okCut, cut = pcall(string.sub, str, 1, 200)
    if not okCut then return "<SECRET>" end
    return cut
end

local function out(msg) DEFAULT_CHAT_FRAME:AddMessage("|cff44ddffFProbe|r " .. plain(msg)) end

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
-- (2) is the trap this whole probe is written around: a pcall alone reports
-- success, so a refusal reads as an allow.
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
        -- Outbound half of the channel. db is whatever was restored from disk, so
        -- a token written during the LAST session is sitting right here if the
        -- flush on /reload or logout actually happened.
        db.external = db.external or {}
        db.external.tokenFromPreviousSession = db.external.tokenWrittenThisSession
        db.external.tokenWrittenThisSession = nil
        db.external.loads = (db.external.loads or 0) + 1
        out("loaded. /fprobe out of combat, then /fprobe combat mid-fight.")
        -- Checked every login, not just on demand: someone reading a signature
        -- that no longer exists has no way to notice on their own.
        if C_Timer and C_Timer.After then
            C_Timer.After(1, function() pcall(docsVersionCheck, false) end)
        end
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
-- NOT registered at load, deliberately. Measured on a live client 2026-09-18:
-- RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED") fires ADDON_ACTION_FORBIDDEN, out
-- of combat, at load. The answer is in, and repeating it every login only trains
-- the player to click Disable on a dialog that is actually a result.
-- Re-check it deliberately with /fprobe events.
clog.registered = false
clog.registrationForbidden = "measured 2026-09-18: ADDON_ACTION_FORBIDDEN at load, out of combat"
-- CombatLogGetCurrentEventInfo is absent on this build as well, so the restriction
-- holds at two independent levels: an addon may not subscribe, and even if it did
-- there is no reader. Record the distinction - "never fires", "fires but
-- unreadable" and "may not listen" are three different answers.
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

-- The combat-state READ surface: spell, unit, aura, cooldown and talent reads.
-- The read side is what Blizzard has said it is restricting, so expect some of
-- this to be masked. Presence alone proves nothing here - a black box keeps the
-- function and returns nil or a masked value, so the read tests compare VALUES
-- across combat states.
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

-- The combat-state EXECUTE surface: casting, actions, macros, bindings and
-- targeting. Retail protects all of this in combat. Presence means nothing on its
-- own; the action tests decide.
local EXECUTE_SURFACE = {
    "CastSpellByName", "CastSpellByID", "UseAction", "UseInventoryItem", "UseItemByName",
    "RunMacro", "RunMacroText", "EditMacro", "SetMacroSpell", "PickupMacro",
    "SetBinding", "SetOverrideBinding", "SetOverrideBindingClick", "ClearOverrideBindings",
    "TargetUnit", "AssistUnit", "PetAttack", "StartAttack",
}

-- The sanctioned escape hatch in retail: precompute out of combat and let
-- Blizzard's own secure code do the switching. C_AssistedCombat is scanned
-- alongside it, since a client that ships its own rotation assist answers the
-- question at a different level.
local SECURE_SURFACE = {
    "SecureActionButtonTemplate", "SecureHandlerWrapScript", "SecureHandlerExecute",
    "SecureHandlerSetFrameRef", "RegisterStateDriver", "RegisterAttributeDriver",
    "SecureCmdOptionParse", "InCombatLockdown", "issecure", "issecurevariable",
    -- The secret-value toolkit. issecretvalue is the only reliable way to look at
    -- a game read without risking the whole run; the rest are its family.
    "issecretvalue", "issecrettable", "hasanysecretvalues", "scrub", "scrubsecretvalues",
    "canaccesssecrets", "secretwrap", "dropsecretaccess",
    "hooksecurefunc", "forceinsecure",
    "C_AssistedCombat", "C_AssistedCombat.GetNextCastSpell", "AssistedCombatManager",
}

-- What can move bytes across the client boundary, in either direction: file
-- access, addon messages, and payload encoding. This bounds any addon that
-- imports or exports data, so the list is deliberately broad - anything that
-- could carry a payload in or out counts, whether or not it is a WoW feature.
local CHANNEL_SURFACE = {
    "C_ChatInfo.SendAddonMessage", "SendAddonMessage", "C_ChatInfo.RegisterAddonMessagePrefix",
    "io", "os", "loadstring", "require", "debug", "package",
    "C_AddOns.GetAddOnMetadata", "C_AddOns.GetAddOnLocalTable", "ReloadUI",
    "C_CVar.GetCVar", "C_CVar.SetCVar", "C_CVar.RegisterCVar", "C_CVar.SetTempCVar",
    "GetScreenWidth", "CreateFrame", "C_Timer.NewTicker",
    -- Payload handling. C_EncodingUtil is the single most useful thing the
    -- measured client turned up here: JSON and CBOR both ways, base64, hex, and
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
-- addon messages, so the gates are expected to bound combat-state reads and
-- nothing else. Confirming that boundary is what the combat run is for.
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
        -- First live run showed half of these erroring at the call site: they
        -- take arguments (a unit token, an action slot, a spell id) and a missing
        -- argument throws exactly like a restriction would. Guessing the arity
        -- wrongly and recording "ERR" would have been a false finding, so each
        -- gate is tried against a few plausible argument sets and the one that
        -- answers is recorded along with WHAT it was asked.
        local ARGS = {
            { n = "()" },
            { n = '("player")', "player" },
            { n = '("target")', "target" },
            { n = "(1)", 1 },
            { n = '("player", 1)', "player", 1 },
        }
        local parts = {}
        for _, name in ipairs(SECRECY_CHECKS) do
            local fn = C_Secrets[name]
            if fn then
                local value, calledWith
                for _, argset in ipairs(ARGS) do
                    local ok, v = pcall(fn, unpack(argset))
                    if ok then
                        value, calledWith = plain(v), argset.n
                        break
                    end
                    value = "ERR:" .. plain(v)
                end
                s.gates[name] = value
                s.gateArgs = s.gateArgs or {}
                s.gateArgs[name] = calledWith or "no argument set worked"
                parts[#parts + 1] = (name:gsub("^Should", ""):gsub("BeSecret$", "")) ..
                    (calledWith and calledWith ~= "()" and calledWith or "") .. "=" .. plain(value)
            end
        end
        out("|cff44ddffSECRECY|r " .. table.concat(parts, " "):sub(1, 400))
    end
    local function ask(where, fname, key, ...)
        local tbl = _G[where]
        local fn = tbl and tbl[fname]
        if not fn then return end
        local ok, v = pcall(fn, ...)
        if not ok and select("#", ...) == 0 then
            -- Same trap as the gates above: these take an addon name, and a
            -- missing argument is indistinguishable from a refusal unless the
            -- call is retried properly.
            ok, v = pcall(fn, ADDON)
            if ok then s[key .. "Arg"] = "(addonName)" end
        end
        s[key] = ok and plain(v) or ("ERR:" .. plain(v))
        out(("  %-22s %s"):format(key, plain(s[key])))
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
-- functions. MEASURED ONLY - this records whether the client ships the capability
-- and what the no-argument reads return, and nothing more.
local function probeAssistedCombat()
    if not C_AssistedCombat then return nil end
    local a = { functions = {} }
    for _, name in ipairs({ "IsAvailable", "GetRotationSpells", "GetNextCastSpell", "GetActionSpell" }) do
        a.functions[name] = C_AssistedCombat[name] ~= nil
    end
    -- Only the no-argument reads are called. GetNextCastSpell/GetActionSpell want
    -- arguments and would be a live combat-decision read, which is a use of the
    -- API rather than a measurement of it.
    if C_AssistedCombat.IsAvailable then
        local ok, v = pcall(C_AssistedCombat.IsAvailable)
        a.isAvailable = ok and plain(v) or ("ERR:" .. plain(v))
    end
    if C_AssistedCombat.GetRotationSpells then
        local ok, v = pcall(C_AssistedCombat.GetRotationSpells)
        a.rotationSpells = ok and (type(v) == "table" and #v or plain(v)) or ("ERR:" .. plain(v))
    end
    out(("|cffffaa00C_AssistedCombat PRESENT|r isAvailable=%s rotationSpells=%s")
        :format(tostring(a.isAvailable), tostring(a.rotationSpells)))
    out("  This client ships its own rotation assist. Recorded, not acted on.")
    db.assistedCombat = a
    return a
end

-- Auction House ---------------------------------------------------------------
-- Which auction API this client ships, and what shape it is in: modern namespace
-- or legacy query API, commodities or not, bulk read or per-item only, and how
-- large the restricted set is. Those four answers bound what any market-data
-- addon can do here.
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
        out("  |cffff4444API|r  no Auction House API at all - addons cannot read the market")
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
                for k = 1, info.n do parts[k] = k .. "=" .. plain(info[k]) end
                samples[#samples + 1] = {
                    index = i, returns = info.n,
                    owner = plain(owner), ownerFullName = plain(ownerFull),
                    tuple = plain(table.concat(parts, " ")),
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

    -- A second successful scan inside retail's 900s window would mean Forever
    -- does not carry that throttle. A refusal brackets it from the other side.
    -- Either answer is the measurement; nothing else in the probe can give it.
    local attempts = (db.auctionHouse or {}).scanAttempts or {}
    local prev = attempts[#attempts - 1]
    if prev then
        local gap = time() - prev.at
        ahScan.secondsSincePreviousAttempt = gap
        if total > 0 then
            out(("  |cff44ff44THROTTLE: a second scan returned %d auctions %d seconds after the last|r")
                :format(total, gap))
            out("  Retail refuses inside 900s. Forever did not.")
        else
            out(("  |cffffaa00THROTTLE: second scan returned nothing after %d seconds|r - throttled"):format(gap))
        end
    end

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

-- The throttle is only measurable by trying again -------------------------
-- AUCTION_HOUSE_THROTTLED_SYSTEM_READY turned out to describe the message
-- system, not the replicate throttle: in the first capture it fired 20 seconds
-- BEFORE the scan was even requested, off the browse query, and
-- IsThrottledMessageSystemReady read true 64 seconds after a successful scan.
-- Neither says anything about ReplicateItems.
--
-- So the only honest test is to call it again and see whether data comes back.
-- Each attempt is stamped with absolute time, because this build does not read
-- SavedVariables back and the history cannot survive a /reload - the gap has to
-- be reconstructed from the collected files afterwards.
local function ahScanAttemptLog(result)
    db.auctionHouse = db.auctionHouse or {}
    local log = db.auctionHouse.scanAttempts or {}
    log[#log + 1] = { at = time(), gameTime = GetTime(), result = result }
    db.auctionHouse.scanAttempts = log
    return #log
end

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
    ahScan.attempt = ahScanAttemptLog("requested")
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
-- Presence is settled: the modern namespace was read off a capture of this exact
-- build. What is NOT settled is every number, and the numbers are what decide an
-- addon's data model:
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

-- One level of a table, flattened to text, secret-safe. Enough to read a shape
-- off, not so much that SavedVariables becomes unreadable.
local function shapeOf(t, depth)
    if type(t) ~= "table" then return plain(t) end
    if issecrettable and issecrettable(t) then return "<SECRET TABLE>" end
    local parts = {}
    for k, v in pairs(t) do
        local val
        if type(v) == "table" and (depth or 1) > 0 then
            val = "{" .. shapeOf(v, (depth or 1) - 1) .. "}"
        else
            val = plain(v)
        end
        parts[#parts + 1] = plain(k) .. "=" .. val
        if #parts >= 20 then break end
    end
    table.sort(parts)
    return table.concat(parts, " ")
end

local function finishBrowse()
    if not browse or browse.done then return end
    browse.done = true
    browse.elapsed = GetTime() - browse.startedAt
    browse.total = browseCount()

    -- THE shape that matters. A browse result is what a market-data addon reads
    -- on every pass: one entry per item key, with the cheapest price and the
    -- total quantity behind it. Three samples is enough to read the field list
    -- off and see whether Forever kept retail's structure.
    local okResults, results = pcall(C_AuctionHouse.GetBrowseResults)
    if okResults and type(results) == "table" then
        browse.resultShape = {}
        for i = 1, math.min(3, #results) do
            browse.resultShape[i] = shapeOf(results[i], 2)
        end
        if browse.resultShape[1] then
            out("  browse entry: " .. plain(browse.resultShape[1]))
        end
    end
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

-- Shapes that decide how an addon stores what it reads. All cheap reads off
-- whatever the client already has cached.
local function ahShapes()
    local shapes = {}
    db.auctionHouse = db.auctionHouse or {}
    local function record(name, fn)
        local ok, v = pcall(fn)
        if not ok then shapes[name] = "ERR: " .. plain(v); return end
        if type(v) == "table" and not (issecrettable and issecrettable(v)) then
            shapes[name] = shapeOf(v, 1)
        else
            shapes[name] = plain(v)
        end
        out(("  %-22s %s"):format(name, plain(shapes[name])))
    end

    -- Time-left bands are the whole basis of "is this listing about to expire",
    -- and a Classic+ title could easily ship different bands from retail's four.
    -- Retail has four bands (30m / 2h / 12h / 48h). Measured on Forever
    -- 2026-09-18: only three exist, and asking for a fourth is a bad-argument
    -- error rather than a nil. So walk until it refuses and record the count -
    -- the number of bands IS the finding, and it changes what "about to expire"
    -- means for any pricing logic.
    if C_AuctionHouse and C_AuctionHouse.GetTimeLeftBandInfo then
        local bands = {}
        for band = 1, 8 do
            local ok, minSec, maxSec = pcall(C_AuctionHouse.GetTimeLeftBandInfo, band)
            if not ok then break end
            bands[band] = plain(minSec) .. ".." .. plain(maxSec)
            shapes["timeLeftBand" .. band] = bands[band]
        end
        shapes.timeLeftBandCount = #bands
        out(("  timeLeftBands          %d (retail has 4): %s")
            :format(#bands, table.concat(bands, ", ")))
    end
    -- Item keys are the join key for every price record an addon keeps.
    -- GetItemKeyFromItem takes an ITEM, not an item id - passing a bare 2589
    -- produced three bad-argument lines in the first capture. A real addon takes
    -- the key off a browse result, so do that: run /fprobe ah browse first and
    -- this reads the genuine article.
    local firstKey
    if C_AuctionHouse and C_AuctionHouse.GetBrowseResults then
        local ok, results = pcall(C_AuctionHouse.GetBrowseResults)
        if ok and type(results) == "table" and results[1] then
            firstKey = results[1].itemKey
            record("itemKey (from browse)", function() return firstKey end)
        end
    end
    if firstKey and C_AuctionHouse.GetItemKeyInfo then
        record("itemKeyInfo", function() return C_AuctionHouse.GetItemKeyInfo(firstKey) end)
    end
    if firstKey and C_AuctionHouse.GetItemCommodityStatus then
        record("commodityStatus", function() return C_AuctionHouse.GetItemCommodityStatus(firstKey) end)
    end
    if not firstKey then
        out("  |cffffaa00no browse results cached|r - run /fprobe ah browse first for the item-key shapes")
    end
    db.auctionHouse = db.auctionHouse or {}
    db.auctionHouse.shapes = shapes
end

-- External data channel report ------------------------------------------------
local function printExternal()
    db.external = db.external or {}

    out("|cff44ddffEXTERNAL inbound|r (ExternalData.lua, executed at load)")
    local tags, entries = {}, 0
    for tag, list in pairs(externalInbox) do
        tags[#tags + 1] = tag .. "(" .. #list .. ")"
        entries = entries + #list
    end
    table.sort(tags)
    local def = externalInbox["default"] and externalInbox["default"][1]
    local untouched = (def and def[1] == "unmodified" and entries == 1) and true or false

    if entries == 0 then
        out("  |cffff4444nothing received|r - ExternalData.lua is missing from the .toc or failed to load")
    elseif untouched then
        out("  |cffffaa00shipped default only|r - the file loads and the channel works, but nothing has")
        out("  written to it yet. Run scripts/write-external-data.ps1, then /reload.")
    else
        out("  |cff44ff44external write received:|r " .. table.concat(tags, " "))
        for tag, list in pairs(externalInbox) do
            local first = list[1]
            if first then
                local parts = {}
                for i = 1, #first do parts[i] = tostring(first[i]) end
                out(("    %s -> %s"):format(tag, table.concat(parts, ", "):sub(1, 120)))
            end
        end
    end
    db.external.inbox = externalInbox
    db.external.inboxEntries = entries
    db.external.untouched = untouched

    out("|cff44ddffEXTERNAL outbound|r (SavedVariables flush)")
    -- Two different failures look identical from in here, and they have opposite
    -- consequences:
    --   a) the client never WROTE the file           -> outbound is dead
    --   b) the client wrote it and never READ it back -> outbound is fine, and the
    --      round trip inside the client is what is broken
    -- (b) is a reported beta bug on this build, so the in-game verdict is only
    -- half the answer; collect-savedvars.ps1 looking at the file on disk is the
    -- other half, and it is the one that settles it.
    if db.external.tokenFromPreviousSession then
        out("  |cff44ff44confirmed|r - last session's token survived: " .. tostring(db.external.tokenFromPreviousSession))
    elseif (db.external.loads or 0) > 1 then
        out("  |cffff4444read-back failed|r - this DB has seen " .. tostring(db.external.loads) ..
            " loads but no token survived")
    else
        out("  |cffffaa00first load of this DB|r - /reload, then /fprobe external again.")
        out("  If the load counter is STILL 1 afterwards, the client is not reading SavedVariables")
        out("  back at all (known beta bug). Run scripts/collect-savedvars.ps1 to see whether the")
        out("  file was nonetheless written - that is what decides the outbound half.")
    end
    out("  loads recorded by this DB: " .. tostring(db.external.loads or 0))
    db.external.tokenWrittenThisSession = ("%s-%d"):format(
        date and date("%H%M%S") or tostring(time()), math.random(1000, 9999))
    out("  wrote token " .. db.external.tokenWrittenThisSession .. " - it should reappear after /reload")
end

-- Which events may an addon listen to at all? -------------------------------
-- COMBAT_LOG_EVENT_UNFILTERED is refused outright (measured). That single fact
-- does not say whether the rule is "no combat log" or "no combat information",
-- and those imply very different games. This walks the neighbourhood and
-- attributes each refusal, unregistering as it goes so nothing is left listening.
--
-- Opt-in, because every refusal pops a dialog the player must dismiss.
local EVENT_PROBE = {
    -- the combat log itself, both forms
    "COMBAT_LOG_EVENT_UNFILTERED", "COMBAT_LOG_EVENT",
    -- combat state, which bounds the rule from the outside
    "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "UNIT_COMBAT",
    -- unit information the doctrine names
    "UNIT_AURA", "UNIT_HEALTH", "UNIT_POWER_UPDATE", "UNIT_SPELLCAST_SUCCEEDED",
    "UNIT_SPELLCAST_START", "UNIT_THREAT_LIST_UPDATE",
    -- events well outside combat, as the control group
    "AUCTION_HOUSE_SHOW", "AUCTION_HOUSE_THROTTLED_SYSTEM_READY",
    "CHAT_MSG_ADDON", "PLAYER_MONEY", "BAG_UPDATE",
}

local function probeEvents()
    out("|cff44ddffEVENT SUBSCRIPTION probe|r - each refusal pops a dialog; press Ignore")
    local probeFrame = CreateFrame("Frame")
    local allowed, refused, missing = {}, {}, {}
    for _, event in ipairs(EVENT_PROBE) do
        local before = #blockLog
        local ok = safeRegister(probeFrame, event)
        if registerBlocked[event] then
            refused[#refused + 1] = event
        elseif not ok then
            missing[#missing + 1] = event
        else
            allowed[#allowed + 1] = event
            pcall(probeFrame.UnregisterEvent, probeFrame, event)
        end
        if #blockLog > before then registerBlocked[event] = registerBlocked[event] or "blocked" end
    end
    table.sort(allowed); table.sort(refused); table.sort(missing)
    out("  |cff44ff44may listen:|r  " .. (table.concat(allowed, ", "):sub(1, 300)))
    out("  |cffff4444REFUSED:|r    " .. (#refused > 0 and table.concat(refused, ", ") or "none"))
    out("  |cffffaa00not on client:|r " .. (#missing > 0 and table.concat(missing, ", ") or "none"))
    if #refused > 0 then
        out("  The refused set is the shape of the rule: combat log only, or combat")
        out("  information generally. Anything outside that set is unaffected.")
    end
    db.eventProbe = { allowed = allowed, refused = refused, missing = missing }
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
        secure = SECURE_SURFACE, channel = CHANNEL_SURFACE,
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

    -- Capability verdicts about this client, settled by the out-of-combat run
    -- alone: which auction API ships, and what can carry data across the client
    -- boundary.
    local verdict = {}
    verdict.auctionHouse = probeAuctionHouse()

    verdict.export = {
        io = lookup("io") ~= nil, os = lookup("os") ~= nil,
        loadstring = (lookup("loadstring") or lookup("load")) ~= nil,
        addonMessage = (lookup("C_ChatInfo.SendAddonMessage") or lookup("SendAddonMessage")) ~= nil,
        cvar = (lookup("C_CVar.SetCVar") or lookup("SetCVar")) ~= nil,
    }
    out(("|cff44ddffEXTERNAL|r  io=%s os=%s load=%s addonMsg=%s cvar=%s")
        :format(tostring(verdict.export.io), tostring(verdict.export.os),
                tostring(verdict.export.loadstring), tostring(verdict.export.addonMessage),
                tostring(verdict.export.cvar)))
    verdict.export.encoding = (lookup("C_EncodingUtil.SerializeJSON") ~= nil)
    verdict.export.clipboard = (lookup("CopyToClipboard") ~= nil)
    out(("            json=%s clipboard=%s reloadUI=%s")
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

    db.verdicts = verdict
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
-- is a flat ban, blocked only in combat matches retail and leaves out-of-combat
-- use untouched.
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
        -- lint-allow: forbidden-call - the point of this test is to measure the refusal
        try("UseAction(slot1)", function() UseAction(1) end)
    end
    if RunMacroText then
        try("RunMacroText(/cast)", function() RunMacroText("/cast " .. (probeSpell or "Attack")) end)
    end
    if EditMacro then
        -- lint-allow: blocked-in-combat - measuring whether it is blocked is the test
        try("EditMacro", function() EditMacro(1, nil, nil, "/cast " .. (probeSpell or "Attack")) end)
    end
    if SetOverrideBindingClick then
        try("SetOverrideBindingClick", function()
            -- lint-allow: blocked-in-combat - measuring whether it is blocked is the test
            SetOverrideBindingClick(watcher, true, "F12", "ForeverProbeSecureBtn")
        end)
    end

    -- The legitimate path: retarget a secure button the player clicks themselves.
    -- Out of combat this should succeed; retail blocks it in combat. This is the
    -- test for whether an addon may change what a secure button does, and when.
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
        -- Two failure modes, and the second one is the subtle one:
        --   a) the read throws            -> pcall catches it, record the error
        --   b) the read returns a SECRET  -> pcall reports success and hands back
        --      a value that throws on the next touch. plain() is what catches
        --      that, and "<SECRET>" is a result in its own right: it means the
        --      value exists and the addon may not look at it.
        local ok, v = pcall(fn)
        reads[name] = ok and plain(v) or ("ERR: " .. plain(v))
        out(("  READ %-22s %s"):format(name, plain(reads[name])))
    end

    readTest("spellCooldownStart", function()
        local f = (C_Spell and C_Spell.GetSpellCooldown) or GetSpellCooldown
        if not f then return "NO API" end
        local r = f(probeSpell or 1)
        if type(r) == "table" then return r.startTime end
        return r
    end)
    -- lint-allow: secret-read - reading a secret and recording that it IS secret
    readTest("playerPower", function() return UnitPower("player") end)
    readTest("playerAura1", function()
        if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
            -- lint-allow: secret-read - reading a secret and recording that it IS secret
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
            -- lint-allow: secret-read - reading a secret and recording that it IS secret
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
    -- The delta needs both passes, and this build never reads SavedVariables
    -- back, so a /reload between them throws the baseline away. Say so at the
    -- moment it matters rather than letting /fprobe report discover it.
    if label == "incombat" and not db.actions.outofcombat then
        out("|cffffaa00no out-of-combat baseline in this session|r - the delta needs both")
        out("  passes with no /reload between them, because this build does not read")
        out("  SavedVariables back. Order: /fprobe, pull something, /fprobe combat, /fprobe report.")
    end
    db.actions[label] = results
    db.blockLog = blockLog
    db.combatLog = clog
    out(("combat log: FORBIDDEN to register (measured). reader=%s fired=%d readable=%d inCombat=%d subevents=%d")
        :format(tostring(clog.readerPresent),
                clog.eventFired or 0, clog.count, clog.inCombatCount, (function()
            local n = 0; for _ in pairs(clog.subevents) do n = n + 1 end; return n
        end)()))
    -- Printed again HERE, not only in probeSurfaces: the action tests are what
    -- actually provoke blocks, so the earlier summary always said "none this
    -- session" and was immediately contradicted by the next three lines.
    printBlocked()
    out(("recorded as '%s'"):format(label))
end

-- Report ----------------------------------------------------------------------
local function printReport()
    local a = db.actions or {}
    if not a.outofcombat or not a.incombat then
        out("need both runs. have: " ..
            (a.outofcombat and "out-of-combat " or "") .. (a.incombat and "in-combat" or "neither"))
        out("  Both must happen in ONE session: this build writes SavedVariables but never")
        out("  reads them back, so a /reload discards whichever pass came first.")
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

    -- The read diff. A value that is readable out of combat and nil/blank in
    -- combat is the black box closing, which is a different and much harder
    -- restriction than a blocked action: the call still succeeds and the data is
    -- simply not there.
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
        out("  |cffff4444these reads are unavailable to addons in combat|r")
    else
        out("  |cff44ff44none - combat state stayed readable|r")
    end
    -- The secrecy delta is the direct answer to the combat-only-vs-always-on
    -- question, straight from Blizzard's own gate rather than inferred from
    -- masked values. A gate that is false out of combat and true in combat is a
    -- combat-scoped black box, which leaves everything outside combat untouched.
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
            out("  |cffff4444some gates are always on|r - these reads are restricted out of combat too")
        end
        db.secrecyDelta = { combatOnly = gatesOn, alwaysOn = alwaysOn }
    end
    out(("  combat log: %d events, %d in combat%s"):format(
        (db.combatLog and db.combatLog.count) or 0,
        (db.combatLog and db.combatLog.inCombatCount) or 0,
        (db.combatLog and db.combatLog.error) and (" |cffff4444ERR: " .. db.combatLog.error .. "|r") or ""))

    db.delta = { combatOnly = combatOnly, flatBan = flatBan, maskedReads = masked }
end

-- Is the shipped reference still true of this client? -------------------------
-- The reference ships generated from one specific build. Blizzard moved this
-- beta 69893 -> 69913 in a single day, so the reference being behind the client
-- is the normal case and silence would be the wrong default: a player reading a
-- signature that no longer exists has no way to tell.
--
-- Three severities, because they mean different things:
--   interface number differs -> a major patch. Assume the reference is wrong
--                               until regenerated; whole systems move.
--   version string differs   -> a content patch. Signatures may have changed.
--   build number differs     -> a hotfix. Usually harmless, occasionally not.
local function docsVersionCheck(verbose)
    local shipped = ForeverProbeDocsVersion
    local version, build, _, toc = GetBuildInfo()
    version, build, toc = plain(version), plain(build), plain(toc)

    local state = { clientVersion = version, clientBuild = build, clientInterface = toc }
    if type(shipped) ~= "table" then
        state.severity = "missing"
        out("|cffff4444no API reference version|r - DocsVersion.lua is missing or failed to load")
        db.docsVersion = state
        return state
    end

    state.refVersion, state.refBuild = plain(shipped.version), plain(shipped.build)
    state.refInterface, state.generated = shipped.interface, plain(shipped.generated)

    local severity, why
    if shipped.interface and toc and tostring(shipped.interface) ~= tostring(toc) then
        severity = "major"
        why = ("interface %s -> %s"):format(plain(shipped.interface), toc)
    elseif shipped.version and version and plain(shipped.version) ~= version then
        severity = "major"
        why = ("version %s -> %s"):format(plain(shipped.version), version)
    elseif shipped.build and build and plain(shipped.build) ~= build then
        severity = "minor"
        why = ("build %s -> %s"):format(plain(shipped.build), build)
    else
        severity = "current"
    end
    state.severity, state.why = severity, why

    if severity == "major" then
        out("|cffff4444API REFERENCE IS OUT OF DATE|r - " .. plain(why))
        out("  The shipped reference describes a different client. Signatures may be")
        out("  wrong and whole systems may have moved. Regenerate before trusting it:")
        out("  |cffffffff/fprobe docs dump|r then |cffffffff/reload|r")
    elseif severity == "minor" then
        out("|cffffaa00API reference is behind this client|r - " .. plain(why))
        out("  Usually harmless on a hotfix, but regenerate if something looks wrong:")
        out("  |cffffffff/fprobe docs dump|r then |cffffffff/reload|r")
    elseif verbose then
        out(("|cff44ff44API reference matches this client|r - %s build %s, generated %s")
            :format(plain(shipped.version), plain(shipped.build), plain(shipped.generated)))
        out(("  covers %s systems, %s functions, %s events, %s tables")
            :format(plain(shipped.systems), plain(shipped.functions),
                    plain(shipped.events), plain(shipped.tables)))
    end

    db.docsVersion = state
    return state
end

-- Blizzard's own API documentation ------------------------------------------
-- Does Forever ship Blizzard_APIDocumentationGenerated, and may an addon load it?
-- This is what the API reference is generated from, so the answer decides whether
-- the reference is measured or inferred.
--
-- If yes, every function signature - argument names, types, nilable flags,
-- return types, events, enums and structures - comes out of the client itself,
-- and stays correct across beta patches for free. If no, the fallback is hand
-- curation from retail sources, which is inference rather than measurement.
--
-- APIDocumentation_LoadUI is PRESENT in the global dump. That is not the same as
-- being allowed to call it - RegisterEvent was present and refused - so the call
-- is attributed like any other action test.
--
-- This command measures and reports. It deliberately does NOT dump everything:
-- the size of one system is what decides whether the real dump has to be
-- chunked, and guessing that would mean writing the dumper twice.

local function keysOf(t, limit)
    if type(t) ~= "table" then return plain(t) end
    local keys = {}
    for k in pairs(t) do keys[#keys + 1] = plain(k) end
    table.sort(keys)
    local n = #keys
    if limit and n > limit then
        local cut = {}
        for i = 1, limit do cut[i] = keys[i] end
        keys = cut
        keys[#keys + 1] = ("...(%d total)"):format(n)
    end
    return table.concat(keys, ", ")
end

local function countField(system, field)
    local v = system and system[field]
    if type(v) ~= "table" then return 0 end
    return #v
end

local function probeApiDocs()
    out("|cff44ddffAPI DOCUMENTATION|r")
    docsVersionCheck(true)
    local api = {}

    if not APIDocumentation_LoadUI then
        out("  |cffff4444APIDocumentation_LoadUI ABSENT|r - this client has no doc system")
        api.loaderPresent = false
        db.apiDocsProbe = api
        return
    end
    api.loaderPresent = true

    -- Presence is not permission. Attribute the call so a refusal is recorded as
    -- a refusal rather than as a mystery.
    activeTest = "APIDocumentation_LoadUI"
    local okLoad, loadErr = pcall(APIDocumentation_LoadUI)
    activeTest = nil
    local blocked = blocksFor("APIDocumentation_LoadUI")
    api.loadOk = okLoad
    api.loadErr = (not okLoad) and plain(loadErr) or nil
    api.blockEvents = (#blocked > 0) and blocked or nil

    if #blocked > 0 then
        out("  |cffff4444FORBIDDEN|r - " .. plain(blocked[1]))
        out("  Addons may not load the documentation - the reference cannot be generated from it.")
        db.apiDocsProbe = api
        return
    end
    if not okLoad then
        out("  |cffff4444load ERR|r " .. plain(loadErr))
        db.apiDocsProbe = api
        return
    end

    local doc = APIDocumentation
    if type(doc) ~= "table" then
        out("  |cffff4444loaded, but no APIDocumentation global|r - the addon is a stub")
        api.globalPresent = false
        db.apiDocsProbe = api
        return
    end
    api.globalPresent = true
    api.docKeys = keysOf(doc, 25)
    out("  |cff44ff44loaded|r. APIDocumentation keys: " .. plain(api.docKeys):sub(1, 200))

    local systems = doc.systems
    if type(systems) ~= "table" then
        out("  |cffffaa00no .systems array|r - walk APIDocumentation keys above instead")
        db.apiDocsProbe = api
        return
    end

    -- Totals, and the breakdown by system Type. "ScriptObject" is how Blizzard
    -- classifies widget/frame methods; if that count is zero then the generated
    -- docs cover the C API only, and nothing downstream may claim to document
    -- Frame:SetPoint and friends.
    local nFunctions, nEvents, nTables = 0, 0, 0
    local byType, namespaced = {}, 0
    for _, sys in ipairs(systems) do
        nFunctions = nFunctions + countField(sys, "Functions")
        nEvents    = nEvents    + countField(sys, "Events")
        nTables    = nTables    + countField(sys, "Tables")
        local t = plain(sys.Type or "nil")
        byType[t] = (byType[t] or 0) + 1
        if sys.Namespace then namespaced = namespaced + 1 end
    end
    api.systemCount, api.functionCount = #systems, nFunctions
    api.eventCount, api.tableCount = nEvents, nTables
    api.namespacedSystems = namespaced
    api.systemsByType = byType

    out(("  systems %d (%d namespaced) | functions %d | events %d | tables %d")
        :format(#systems, namespaced, nFunctions, nEvents, nTables))
    local typeParts = {}
    for t, n in pairs(byType) do typeParts[#typeParts + 1] = t .. "=" .. n end
    table.sort(typeParts)
    out("  system types: " .. table.concat(typeParts, " "))
    if not byType["ScriptObject"] then
        out("  |cffffaa00no ScriptObject systems|r - widget/frame methods are NOT documented here")
    end

    -- The shape of one function, read off rather than assumed. The generator is
    -- written against whatever this prints, not against retail's schema.
    local sample, sampleSystem
    for _, sys in ipairs(systems) do
        local fns = sys.Functions
        if type(fns) == "table" and fns[1] then sample, sampleSystem = fns[1], sys
            break
        end
    end
    if sample then
        api.sampleSystem = plain(sampleSystem.Name)
        api.sampleNamespace = plain(sampleSystem.Namespace)
        api.sampleFunction = plain(sample.Name)
        api.sampleKeys = keysOf(sample, 20)
        out(("  sample %s.%s"):format(plain(sampleSystem.Namespace or "_G"), plain(sample.Name)))
        out("    keys: " .. plain(api.sampleKeys):sub(1, 220))
        if type(sample.Arguments) == "table" and sample.Arguments[1] then
            api.sampleArgKeys = keysOf(sample.Arguments[1], 12)
            api.sampleArg = shapeOf(sample.Arguments[1], 0)
            out("    arg[1]: " .. plain(api.sampleArg):sub(1, 200))
        end
        if type(sample.Returns) == "table" and sample.Returns[1] then
            api.sampleReturn = shapeOf(sample.Returns[1], 0)
            out("    ret[1]: " .. plain(api.sampleReturn):sub(1, 200))
        end
        -- Tier 1 of the plugin's restriction data: Blizzard's own flag.
        api.sampleHasRestrictions = plain(sample.HasRestrictions)
        local restricted = 0
        for _, sys in ipairs(systems) do
            for _, fn in ipairs(sys.Functions or {}) do
                if fn.HasRestrictions then restricted = restricted + 1 end
            end
        end
        api.restrictedFunctionCount = restricted
        out(("    functions flagged HasRestrictions: %d"):format(restricted))
    else
        out("  |cffffaa00no function entries found|r")
    end

    -- Size. This is the number that decides whether the dumper chunks per system
    -- or writes in one pass - the largest SavedVariables flush measured so far is
    -- 303 KB, and retail's doc set is several MB.
    if C_EncodingUtil and C_EncodingUtil.SerializeJSON and sampleSystem then
        local okJson, json = pcall(C_EncodingUtil.SerializeJSON, sampleSystem)
        if okJson and type(json) == "string" then
            api.sampleSystemBytes = #json
            api.estimatedTotalBytes = #json * #systems
            out(("  one system serializes to %d bytes -> rough total %.1f MB across %d systems")
                :format(#json, (#json * #systems) / 1048576, #systems))
        else
            api.jsonErr = plain(json)
            out("  |cffffaa00SerializeJSON failed|r " .. plain(json):sub(1, 120))
            out("  the dumper will need the raw Lua table fallback")
        end
    end

    db.apiDocsProbe = api
    out("  recorded. |cffffffff/reload|r then collect-savedvars.ps1")
end

-- The dumper ----------------------------------------------------------------
-- Measured 2026-09-18 on build 69913: the documentation loads, and it is large -
-- 408 systems, 6,577 functions, 1,802 events, 792 tables, with 81 ScriptObject
-- systems, which means widget and frame methods are documented too.
--
-- Two things the measurement changed.
--
-- 1. Doc entries are MIXIN OBJECTS, not plain data. Every entry carries two
--    dozen methods (GetFullName, GetArgumentString, IsOptional, ...) alongside
--    its fields, which is why C_EncodingUtil.SerializeJSON refused the live
--    objects with "attempted to serialize a function value". So this builds a
--    plain PROJECTION first - data fields only, nothing callable - and lets the
--    client's own SavedVariables writer serialize that. Fewer moving parts than
--    JSON-inside-Lua, and the resulting file is plain Lua that any parser reads.
--
-- 2. Those mixins expose Blizzard's own renderers. Capturing GetArgumentString,
--    GetReturnString and GetFullName next to the structured fields costs almost
--    nothing and gives the generator a cross-check: if a reconstructed signature
--    disagrees with Blizzard's own rendering of the same entry, one of them is
--    wrong, and a mismatch that is recorded can be caught before it ships.
--
-- Blizzard's prose Documentation fields are deliberately NOT captured. Signatures
-- and type names are close to facts; the prose is Blizzard's writing, extracted
-- from a copyrighted client.

-- Only scalars are stored. Anything else - a table, a function, a secret - is
-- dropped rather than guessed at, so a field that survives into the projection is
-- a field that is genuinely a value.
local function scalar(v)
    local t = type(v)
    if t ~= "string" and t ~= "number" and t ~= "boolean" then return nil end
    if issecretvalue and issecretvalue(v) then return nil end
    return v
end

local function callString(obj, method)
    local fn = obj and obj[method]
    if type(fn) ~= "function" then return nil end
    local ok, s = pcall(fn, obj)
    return ok and scalar(s) or nil
end

-- Arguments, returns and event payload fields all share this shape.
local function projectField(f)
    if type(f) ~= "table" then return nil end
    return {
        Name = scalar(f.Name),
        Type = scalar(f.Type),
        InnerType = scalar(f.InnerType),
        Nilable = scalar(f.Nilable),
        Default = scalar(f.Default),
        Mixin = scalar(f.Mixin),
        StrideIndex = scalar(f.StrideIndex),
        Documentation = nil, -- deliberate, see header
    }
end

local function projectList(list, fn)
    if type(list) ~= "table" then return nil end
    local out, n = {}, 0
    for i = 1, #list do
        local v = fn(list[i])
        if v then n = n + 1; out[n] = v end
    end
    if n == 0 then return nil end
    return out
end

local function projectFunction(f)
    if type(f) ~= "table" then return nil end
    return {
        Name = scalar(f.Name),
        Type = scalar(f.Type),
        HasRestrictions = scalar(f.HasRestrictions),
        Arguments = projectList(f.Arguments, projectField),
        Returns = projectList(f.Returns, projectField),
        -- Blizzard's own rendering, kept as the cross-check described above.
        FullName = callString(f, "GetFullName"),
        ArgumentString = callString(f, "GetArgumentString"),
        ReturnString = callString(f, "GetReturnString"),
    }
end

local function projectEvent(e)
    if type(e) ~= "table" then return nil end
    return {
        Name = scalar(e.Name),
        LiteralName = scalar(e.LiteralName),
        Type = scalar(e.Type),
        Payload = projectList(e.Payload, projectField),
        FullName = callString(e, "GetFullName"),
    }
end

local function projectTable(t)
    if type(t) ~= "table" then return nil end
    return {
        Name = scalar(t.Name),
        Type = scalar(t.Type),          -- Enumeration / Structure / Constants
        NumValues = scalar(t.NumValues),
        MinValue = scalar(t.MinValue),
        MaxValue = scalar(t.MaxValue),
        Fields = projectList(t.Fields, projectField),
        Values = projectList(t.Values, function(v)
            if type(v) ~= "table" then return nil end
            return { Name = scalar(v.Name), EnumValue = scalar(v.EnumValue) }
        end),
    }
end

local function projectSystem(sys)
    if type(sys) ~= "table" then return nil end
    return {
        Name = scalar(sys.Name),
        Namespace = scalar(sys.Namespace),
        Type = scalar(sys.Type),        -- System / ScriptObject
        Functions = projectList(sys.Functions, projectFunction),
        Events = projectList(sys.Events, projectEvent),
        Tables = projectList(sys.Tables, projectTable),
    }
end

-- /fprobe docs dump [start] [count]
--
-- The range arguments exist because the largest SavedVariables flush measured so
-- far is 303 KB and this projection will be several megabytes. If
-- the whole thing will not write, it can be taken in passes; each pass merges
-- into what is already there rather than replacing it.
local function dumpApiDocs(startAt, count)
    if not APIDocumentation then
        local ok = pcall(APIDocumentation_LoadUI)
        if not ok or not APIDocumentation then
            out("|cffff4444documentation not loaded|r - run /fprobe docs first")
            return
        end
    end
    local systems = APIDocumentation.systems
    if type(systems) ~= "table" then
        out("|cffff4444no .systems array|r")
        return
    end

    startAt = math.max(1, tonumber(startAt) or 1)
    local last = #systems
    if count then last = math.min(last, startAt + math.max(1, tonumber(count) or 0) - 1) end

    db.apiDocs = db.apiDocs or {}
    local store = db.apiDocs
    -- Read the build HERE rather than trusting db.build, which is only set by a
    -- full /fprobe run. Measured 2026-09-18: a 3.9 MB capture landed with no
    -- build recorded at all, because the session only ran the dump - a reference
    -- that cannot say which client produced it is the exact drift problem the
    -- version flagging exists to solve.
    local bVersion, bBuild, bDate, bToc = GetBuildInfo()
    store.client = {
        version = plain(bVersion), build = plain(bBuild),
        date = plain(bDate), interface = plain(bToc),
    }
    store.systems = store.systems or {}
    store.capturedAt = date and date("%Y-%m-%d %H:%M:%S") or time()

    local nSys, nFn, nEv, nTb, failed = 0, 0, 0, 0, 0
    local collisions = {}
    for i = startAt, last do
        local ok, projected = pcall(projectSystem, systems[i])
        if ok and projected and projected.Name then
            -- Keyed so repeated or partial runs merge cleanly instead of
            -- duplicating - this build cannot read SavedVariables back, so a pass
            -- has to be self-contained within one session.
            --
            -- NOT keyed by Namespace: measured 2026-09-18, three systems shared a
            -- namespace with another and silently overwrote it, so 408 walked
            -- became 405 stored and the loss was invisible afterwards. Name plus
            -- type is the key, Namespace stays a field, and any residual
            -- collision is suffixed and RECORDED rather than dropped.
            local key = projected.Name or ("system" .. i)
            if projected.Type == "ScriptObject" then key = "ScriptObject:" .. key end
            if store.systems[key] then
                collisions[#collisions + 1] = key
                local n = 2
                while store.systems[key .. "~" .. n] do n = n + 1 end
                key = key .. "~" .. n
            end
            store.systems[key] = projected
            nSys = nSys + 1
            nFn = nFn + #(projected.Functions or {})
            nEv = nEv + #(projected.Events or {})
            nTb = nTb + #(projected.Tables or {})
        else
            failed = failed + 1
        end
        if (i - startAt) % 100 == 99 then
            out(("  ...%d/%d systems"):format(i - startAt + 1, last - startAt + 1))
        end
    end

    -- Count what is actually in the store, not just what was walked. The two
    -- disagreeing is exactly the bug above, and it should be loud.
    local stored = 0
    for _ in pairs(store.systems) do stored = stored + 1 end
    store.counts = {
        systems = nSys, stored = stored, functions = nFn, events = nEv,
        tables = nTb, failed = failed, collisions = collisions,
    }
    out(("|cff44ff44dumped|r systems %d..%d -> %d systems, %d functions, %d events, %d tables%s")
        :format(startAt, last, nSys, nFn, nEv, nTb,
                failed > 0 and (" |cffffaa00(" .. failed .. " failed)|r") or ""))
    out(("  %d systems in the store"):format(stored))
    if #collisions > 0 then
        out(("  |cffffaa00%d name collisions, suffixed:|r %s")
            :format(#collisions, table.concat(collisions, ", "):sub(1, 200)))
    end
    out("  |cffffffff/reload|r to flush, then collect-savedvars.ps1")
    out("  If the file is truncated or the flush hangs, take it in passes:")
    out("  |cffffffff/fprobe docs dump 1 100|r, /reload, collect, then 101 100, and so on.")
end

-- Video CVar probe ------------------------------------------------------------
-- Can an addon drive display brightness and contrast? Four parts, and they fail
-- in different ways:
--
--   1. do the CVars exist on this build, and will the client let an addon write
--      them
--   2. does a write take effect LIVE, or does each one cost a device restart
--   3. do they work windowed, or only in exclusive fullscreen
--   4. are writes blocked in combat
--
-- The retail names are a STARTING GUESS, not the answer. ConsoleGetAllCommands is
-- present on this build, so the real names get enumerated rather than assumed.
--
-- (2) decides whether a smooth ease is possible at all, and no Lua read reports
-- what the monitor is doing. So /fprobe video ramp drives a sweep from OnUpdate
-- and counts the frames it got: a live post-process leaves the frame deltas flat,
-- while a device restart per write craters them. That shows up in the numbers as
-- well as on the screen, which turns half of a "ask the human" question into a
-- measurement.
--
-- (3) cannot be measured from Lua either, so the display-mode CVars are recorded
-- alongside the result. A capture that does not say which mode it was taken in
-- cannot answer the question afterwards.
local VIDEO_CVAR_GUESSES = { "gxBrightness", "gxContrast", "gxGamma" }
local DISPLAY_MODE_CVARS = {
    "gxMaximize", "gxWindow", "gxFullscreenResolution", "gxWindowedResolution", "gxMonitor",
}

local function videoCVarSnapshot(name)
    local snap = { name = name }
    if not (C_CVar and C_CVar.GetCVarInfo) then
        snap.err = "C_CVar.GetCVarInfo absent"
        return snap
    end
    local ok, value, default, srvAcct, srvChar, locked, secure, readOnly =
        pcall(C_CVar.GetCVarInfo, name)
    if not ok then
        snap.err = plain(value):sub(1, 120)
        return snap
    end
    if value == nil then
        snap.present = false
        return snap
    end
    snap.present = true
    snap.value = plain(value)
    snap.default = plain(default)
    snap.storedServerAccount = srvAcct and true or false
    snap.storedServerCharacter = srvChar and true or false
    snap.lockedFromUser = locked and true or false
    snap.secure = secure and true or false
    snap.readOnly = readOnly and true or false
    -- The three flags that decide, before any write is attempted, whether an addon
    -- is allowed to touch it.
    snap.writable = not (snap.lockedFromUser or snap.secure or snap.readOnly)
    return snap
end

local function discoverVideoCVars()
    local result = { matches = {} }
    if not ConsoleGetAllCommands then
        result.err = "ConsoleGetAllCommands absent on this client"
        return result
    end
    local ok, list = pcall(ConsoleGetAllCommands)
    if not ok then
        result.err = plain(list):sub(1, 120)
        return result
    end
    if type(list) ~= "table" then
        result.err = "returned " .. type(list) .. ", not a table"
        return result
    end
    result.total = #list
    for i = 1, #list do
        local entry, cmd = list[i], nil
        if type(entry) == "table" then
            -- Shape is unknown on this build, so record it once rather than
            -- guessing at the field name in silence.
            if not result.entryShape then
                local keys = {}
                for k in pairs(entry) do keys[#keys + 1] = plain(k) end
                table.sort(keys)
                result.entryShape = table.concat(keys, ",")
            end
            cmd = entry.command or entry.name or entry.commandName
        elseif type(entry) == "string" then
            cmd = entry
        end
        if type(cmd) == "string" then
            local lower = cmd:lower()
            if lower:find("bright", 1, true) or lower:find("contrast", 1, true)
                or lower:find("gamma", 1, true) then
                result.matches[#result.matches + 1] = cmd
            end
        end
    end
    table.sort(result.matches)
    return result
end

-- Nudge a CVar, read it back, put it back. The readback is the whole point: a
-- write that is accepted and ignored returns success and changes nothing, which
-- is the silent no this whole probe is built to catch.
local function videoWriteTest(snap, setter, setterName)
    local test = { via = setterName }
    local base = tonumber(snap.value)
    if base == nil then
        test.skipped = "current value is not numeric: " .. tostring(snap.value)
        return test
    end
    -- Small, always reversible, and away from zero so a proportional nudge moves.
    local target = (base > 0.05) and (base * 0.9) or (base + 0.1)
    test.from, test.target = base, target

    local tag = setterName .. "(" .. snap.name .. ")"
    activeTest = tag
    local ok, ret = pcall(setter, snap.name, ("%.4f"):format(target))
    activeTest = nil
    test.callOk = ok
    if ok then test.returned = plain(ret) else test.err = plain(ret):sub(1, 200) end

    local blocked = blocksFor(tag)
    if #blocked > 0 then test.blockEvents = blocked end

    -- Read back BEFORE restoring, or the measurement is gone.
    local okRead, readBack = pcall(C_CVar.GetCVar, snap.name)
    test.readBack = okRead and plain(readBack) or ("read failed: " .. plain(readBack))
    local n = okRead and tonumber(readBack) or nil
    test.tookEffect = (n ~= nil) and (math.abs(n - target) < 0.005) or false

    -- Restore unconditionally, including when the write looked like it failed. A
    -- partial success must not leave the player's screen where the probe put it.
    pcall(setter, snap.name, snap.value)
    local okAfter, after = pcall(C_CVar.GetCVar, snap.name)
    test.restoredTo = okAfter and plain(after) or "<restore readback failed>"

    test.allowed = ok and (#blocked == 0) and test.tookEffect
    return test
end

local function probeVideo()
    local inCombat = InCombatLockdown and InCombatLockdown() or false
    local video = {
        inCombat = inCombat,
        setterPresent = {
            ["C_CVar.SetCVar"] = (C_CVar and C_CVar.SetCVar) and true or false,
            ["SetCVar"] = SetCVar and true or false,
        },
        cvars = {}, displayMode = {}, writes = {},
    }

    out(("|cff44ddffvideo CVars|r  %s"):format(
        inCombat and "|cffffaa00IN COMBAT|r" or "out of combat"))

    -- 1. What are the names actually called on this client.
    local disc = discoverVideoCVars()
    video.discovery = disc
    if disc.err then
        out(("  console enumeration unavailable - %s"):format(disc.err))
        out("  falling back to the retail names, which are a guess on this build")
    else
        out(("  console commands matching bright/contrast/gamma: %d of %d")
            :format(#disc.matches, disc.total or 0))
        if #disc.matches > 0 then
            out("    " .. table.concat(disc.matches, ", "):sub(1, 240))
        end
    end

    -- Guesses first so their absence is recorded as a result, then anything the
    -- enumeration turned up that the guesses missed.
    local names, seen = {}, {}
    for _, n in ipairs(VIDEO_CVAR_GUESSES) do
        names[#names + 1] = n
        seen[n:lower()] = true
    end
    for _, n in ipairs(disc.matches) do
        if not seen[n:lower()] then
            names[#names + 1] = n
            seen[n:lower()] = true
        end
    end

    -- 2. Presence and the permission flags.
    for _, name in ipairs(names) do
        local snap = videoCVarSnapshot(name)
        video.cvars[name] = snap
        if snap.err then
            out(("  %-26s |cffff4444%s|r"):format(name, snap.err))
        elseif not snap.present then
            out(("  %-26s |cffff4444ABSENT on this client|r"):format(name))
        else
            local flags = {}
            if snap.lockedFromUser then flags[#flags + 1] = "lockedFromUser" end
            if snap.secure then flags[#flags + 1] = "secure" end
            if snap.readOnly then flags[#flags + 1] = "readOnly" end
            out(("  %-26s = %-10s default %-10s %s"):format(
                name, snap.value, snap.default,
                (#flags > 0) and ("|cffffaa00" .. table.concat(flags, ",") .. "|r")
                              or "|cff44ff44no lock flags|r"))
        end
    end

    -- 3. Does a write land. Both setters, because the documented namespaced one
    --    and the undocumented global one are not guaranteed to be protected the
    --    same way, and this costs one extra call to find out.
    local setters = {}
    if C_CVar and C_CVar.SetCVar then setters[#setters + 1] = { "C_CVar.SetCVar", C_CVar.SetCVar } end
    if SetCVar then setters[#setters + 1] = { "SetCVar", SetCVar } end
    if #setters == 0 then
        out("  |cffff4444no SetCVar on this client at all|r")
    end
    for _, name in ipairs(names) do
        local snap = video.cvars[name]
        if snap and snap.present and tonumber(snap.value) then
            for _, s in ipairs(setters) do
                local test = videoWriteTest(snap, s[2], s[1])
                video.writes[name .. " via " .. s[1]] = test
                if test.skipped then
                    out(("  write %-20s %-16s skipped - %s"):format(name, s[1], test.skipped))
                else
                    out(("  write %-20s %-16s %s  %.4f -> readback %s%s"):format(
                        name, s[1],
                        test.allowed and "|cff44ff44TOOK EFFECT|r" or "|cffff4444NO EFFECT|r",
                        test.target, tostring(test.readBack),
                        test.blockEvents and (" [" .. test.blockEvents[1] .. "]")
                            or (test.err and (" - " .. test.err:sub(1, 50)) or "")))
                end
            end
        end
    end

    -- 4. Which display mode this was measured in. Not an answer, but without it
    --    the fullscreen-only question cannot be settled from the capture later.
    for _, name in ipairs(DISPLAY_MODE_CVARS) do
        local ok, v = pcall(C_CVar.GetCVar, name)
        video.displayMode[name] = ok and plain(v) or "<read failed>"
    end
    if C_VideoOptions and C_VideoOptions.GetCurrentGameWindowSize then
        local ok, size = pcall(C_VideoOptions.GetCurrentGameWindowSize)
        if ok and type(size) == "table" then
            video.displayMode.windowSize = plain(size.x) .. "x" .. plain(size.y)
        end
    end
    local modeBits = {}
    for _, name in ipairs(DISPLAY_MODE_CVARS) do
        local v = video.displayMode[name]
        if v and v ~= "" and v ~= "<read failed>" then
            modeBits[#modeBits + 1] = name .. "=" .. v
        end
    end
    out("  display mode: " .. (table.concat(modeBits, "  "):sub(1, 220)))
    if video.displayMode.windowSize then
        out("  window size:  " .. video.displayMode.windowSize)
    end

    db.video = db.video or {}
    db.video[inCombat and "inCombat" or "outOfCombat"] = video

    out("next:")
    out("  |cffffffff/fprobe video ramp|r     sweep it and watch the screen - does it apply LIVE")
    out("  |cffffffff/fprobe video|r in combat  the combat half of the answer")
    out("  |cffffffff/fprobe blocked|r         if a forbidden-action popup appeared")
    return video
end

-- The live-apply measurement. Sweeps one CVar down and back from OnUpdate,
-- writing every frame, then reports how many frames it actually got. A cheap
-- post-process leaves the frame gaps flat; a device restart per write shows up as
-- a spike. Whether the SCREEN changed is still the player's to report - the
-- client does not say, and "accepted and ignored" looks identical from Lua.
local RAMP_SECONDS, RAMP_DEPTH = 4.0, 0.40
local rampFrame

local function videoRamp(nameArg)
    if rampFrame and rampFrame.running then
        return out("|cffffaa00a ramp is already running|r")
    end
    local setter = (C_CVar and C_CVar.SetCVar) or SetCVar
    if not setter then return out("|cffff4444no SetCVar on this client|r") end

    -- The slash handler lowercases the whole argument, so resolve back to the
    -- canonical spelling rather than passing a lowercased name through.
    local wanted = (nameArg and nameArg ~= "") and nameArg or nil
    local candidates = {}
    for _, n in ipairs(VIDEO_CVAR_GUESSES) do candidates[#candidates + 1] = n end
    for _, n in ipairs(discoverVideoCVars().matches) do candidates[#candidates + 1] = n end

    local target, snap
    for _, n in ipairs(candidates) do
        local s = videoCVarSnapshot(n)
        if wanted then
            if n:lower() == wanted then
                target, snap = n, s
                break
            end
        elseif s.present and s.writable and tonumber(s.value) then
            target, snap = n, s
            break
        end
    end
    if not target then
        return out(wanted
            and ("|cffff4444no CVar matching '" .. wanted .. "' - run /fprobe video first|r")
            or "|cffff4444no writable brightness/contrast CVar found - run /fprobe video first|r")
    end
    local base = tonumber(snap.value)
    if not base then
        return out(("|cffff4444%s is not numeric: %s|r"):format(target, tostring(snap.value)))
    end

    rampFrame = rampFrame or CreateFrame("Frame")
    local amplitude = base * RAMP_DEPTH
    local stats = {
        cvar = target, base = base, amplitude = amplitude, inCombat = InCombatLockdown
            and InCombatLockdown() or false,
        frames = 0, writes = 0, writeFailures = 0, elapsed = 0,
        maxDelta = 0, minDelta = 999,
    }

    local function restore()
        rampFrame.running = false
        rampFrame:SetScript("OnUpdate", nil)
        pcall(setter, target, snap.value)
    end

    out(("|cff44ddfframp|r %s  %.4f -> %.4f -> %.4f over %.0fs - |cffffffffwatch the screen|r")
        :format(target, base, base - amplitude, base, RAMP_SECONDS))

    rampFrame.running = true
    rampFrame:SetScript("OnUpdate", function(_, delta)
        stats.frames = stats.frames + 1
        stats.elapsed = stats.elapsed + delta
        if delta > stats.maxDelta then stats.maxDelta = delta end
        if delta < stats.minDelta then stats.minDelta = delta end

        if stats.elapsed >= RAMP_SECONDS then
            restore()
            db.video = db.video or {}
            db.video.ramp = stats
            local fps = stats.frames / math.max(stats.elapsed, 0.001)
            out(("  %d frames in %.2fs (%.0f/s), %d writes, %d failures")
                :format(stats.frames, stats.elapsed, fps, stats.writes, stats.writeFailures))
            out(("  frame gap min %.1f ms, max %.1f ms")
                :format(stats.minDelta * 1000, stats.maxDelta * 1000))
            if stats.maxDelta > 0.1 then
                out("  |cffffaa00frame gap spiked - each write looks expensive (device restart?)|r")
            else
                out("  |cff44ff44no frame-gap spike - cheap enough to drive a per-frame ease|r")
            end
            out("  |cffffffffDid the screen actually change?|r If nothing happened at all, the")
            out("  write was accepted and ignored - that is a silent no, and it is a result.")
            return
        end

        -- sin(0..pi) gives 0 -> 1 -> 0, so it ends exactly where it started even
        -- if the restore below were to fail.
        local f = math.sin(stats.elapsed / RAMP_SECONDS * math.pi)
        local ok = pcall(setter, target, ("%.4f"):format(base - amplitude * f))
        if ok then stats.writes = stats.writes + 1 else stats.writeFailures = stats.writeFailures + 1 end
    end)

    -- Belt and braces. If OnUpdate stops firing mid-sweep - which is exactly what
    -- a device restart per write might do - the player is left sitting at a
    -- darkened screen with no way back.
    if C_Timer and C_Timer.After then
        C_Timer.After(RAMP_SECONDS + 2, function()
            if rampFrame and rampFrame.running then
                restore()
                out("|cffffaa00ramp did not finish on its own - value restored|r")
                out("  OnUpdate stalled mid-sweep, which is itself the answer to 'is it live'.")
            end
        end)
    end
end

-- Driver ----------------------------------------------------------------------
SLASH_FPROBE1 = "/fprobe"
SlashCmdList.FPROBE = function(arg)
    local cmd, sub, extra = ((arg or ""):lower()):match("^%s*(%S*)%s*(%S*)%s*(%S*)")
    cmd, sub = cmd or "", sub or ""
    if cmd == "report" then return printReport() end
    if cmd == "blocked" then return printBlocked() end
    if cmd == "events" then return probeEvents() end
    if cmd == "docs" then
        if sub == "version" then return docsVersionCheck(true) end
        if sub == "dump" then
            -- The two range numbers come off the raw argument, because the
            -- three-token parse above only reaches as far as `extra`.
            local a, b = (arg or ""):match("docs%s+dump%s+(%d*)%s*(%d*)")
            return dumpApiDocs(tonumber(a), tonumber(b))
        end
        return probeApiDocs()
    end
    if cmd == "external" then return printExternal() end
    if cmd == "video" then
        if sub == "ramp" then return videoRamp(extra) end
        return probeVideo()
    end
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
    -- An unrecognised command used to fall straight through to the full scan,
    -- which looks exactly like a successful run. That hid a stale install for a
    -- whole session on 2026-09-18: /fprobe video printed the surface scan and
    -- read as "video is broken" rather than "this copy predates video".
    if cmd ~= "" then
        if cmd ~= "help" then
            out(("|cffffaa00unknown command:|r %s  |cff888888(this copy of the addon may predate it)|r")
                :format(cmd))
        end
        out("  |cffffffff/fprobe|r               surface scan and action tests, out of combat")
        out("  |cffffffff/fprobe combat|r        re-run them in combat, then /fprobe report")
        out("  |cffffffff/fprobe ah|r            auction house detail (browse, scan, throttle)")
        out("  |cffffffff/fprobe video|r         brightness/contrast CVars (ramp)")
        out("  |cffffffff/fprobe events|r        which events an addon may subscribe to")
        out("  |cffffffff/fprobe blocked|r       captured BLOCKED/FORBIDDEN actions")
        out("  |cffffffff/fprobe external|r      inbound ExternalData.lua, outbound flush")
        out("  |cffffffff/fprobe docs|r          Blizzard's API documentation (dump, version)")
        return
    end

    db.timestamp = date and date("%Y-%m-%d %H:%M:%S") or time()
    local version, build, _, toc = GetBuildInfo()
    db.build = { version = version, build = build, tocversion = toc }
    out(("build %s (%s) toc %s"):format(tostring(version), tostring(build), tostring(toc)))
    probeSurfaces()
    probeGlobals()
    printExternal()
    out("action tests:")
    runActionTests()
    out("next: |cffffffff/fprobe ah|r at an auction house, |cffffffff/fprobe combat|r on a mob, then /reload.")
end
