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
-- of every declared saved global at four phases, including each table's
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

local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", function(_, event, addon)
    if event == "ADDON_LOADED" then
        if addon ~= ADDON then return end
        -- Bind here and nowhere else. This is the idiom under test.
        local before = snapshot("ADDON_LOADED-before-bind")
        ForeverProbeBind = ForeverProbeBind or {}
        ForeverProbeChar = ForeverProbeChar or {}
        stamp("ADDON_LOADED")
        snapshot("ADDON_LOADED-after-bind")

        -- The other half of the order question, and the one that would mean the
        -- probe's own idiom was the bug all along: if the DB's address changed
        -- between file scope and here, the client swapped the global out from
        -- under the `local db` that ForeverProbe.lua took at file scope, and
        -- every write since has gone into an orphan.
        for index, info in ipairs(before) do
            local was = atFileScope[index]
            if info.name == "ForeverProbeDB" and was and was.addr and info.addr
               and was.addr ~= info.addr then
                record.order = "saved-variables-restored-AFTER-addon-lua"
                record.note = "ForeverProbeDB changed address between file scope (" ..
                    was.addr .. ") and ADDON_LOADED (" .. info.addr ..
                    "), so the file-scope `local db` is pointing at an orphaned table."
            end
        end
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
