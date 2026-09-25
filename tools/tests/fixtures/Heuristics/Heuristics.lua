-- Heuristic fixtures: lines that must fire and lines that must stay silent.
-- test_lint.py pins each one by line number, so do not reflow this file.

local hasSnippets = type(loadstring_untainted) == "function"
if not _G.loadstring_untainted then end
local compile = _G["loadstring_untainted"] or loadstring
if rawget(_G, "loadstring_untainted") then end
local record = { t = type(rawget(_G, "loadstring_untainted")) }
-- if loadstring_untainted then
print("if loadstring_untainted then")

if frame:HasAnyForbiddenAspects() and aspects == 0x1000 then end
local ASPECTS = {
    QueryAnimationProgress = 2048,
    QueryRotation = Enum.ForbiddenAspect.QueryRotation,
}
frame:AddForbiddenAspects(Enum.ForbiddenAspect.ChangeParent)
local bufferSize = 4096
if size > 2048 and x == 16384 then end
frame:AddForbiddenAspects(1024)
