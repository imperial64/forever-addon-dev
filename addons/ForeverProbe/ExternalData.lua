-- ExternalData.lua
--
-- The inbound half of the external data channel.
--
-- This file is meant to be OVERWRITTEN by a process outside the game. The client
-- has no io, no os and no sockets, so the only way to hand an addon data from
-- outside is to write a .lua file that the .toc already lists and let the client
-- execute it as addon code at load. The addon exposes a receiver function, the
-- generated file calls it, and the addon reads the result back out of memory.
-- It works because the file is code being run, not data being read, which is the
-- only door the sandbox leaves open. It is the standard way an addon gets
-- out-of-game data in: config injection, price tables, any import that does not
-- originate inside the client.
--
-- Cost of the channel: it is read once, at load. New data needs a /reload.
--
-- Write it with:  scripts\write-external-data.ps1 -Message "hello from outside"
-- Then in game:   /reload  and  /fprobe external
--
-- The shipped contents below are the "nothing has written to this yet" marker, so
-- an untouched install is distinguishable from a successful external write.

local _, ns = ...
if not ns or not ns.LoadExternalData then return end

ns.LoadExternalData("default", "unmodified")
