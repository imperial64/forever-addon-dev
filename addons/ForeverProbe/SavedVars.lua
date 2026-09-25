-- SavedVars.lua
--
-- Settles what is actually wrong with SavedVariables on this client.
--
-- The repo's measured position is §P.9: the client writes the file and never
-- reads it back. Three third-party reports disagree with each other about why,
-- and the difference matters because two of the three would mean the bug is
-- OURS and avoidable:
--
--   a) The client never restores the table.           -> nothing an addon can do.
--   b) Only some WTF paths are restored.              -> seed the others (scripts/seed-savedvars.ps1).
--   c) The client restores it, and the addon's own file-scope initialiser then
--      replaces it, so the empty table is what gets serialised on exit.
--
-- (c) is the interesting one. It hinges entirely on LOAD ORDER. Retail runs the
-- addon's Lua files first and restores saved variables afterwards, which is
-- exactly why `MyDB = MyDB or {}` at file scope is a retail bug: the global is
-- swapped out from under the local you just took. One port diary reports that
-- Forever does the opposite and restores BEFORE executing addon Lua, which
-- would make the same line safe and would mean something else is broken.
--
-- Nobody has published a measurement of the order. This file is that
-- measurement, and it is why it loads FIRST in the .toc: the earliest moment
-- addon code can observe the globals is the whole point. It records the state
-- of every declared saved global at each phase (file scope, after
-- ForeverProbe.lua's own initialiser, ADDON_LOADED, login), including each table's
-- ADDRESS, so a table being swapped between phases is visible rather than
-- inferred.
--
-- Four globals, three binding idioms, and a control written from outside:
--
--   ForeverProbeDB       `X = X or {}` at file scope - what the probe has always
--                        done, and what every previous capture was taken with.
--                        Owned by ForeverProbe.lua; only observed here.
--   ForeverProbeBind     never touched at file scope; bound and mutated only
--                        inside ADDON_LOADED. The idiom the port diary says
--                        working addons use.
--   ForeverProbeClobber  unconditionally reassigned at file scope. The control
--                        for (c): if the client restores anything at all, this
--                        one and only this one should come back empty.
--   ForeverProbeChar     SavedVariablesPerCharacter, bound like Bind. A third
--                        path on disk, and a third chance for one to work.
--   ForeverProbeSeed     never written by this addon. scripts/seed-savedvars.ps1
--                        writes a differently tokenised copy into every
--                        candidate WTF path at once; whichever token arrives
--                        names the path the client actually reads.
--
-- Nothing here prints. It collects into ns.savedVars and ForeverProbe.lua
-- reports it, so this file stays dependency-free and can load first.
--
-- Everything is wrapped, because an error in a main chunk aborts the rest of
-- the file and this one runs before the addon that would report the failure.

local ADDON, ns = ...

-- The globals to watch, and whether this addon is allowed to write them.
-- `seed` is deliberately read-only: writing it would destroy the thing the
-- external script put there.
local WATCHED = {
    { name = "ForeverProbeDB",      idiom = "file-scope `X = X or {}`", write = false },
    { name = "ForeverProbeBind",    idiom = "bound on ADDON_LOADED",    write = true  },
    { name = "ForeverProbeClobber", idiom = "file-scope reassignment",  write = true  },
    { name = "ForeverProbeChar",    idiom = "per-character, on ADDON_LOADED", write = true },
    { name = "ForeverProbeSeed",    idiom = "written from outside the client", write = false },
}

local record = { phases = {}, order = "unknown", note = nil }
ns.savedVars = record

-- tostring() on a plain table gives "table: 0x00000221...". The address is the
-- only way to tell "the same table, mutated" from "a different table put in its
-- place", which is the single fact this whole file exists to establish.
local function addressOf(t)
    local ok, str = pcall(tostring, t)
    if not ok then return "?" end
    return str:match("0x%x+") or str
end

local function inspect(name)
    local info = { name = name }
    local ok, value = pcall(rawget, _G, name)
    if not ok then info.type = "ERR"; return info end
    info.type = type(value)
    if type(value) ~= "table" then return info end
    -- A restored saved table cannot be secret, but this runs before the
    -- addon's plain() helper exists and a throw here would take the file out.
    if hasanysecretvalues and pcall(hasanysecretvalues, value) and hasanysecretvalues(value) then
        info.secret = true
        return info
    end
    info.addr = addressOf(value)
    local count = 0
    local okIter = pcall(function()
        for _ in pairs(value) do count = count + 1 end
    end)
    info.keys = okIter and count or -1
    local function field(key)
        local okField, v = pcall(rawget, value, key)
        if okField and (type(v) == "string" or type(v) == "number") then return v end
        return nil
    end
    info.token = field("token")
    info.session = field("session")
    info.path = field("path")      -- only ForeverProbeSeed carries one
    info.stampedAt = field("stampedAt")
    -- Captured once by stamp(), before this session wrote anything. A non-nil
    -- restoredToken is the only positive proof that the client read the file
    -- back, and it is what printSavedVars() reports on.
    info.restoredToken = field("restoredToken")
    info.restoredSession = field("restoredSession")
    -- The 70009 cold-start test (`/fprobe cold seed`) writes its markers into a
    -- `coldTest` subtable, kept apart from the fields above so the two
    -- instruments cannot overwrite each other's evidence.
    local okCold, cold = pcall(rawget, value, "coldTest")
    if okCold and type(cold) == "table" then
        local okC, c = pcall(rawget, cold, "coldToken")
        local okR, r = pcall(rawget, cold, "reloadToken")
        if okC and type(c) == "string" then info.cold = c end
        if okR and type(r) == "string" then info.reload = r end
    end
    return info
end

local function snapshot(phase)
    local globals = {}
    for index, spec in ipairs(WATCHED) do
        globals[index] = inspect(spec.name)
        globals[index].idiom = spec.idiom
    end
    record.phases[#record.phases + 1] = { phase = phase, globals = globals }
    return globals
end

-- ForeverProbe.lua calls this right after its own `X = X or {}` line. Without
-- it, the only file-scope observation of ForeverProbeDB is the one above,
-- taken BEFORE that line runs: on a build that restores after file scope it
-- reads nil, there is no file-scope address to compare against, and a swap
-- the rebind guard saw plainly went unrecorded here. Measured 2026-09-25 on
-- 70009: `/fprobe sv` said "nothing was restored" on the same load that
-- `/fprobe cold` reported ForeverProbeDB replaced after file scope.
ns.savedVarsObserve = function(phase)
    pcall(snapshot, phase)
end

-- Write a token into the tables this addon owns, so the NEXT session can say
-- whether it survived. The session counter is the cheap version of the same
-- question: it only ever climbs if the client restored the table.
local sessionToken = ("%s-%d"):format(
    (date and date("%H%M%S")) or tostring(time and time() or 0),
    math.random(1000, 9999))
record.tokenWrittenThisSession = sessionToken

-- Write-once, and this is the second attempt at it.
--
-- The first version stamped on every phase, which ran three times a session and
-- did two things wrong at once. `session` counted STAMPS, so it read 3 after a
-- single session and the "session > 1 means something was restored" test in
-- printSavedVars() was always true for the wrong reason. And
-- `previousToken = token` on the second stamp overwrote the restored token with
-- this session's own, destroying the only cross-session evidence the file
-- collects. The 2026-09-20 capture reads `session = 3` on everything because of
-- it; the addresses carried that run instead.
--
-- So the survival evidence is captured ONCE, before anything is written, and the
-- counter moves once. Later phases may only update stampedAt.
local stamped = {}

local function stamp(phase)
    for _, spec in ipairs(WATCHED) do
        if spec.write then
            local t = rawget(_G, spec.name)
            if type(t) == "table" then
                pcall(function()
                    if not stamped[spec.name] then
                        stamped[spec.name] = true
                        -- Whatever is here NOW arrived from disk, or nothing did.
                        t.restoredToken = t.token
                        t.restoredSession = tonumber(t.session) or 0
                        t.boundAt = phase
                        t.token = sessionToken
                        t.session = (tonumber(t.session) or 0) + 1
                    end
                    t.stampedAt = phase
                end)
            end
        end
    end
end

-- Phase 1: file scope, before anything else in this addon runs ---------------
--
-- Observe BEFORE writing anything. If ForeverProbeDB already carries last
-- session's token right here, saved variables are restored before addon Lua
-- executes and the port diary is right about the order.
local atFileScope = snapshot("file-scope")

-- The control. Unconditional, which is the bug being reproduced on purpose: if
-- the client restores this table and then this line throws it away, the empty
-- replacement is what gets written back out at logout.
ForeverProbeClobber = { createdAt = "file-scope" }  -- lint-allow: sv-file-scope-init - the control case for findings 11/12; clobbering deliberately

-- Read the file-scope evidence while it is fresh. ForeverProbeDB is the one
-- with history: every capture in research/captures/ was taken through it.
for _, info in ipairs(atFileScope) do
    if info.name == "ForeverProbeDB" and info.type == "table" and (info.keys or 0) > 0 then
        record.order = "saved-variables-restored-BEFORE-addon-lua"
        record.note = "ForeverProbeDB already held " .. tostring(info.keys) ..
            " keys at file scope, so the client restores before it executes addon code."
    end
end

-- The verdict, decided once every observation up to ADDON_LOADED is in.
--
-- Three kinds of evidence, per global, all of them plain data so the record
-- can be serialised as it stands:
--   atFileScope  a table was already there when this file started, before any
--                addon code ran: restored BEFORE addon Lua
--   swapped      a different table sat at the global by ADDON_LOADED than the
--                LAST file-scope observation saw (ForeverProbe.lua reports one
--                after its own initialiser, so ForeverProbeDB is covered):
--                restored AFTER addon Lua, under the file-scope binding
--   appeared     nil at every file-scope observation, a table by ADDON_LOADED:
--                restored after addon Lua, with nothing to swap out
-- plus the write-once token stamp() captured. `readBack` - "does the client
-- read them back at all" - is true on any token, any seeded path, or any
-- restored table with content in it, whatever the order turned out to be.
-- It is what printSavedVars() checks before it will ever say "no".
local function isFileScopePhase(name)
    return type(name) == "string" and name:sub(1, 10) == "file-scope"
end

local function decideOrder(before, after)
    local evidence, anyBefore, anyAfter, readBack = {}, {}, {}, false
    local dbSwap
    for index, spec in ipairs(WATCHED) do
        local ev = {}
        local first = record.phases[1] and record.phases[1].globals[index]
        local lastSeen
        for _, phase in ipairs(record.phases) do
            if isFileScopePhase(phase.phase) and phase.globals[index] then
                lastSeen = phase.globals[index]
            end
        end
        local now = before[index]
        local done = after[index]
        if first and first.type == "table" then
            ev.atFileScope = true
            ev.fileScopeKeys = first.keys
            if lastSeen and lastSeen.addr and first.addr and lastSeen.addr ~= first.addr then
                ev.replacedAtFileScope = true   -- the Clobber control, doing its job
            end
            anyBefore[#anyBefore + 1] = spec.name
        end
        if now and now.type == "table" and lastSeen then
            if lastSeen.addr and now.addr and lastSeen.addr ~= now.addr then
                ev.swapped = { from = lastSeen.addr, to = now.addr, phase = lastSeen.phase }
                anyAfter[#anyAfter + 1] = spec.name
                if spec.name == "ForeverProbeDB" then dbSwap = ev.swapped end
            elseif lastSeen.type ~= "table" then
                ev.appeared = true
                anyAfter[#anyAfter + 1] = spec.name
            end
            ev.keysAtLoad = now.keys
        end
        if done and done.restoredToken then ev.token = done.restoredToken end
        if done and done.path then ev.seedPath = done.path end
        if ev.token or ev.seedPath
           or ((ev.atFileScope or ev.swapped or ev.appeared)
               and ((ev.fileScopeKeys or 0) > 0 or (ev.keysAtLoad or 0) > 0)) then
            ev.restored = true
            readBack = true
        end
        evidence[spec.name] = ev
    end
    record.evidence = evidence
    record.readBack = readBack

    local function names(list)
        return (table.concat(list, ", "):gsub("ForeverProbe", ""))
    end
    if #anyBefore > 0 and #anyAfter > 0 then
        record.order = "inconsistent"
        record.note = "present at file scope: " .. names(anyBefore) ..
            "; replaced or restored after it: " .. names(anyAfter) ..
            ". Both orders at once; read the address trace."
    elseif #anyBefore > 0 then
        record.order = "saved-variables-restored-BEFORE-addon-lua"
        record.note = names(anyBefore) ..
            " already held a table at file scope: the client restores before it executes addon code."
    elseif #anyAfter > 0 then
        record.order = "saved-variables-restored-AFTER-addon-lua"
        -- Kept under 200 characters: the reporter prints it through plain(),
        -- which cuts there. The per-global lines carry the addresses.
        if dbSwap then
            record.note = "ForeverProbeDB was swapped after file scope, so the file-scope" ..
                " `local db` was orphaned until the rebind guard re-pointed it."
        else
            record.note = "restored after file scope, by ADDON_LOADED: " .. names(anyAfter)
        end
    else
        record.order = "unknown"
        record.note = nil
    end
end

local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", function(_, event, addon)
    if event == "ADDON_LOADED" then
        if addon ~= ADDON then return end
        -- Bind here and nowhere else. This is the idiom under test.
        local before = snapshot("ADDON_LOADED-before-bind")
        ForeverProbeBind = ForeverProbeBind or {}
        ForeverProbeChar = ForeverProbeChar or {}
        stamp("ADDON_LOADED")
        local after = snapshot("ADDON_LOADED-after-bind")
        pcall(decideOrder, before, after)
        return
    end
    if event == "PLAYER_LOGIN" then
        snapshot("PLAYER_LOGIN")
        stamp("PLAYER_LOGIN")
        return
    end
    if event == "PLAYER_ENTERING_WORLD" then
        snapshot("PLAYER_ENTERING_WORLD")
        stamp("PLAYER_ENTERING_WORLD")
        -- Nothing after this point can still be called "restoration at load".
        frame:UnregisterAllEvents()
        return
    end
end)

-- pcall, per the rule this addon was written around: an event this client does
-- not know RAISES, and a raise here would remove the measurement entirely.
for _, event in ipairs({ "ADDON_LOADED", "PLAYER_LOGIN", "PLAYER_ENTERING_WORLD" }) do
    pcall(frame.RegisterEvent, frame, event)
end
