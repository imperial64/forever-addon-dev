-- Forever Probe
--
-- Records the addon API surface of WoW Forever and empirically determines what a
-- rotation helper can and cannot do. Built around one question the press quotes
-- cannot answer: is the in-combat "disarmament" the same shape as retail's, where
-- an addon may SUGGEST an ability but never PRESS it?
--
--   /fprobe          static surface scan + action tests out of combat
--   /fprobe combat   re-run the action tests while actually in combat
--   /fprobe report   print the out-of-combat vs in-combat delta
--
-- Results persist to WTF/Account/<ACCT>/SavedVariables/ForeverProbe.lua on
-- /reload or logout.
--
-- Blocked actions do NOT always raise a Lua error. They frequently fire
-- ADDON_ACTION_BLOCKED or ADDON_ACTION_FORBIDDEN instead, so pcall alone would
-- report a false "allowed". Both events are captured and correlated with
-- whichever test was running.

ForeverProbeDB = ForeverProbeDB or {}
local db = ForeverProbeDB

local function out(msg) DEFAULT_CHAT_FRAME:AddMessage("|cff44ddffFProbe|r " .. tostring(msg)) end

-- Block capture ---------------------------------------------------------------
local activeTest, blockLog = nil, {}

local watcher = CreateFrame("Frame")
watcher:RegisterEvent("ADDON_ACTION_BLOCKED")
watcher:RegisterEvent("ADDON_ACTION_FORBIDDEN")
watcher:RegisterEvent("PLAYER_LOGIN")
watcher:SetScript("OnEvent", function(_, event, addon, func)
    if event == "PLAYER_LOGIN" then
        out("loaded. /fprobe out of combat, then /fprobe combat mid-fight.")
        return
    end
    if addon == "ForeverProbe" or activeTest then
        blockLog[#blockLog + 1] = { event = event, addon = addon, func = func, test = activeTest }
    end
end)

-- Combat log monitor ----------------------------------------------------------
-- The doctrine says addons can no longer parse combat events in real time. That
-- could mean the event stops firing, fires with fields stripped, or fires only
-- out of combat. Passively count events and keep a sample of each so the shape
-- of any restriction is visible rather than guessed at.
local clog = { count = 0, inCombatCount = 0, samples = {}, subevents = {} }

local clogFrame = CreateFrame("Frame")
clogFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
clogFrame:SetScript("OnEvent", function()
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

local function blocksFor(test)
    local hits = {}
    for _, b in ipairs(blockLog) do
        if b.test == test then hits[#hits + 1] = b.event .. ":" .. tostring(b.func) end
    end
    return hits
end

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

-- What a rotation helper READS. None of this should be restricted. If any of it
-- is missing, a rotation helper cannot compute a recommendation at all, which is
-- a far harder blocker than the execute-side rules.
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

-- The three original addon plans, unchanged.
local PLAN_SURFACE = {
    "C_AuctionHouse", "QueryAuctionItems", "GetAuctionItemInfo", "GetNumAuctionItems",
    "C_GuildInfo", "C_Club", "GetGuildRosterInfo", "GuildRoster", "C_GuildBank",
    "C_ChatInfo.SendAddonMessage", "SendAddonMessage", "C_ChatInfo.RegisterAddonMessagePrefix",
    "io", "os", "loadstring", "require", "debug", "package",
}

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
    if lookup("C_AssistedCombat") then
        out("|cffffaa00C_AssistedCombat PRESENT|r - Blizzard ships its own rotation assist here")
    end
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
    local probeSpell = GetSpellInfo and GetSpellInfo(1) or nil

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
        local ok, v = pcall(fn)
        reads[name] = ok and tostring(v) or ("ERR: " .. tostring(v):sub(1, 80))
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

    db.actions = db.actions or {}
    db.actions[label] = results
    db.blockLog = blockLog
    db.combatLog = clog
    out(("combat log events seen so far: %d total, %d while in combat, %d distinct subevents")
        :format(clog.count, clog.inCombatCount, (function()
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
    out(("  combat log: %d events, %d in combat%s"):format(
        (db.combatLog and db.combatLog.count) or 0,
        (db.combatLog and db.combatLog.inCombatCount) or 0,
        (db.combatLog and db.combatLog.error) and (" |cffff4444ERR: " .. db.combatLog.error .. "|r") or ""))

    db.delta = { combatOnly = combatOnly, flatBan = flatBan, maskedReads = masked }
end

-- Driver ----------------------------------------------------------------------
SLASH_FPROBE1 = "/fprobe"
SlashCmdList.FPROBE = function(arg)
    arg = (arg or ""):lower():match("^%s*(%S*)") or ""
    if arg == "report" then return printReport() end
    if arg == "combat" then
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
    out("action tests:")
    runActionTests()
    out("now pull a mob and run |cffffffff/fprobe combat|r, then /reload.")
end
