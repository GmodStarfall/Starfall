--- Shared stuff between client-side entities library and
-- server-side entities library

SF.Entities = {}

local ents_methods, ents_metamethods = SF.Typedef("Entity")
local wrap, unwrap = SF.CreateWrapper(ents_metamethods,true,true)
--- Entities Library
-- @shared
local ents_lib, _ = SF.Libraries.Register("ents")

-- ------------------------- Internal functions ------------------------- --

SF.Entities.Wrap = wrap
SF.Entities.Unwrap = unwrap
SF.Entities.Methods = ents_methods
SF.Entities.Metatable = ents_metamethods
SF.Entities.Library = ents_lib

--- Returns true if valid and is not the world, false if not
-- @param entity Entity to check
function SF.Entities.IsValid(entity)
	return entity and entity:IsValid() and not entity:IsWorld()
--	if entity == nil then return false end
--	if not entity:IsValid() then return false end
--	if entity:IsWorld() then return false end
--	return true
end
local isValid = SF.Entities.IsValid

--- Gets the physics object of the entity
-- @return The physobj, or nil if the entity isn't valid or isn't vphysics
function SF.Entities.GetPhysObject(ent)
	return (isValid(ent) and ent:GetMoveType() == MOVETYPE_VPHYSICS and ent:GetPhysicsObject()) or nil
--	if not ents.IsValid(entity) then return nil end
--	if entity:GetMoveType() ~= MOVETYPE_VPHYSICS then return nil end
--	return entity:GetPhysicsObject()
end
local getPhysObject = SF.Entities.GetPhysObject

-- ------------------------- Library functions ------------------------- --

--- Returns the entity representing a processor that this script is running on.
-- May be nil
function ents_lib.self()
	local ent = SF.instance.data.entity
	return ent and wrap(ent)
end

--- Returns whoever created the script
function ents_lib.owner()
	return wrap(SF.instance.player)
end

-- ------------------------- Methods ------------------------- --

--- To string
-- @shared
function ents_metamethods:__tostring()
	local ent = unwrap(self)
	return ent and tostring(ent) or "(null entity)"
end

--- Checks if an entity is valid.
-- @shared
-- @return True if valid, false if not
function ents_methods:isValid()
	SF.CheckType(self,ents_metamethods)
	return isValid(unwrap(self))
end

--- Returns the EntIndex of the entity
-- @shared
-- @return The numerical index of the entity
function ents_methods:index()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:EntIndex()
end

--- Returns the class of the entity
-- @shared
-- @return The string class name
function ents_methods:class()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:GetClass()
end

--- Returns the position of the entity
-- @shared
-- @return The position vector
function ents_methods:pos()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:GetPos()
end

--- Returns the angle of the entity
-- @shared
-- @return The angle
function ents_methods:ang()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:GetAngles()
end

--- Returns the mass of the entity
-- @shared
-- @return The numerical mass
function ents_methods:mass()
	SF.CheckType(self,ents_metamethods)
	
	local ent = unwrap(self)
	local phys = getPhysObject(ent)
	if not phys then return false, "entity has no physics object or is not valid" end
	
	return phys:GetMass()
end

--- Returns the velocity of the entity
-- @shared
-- @return The velocity vector
function ents_methods:vel()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:GetVelocity()
end

--- Converts a vector in entity local space to world space
-- @shared
-- @param data Local space vector
function ents_methods:toWorld(data)
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	
	return ent:LocalToWorld(data)
end

--- Converts an angle in entity local space to world space
-- @shared
-- @param data Local space angle
function ents_methods:toWorldAngles(data)
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	
	return ent:LocalToWorldAngles(data)
end

--- Converts a vector in entity local space to world space
-- @shared
-- @param data Local space vector
function ents_methods:toLocal(data)
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	
	return ent:WorldToLocal(data)
end

--- Converts an angle in entity local space to world space
-- @shared
-- @param data Local space angle
function ents_methods:toLocalAngles(data)
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	
	return ent:WorldToLocalAngles(data)
end
