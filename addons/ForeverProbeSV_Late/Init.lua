-- Init.lua - ForeverProbeSV_Late, the variant WITHOUT `## LoadSavedVariablesFirst`.
--
-- The only Lua that differs between the two variants, because the file-scope
-- assignments under test have to name their globals literally. Core.lua has
-- already run and taken nothing; this file observes, assigns, and observes
-- again, all at file scope.
--
-- What each outcome means, W.30's clobber check:
--   Without the directive the restore is expected AFTER this file (retail's
--   order), so fs-before is empty and both Clobber and OrInit should show the
--   marker by ADDON_LOADED, with a changed address: the client's restore
--   replacing whatever this file put there. If Clobber comes back fresh
--   instead, the default order on this client is restore-first after all.

local _, ns = ...

if ns.snapshot then ns.snapshot("fs-before") end

ForeverProbeSV_LateClobber = { fresh = true }  -- lint-allow: sv-file-scope-init - the W.30 clobber control; unconditional on purpose
ForeverProbeSV_LateOrInit = ForeverProbeSV_LateOrInit or { fresh = true }
ForeverProbeSV_LateCharClobber = { fresh = true }  -- lint-allow: sv-file-scope-init - per-character twin of the clobber control
ForeverProbeSV_LateCharOrInit = ForeverProbeSV_LateCharOrInit or { fresh = true }

if ns.snapshot then ns.snapshot("fs-after") end
