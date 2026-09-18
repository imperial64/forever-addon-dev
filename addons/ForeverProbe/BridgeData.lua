-- BridgeData.lua
--
-- The inbound half of the Claude Code bridge, and the probe for section 9 item 6
-- of research/auction-addon-architecture.md.
--
-- This file is meant to be OVERWRITTEN by a process outside the game. The client
-- has no io, no os and no sockets, so the only way to hand an addon data from
-- outside is to write a .lua file that the .toc already lists and let the client
-- execute it as addon code at load. TradeSkillMaster_AppHelper ships an empty
-- AppData.lua for exactly this reason and its desktop app rewrites it with a list
-- of TSM.LoadData(...) calls; this is the same mechanism with our own receiver.
--
-- Cost of the channel: it is read once, at load. New data needs a /reload.
--
-- Write it with:  scripts\write-bridge-data.ps1 -Message "hello from Claude Code"
-- Then in game:   /reload  and  /fprobe bridge
--
-- The shipped contents below are the "nothing has written to this yet" marker, so
-- an untouched install is distinguishable from a successful external write.

local _, ns = ...
if not ns or not ns.LoadBridgeData then return end

ns.LoadBridgeData("default", "unmodified")
