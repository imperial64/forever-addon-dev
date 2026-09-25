-- sv-file-scope-alias without the directive. test_lint.py pins every line.
SVAliasDB = SVAliasDB or {}
local db = SVAliasDB
local opts = SVAliasDB or {}
local cfg = SVAliasDB.config
local count = SVAliasDBCount
local lib = LibStub
local fixed = SVAliasFixedDB
-- local quoted = SVAliasDB
local unset = SVAliasDB == nil
local function onLoaded()
    local inner = SVAliasDB
    fixed = SVAliasFixedDB
end
