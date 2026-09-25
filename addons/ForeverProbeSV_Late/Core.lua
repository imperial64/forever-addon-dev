-- Core.lua - the SavedVariables cold-start companion, shared by both variants.
--
-- THIS FILE IS IDENTICAL in addons/ForeverProbeSV_First/ and
-- addons/ForeverProbeSV_Late/. scripts/install-addon.ps1 refuses to install
-- when the two copies differ. Everything variant-specific lives in the .toc
-- (the `## LoadSavedVariablesFirst: 1` line) and in Init.lua (the literal
-- file-scope assignments). Edit one copy, then copy it over the other.
--
-- Why two addons: research/watch-findings.md W.30 found that the Forever client
-- honours `## LoadSavedVariablesFirst: 1`, which moves the saved-variable restore
-- ahead of the addon's own Lua. A directive is per addon, so the with and
-- without cases need an addon each to run in one session. W.32 reports the
-- read-back bug itself fixed in build 70009; these two are the instrument for it.
--
-- Six saved globals per variant, named <addon><key>:
--
--   DB           account-wide, bound on ADDON_LOADED (`X = X or {}` there)
--   Char         per-character, bound on ADDON_LOADED
--   Clobber      account-wide, `X = { fresh = true }` unconditionally at file scope
--   OrInit       account-wide, `X = X or { fresh = true }` at file scope
--   CharClobber  per-character twin of Clobber
--   CharOrInit   per-character twin of OrInit
--
-- Each is inspected at five phases: file scope before Init.lua assigns anything,
-- file scope after, ADDON_LOADED (before binding), PLAYER_LOGIN and
-- PLAYER_ENTERING_WORLD. `/fprobe cold seed` writes a marker into all six, and
-- `/fprobe cold` reads the phases back. Nothing here prints; ForeverProbe does
-- the reporting, and this addon also keeps its own observations in its DB so
-- the capture has them even if /fprobe is never run.
--
-- Every read is wrapped: an error in a main chunk aborts the rest of the file.

local ADDON, ns = ...
local VARIANT = ADDON:match("_(%a+)$") or ADDON
local KEYS = { "DB", "Char", "Clobber", "OrInit", "CharClobber", "CharOrInit" }

local record = { addon = ADDON, variant = VARIANT, phases = {}, load = {} }
ns.record = record

-- Only strings, numbers and booleans are kept, and never a secret: a secret in
-- a saved table would take the whole SavedVariables flush with it.
local function safe(v)
    if v == nil then return nil end
    if issecretvalue then
        local ok, secret = pcall(issecretvalue, v)
        if not ok or secret then return "<SECRET>" end
    end
    local t = type(v)
    if t == "string" or t == "number" or t == "boolean" then return v end
    return nil
end

-- The address is what tells "the same table, mutated" from "a different table
-- put in its place", which is the clobber question.
local function addressOf(t)
    local ok, s = pcall(tostring, t)
    if not ok or type(s) ~= "string" then return "?" end
    return s:match("0x%x+") or s
end

local function field(t, key)
    local ok, v = pcall(rawget, t, key)
    if not ok then return nil end
    return safe(v)
end

-- Whether the client exposes the directive back to Lua at all is unknown, so it
-- is read and recorded rather than assumed. `declared` is what the .toc says.
local function metadata(key)
    local getter = (C_AddOns and C_AddOns.GetAddOnMetadata) or rawget(_G, "GetAddOnMetadata")
    if type(getter) ~= "function" then return "no GetAddOnMetadata" end
    local ok, v = pcall(getter, ADDON, key)
    if not ok then return "raised" end
    if v == nil then return "nil" end
    return tostring(safe(v))
end
record.declared = (VARIANT == "First") and "LoadSavedVariablesFirst: 1" or "absent"
record.directive = metadata("LoadSavedVariablesFirst")
record.tocVariant = metadata("X-SVVariant")

local function inspect(key)
    local info = {}
    local ok, value = pcall(rawget, _G, ADDON .. key)
    if not ok then info.type = "ERR"; return info end
    info.type = type(value)
    if info.type ~= "table" then return info end
    info.addr = addressOf(value)
    local count = 0
    pcall(function() for _ in pairs(value) do count = count + 1 end end)
    info.keys = count
    info.cold = field(value, "coldToken")
    info.reload = field(value, "reloadToken")
    if field(value, "fresh") == true then info.fresh = true end
    return info
end

function ns.snapshot(phase)
    local globals = {}
    for _, key in ipairs(KEYS) do globals[key] = inspect(key) end
    record.phases[#record.phases + 1] = {
        phase = phase,
        at = date and date("%H:%M:%S") or nil,
        globals = globals,
    }
end

-- The seed, called by `/fprobe cold seed`. `kind` is "cold" or "reload", so the
-- two legs never share a field. `fresh` is cleared so a table that comes back
-- from disk cannot be mistaken for the file-scope one.
local function seed(kind, token, at)
    local written = 0
    for _, key in ipairs(KEYS) do
        local t = rawget(_G, ADDON .. key)
        if type(t) == "table" then
            t[kind .. "Token"] = token
            t[kind .. "SeededAt"] = at
            t.fresh = nil
            written = written + 1
        end
    end
    return ("%d/%d"):format(written, #KEYS)
end

-- A plain global, not a saved one: ForeverProbe finds the companions through it.
local registry = rawget(_G, "ForeverProbeSVTest")
if type(registry) ~= "table" then
    registry = {}
    ForeverProbeSVTest = registry
end
registry[ADDON] = { record = record, seed = seed, keys = KEYS, variant = VARIANT }

local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", function(_, event, a1, a2)
    if event == "ADDON_LOADED" then
        if a1 ~= ADDON then return end
        -- Observe first, then bind. What is here now arrived from disk or was
        -- put here by Init.lua at file scope; nothing else has touched it.
        ns.snapshot("ADDON_LOADED")
        for _, key in ipairs({ "DB", "Char" }) do
            if type(rawget(_G, ADDON .. key)) ~= "table" then
                rawset(_G, ADDON .. key, {})
            end
        end
        return
    end
    if event == "PLAYER_LOGIN" then
        ns.snapshot("PLAYER_LOGIN")
        return
    end
    if event == "PLAYER_ENTERING_WORLD" then
        -- The two arguments say which leg this load is: a cold start reads
        -- initialLogin=true, a /reload reads reloadingUi=true.
        record.load.initialLogin = safe(a1)
        record.load.reloadingUi = safe(a2)
        ns.snapshot("ENTERING_WORLD")
        pcall(frame.UnregisterAllEvents, frame)
        -- Keep this load's observations in the addon's own file as well, the
        -- last six loads, so the capture stands without /fprobe.
        local store = rawget(_G, ADDON .. "DB")
        if type(store) == "table" then
            if type(store.observed) ~= "table" then store.observed = {} end
            table.insert(store.observed, {
                at = date and date("%Y-%m-%d %H:%M:%S") or nil,
                declared = record.declared, directive = record.directive,
                load = record.load, phases = record.phases,
            })
            while #store.observed > 6 do table.remove(store.observed, 1) end
        end
        return
    end
end)

-- pcall, per the rule: an event this client does not know RAISES.
for _, event in ipairs({ "ADDON_LOADED", "PLAYER_LOGIN", "PLAYER_ENTERING_WORLD" }) do
    pcall(frame.RegisterEvent, frame, event)
end
