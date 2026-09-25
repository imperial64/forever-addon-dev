-- Init.lua - ForeverProbeSV_First, the variant WITH `## LoadSavedVariablesFirst: 1`.
--
-- The only Lua that differs between the two variants, because the file-scope
-- assignments under test have to name their globals literally. Core.lua has
-- already run and taken nothing; this file observes, assigns, and observes
-- again, all at file scope.
--
-- What each outcome means, W.30's clobber check:
--   With the directive the restore happens BEFORE this file, so fs-before
--   should already show the marker, Clobber should throw it away (and the
--   empty table is what gets written at exit), and OrInit should keep it.
--   Without it (ForeverProbeSV_Late) the restore happens AFTER, so fs-before
--   is empty, and both should show the marker by ADDON_LOADED - the client's
--   restore replacing whatever this file put there.

local _, ns = ...

if ns.snapshot then ns.snapshot("fs-before") end

ForeverProbeSV_FirstClobber = { fresh = true }  -- lint-allow: sv-file-scope-init - the W.30 clobber control; unconditional on purpose
ForeverProbeSV_FirstOrInit = ForeverProbeSV_FirstOrInit or { fresh = true }
ForeverProbeSV_FirstCharClobber = { fresh = true }  -- lint-allow: sv-file-scope-init - per-character twin of the clobber control
ForeverProbeSV_FirstCharOrInit = ForeverProbeSV_FirstCharOrInit or { fresh = true }

if ns.snapshot then ns.snapshot("fs-after") end
