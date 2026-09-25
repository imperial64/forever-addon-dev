-- With `## LoadSavedVariablesFirst: 1` the restore has already happened when
-- this line runs, so the unconditional assignment below discards it.
SVFirstDB = { fresh = true }
SVFirstKeptDB = SVFirstKeptDB or { fresh = true }
local kept = SVFirstKeptDB
local db = SVFirstDB
local early = SVFirstResetDB
local function reset()
    SVFirstResetDB = {}
end
