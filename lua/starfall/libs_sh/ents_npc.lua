-------------------------------------------------------------------------------
-- NPC functions.
-------------------------------------------------------------------------------

assert(SF.Entities)

SF.NPC = {}
local npc_methods, npc_metamethods = SF.Typedef("NPC", SF.Entities.Metatable)

SF.NPC.Methods = player_methods
SF.NPC.Metatable = player_metamethods

-- Overload entity wrap functions to handle NPC
local dsetmeta = debug.setmetatable
local old_ent_wrap = SF.Entities.Wrap
function SF.Entities.Wrap(obj)
	local w = old_ent_wrap(obj)
	if type(obj) == "NPC" then
		dsetmeta(w, npc_metamethods)
	end
	return w
end

local function isValid(entity)
	return SF.Entities.IsValid(entity) and entity:IsNPC()
end

-- ------------------------- Entity Methods ------------------------- --

local ents_methods = SF.Entities.Methods
local ents_metatable = SF.Entities.Metatable

local wrap, unwrap = SF.Entities.Wrap, SF.Entities.Unwrap

function ents_methods:isNPC( )
	SF.CheckType( self, ents_metatable )
	local ent = SF.Entities.Unwrap( self )
	if not SF.Entities.IsValid(ent) then return false, "invalid entity" end
	return ent:IsNPC( )
end

-- ------------------------- NPC Methods ------------------------- --