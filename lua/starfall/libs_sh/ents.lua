-------------------------------------------------------------------------------
-- Shared entity library functions
-------------------------------------------------------------------------------

SF.Entities = {}

local ents_methods, ents_metamethods = SF.Typedef("Entity")
local wrap, unwrap = SF.CreateWrapper(ents_metamethods,true,true)

--- Entities Library
-- @shared
local ents_lib, _ = SF.Libraries.Register("ents")

-- This is slightly more efficient
function IsValid(ent)
	return ent and ent:IsValid()
end

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
end
local isValid = SF.Entities.IsValid

--- Gets the physics object of the entity
-- @return The physobj, or nil if the entity isn't valid or isn't vphysics
function SF.Entities.GetPhysObject(ent)
	return (isValid(ent) and ent:GetMoveType() == MOVETYPE_VPHYSICS and ent:GetPhysicsObject()) or nil
end
local getPhysObject = SF.Entities.GetPhysObject

-- ------------------------- Library functions ------------------------- --

--- Returns the entity representing a processor that this script is running on.
-- May be nil
function ents_lib.self()
	local ent = SF.instance.data.entity
	if ent then 
		return SF.Entities.Wrap(ent)
	else return nil end
end

--- Returns whoever created the script
function ents_lib.owner()
	return SF.Entities.Wrap(SF.instance.player)
end

--- Same as ents_lib.owner() on the server. On the client, returns the local player
-- @name ents_lib.player
-- @class function
-- @return Either the owner (server) or the local player (client)
if SERVER then
	ents_lib.player = ents_lib.owner
else
	function ents_lib.player()
		return SF.Entities.Wrap(LocalPlayer())
	end
end

-- ------------------------- Methods ------------------------- --

--- To string
-- @shared
function ents_metamethods:__tostring()
	local ent = unwrap(self)
	if not ent then return "(null entity)"
	else return tostring(ent) end
end

--- Checks if an entity is valid.
-- @shared
-- @return True if valid, false if not
function ents_methods:isValid()
	SF.CheckType(self,ents_metamethods)
	return isValid(unwrap(self))
end

--- Checks if the entity is world
-- @shared
-- @return True if world, false if not
function ents_methods:isWorld()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	return (ent and ent:IsValid() and ent:IsWorld())
end

--- Is some player holding the entity?
-- @shared
-- @return Return true if some player is holding this entity
function ents_methods:isPlayerHolding()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:IsPlayerHolding()
end

--- Is the entity on fire?
-- @shared
-- @return Return true if this entity is on fire
function ents_methods:isOnFire()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:IsOnFire()
end

--- Is the entity on ground?
-- @shared
-- @return Return true if this entity is on ground
function ents_methods:isOnGround()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:IsOnGround()
end

--- Is the entity under water?
-- @shared
-- @return Return true if this entity is under water
function ents_methods:isUnderWater()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return (ent:WaterLevel() > 0)
end

--- Is the entity frozen?
-- @shared
-- @return Returns true if entity is frozen
function ents_methods:isFrozen()
	SF.CheckType( self, player_metamethods )
	local phys = getPhysObject(unwrap(self))
	if not phys then return false, "entity has no physics object or is not valid" end
	return phys:IsMoveable()
end

-- ---------------- Basic info methods  -------- --

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

--- Gets the model of an entity
-- @shared
-- @return The entity model name
function ents_methods:model()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:GetModel()
end

--- Gets the entity health
-- @shared
-- @return The entity health
function ents_methods:health()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:Health()
end

-- ---------------- Positional methods  -------- --

--- Returns the position of the entity
-- @shared
-- @return The position vector
function ents_methods:pos()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:GetPos()
end

--- Returns the forward direction of the entity
-- @shared
-- @return Returns the forward vector of the entity, as a normalized direction vector
function ents_methods:forward()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:GetForward()
end

--- Returns the rightward direction of the entity
-- @shared
-- @return Returns the rightward vector of the entity, as a normalized direction vector
function ents_methods:right()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:GetRight()
end

--- Returns the upward direction of the entity
-- @shared
-- @return Returns the upward vector of the entity, as a normalized direction vector
function ents_methods:up()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:GetUp()
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

--- Returns the angle of the entity
-- @shared
-- @return The angle
function ents_methods:ang()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:GetAngles()
end

--- Returns the angular velocity of the entity
-- @shared
-- @return The angular velocity angle
function ents_methods:angVel()
	SF.CheckType(self,ents_metamethods)
	local phys = getPhysObject(unwrap(self))
	if not phys then return false, "entity has no physics object or is not valid" end
	local vel = phys:GetAngleVelocity()
	return Angle(vel.y, vel.z, vel.x)
end

--- Returns the angular velocity of the entity as vector
-- @shared
-- @return The angular velocity vector
function ents_methods:angVelVector()
	SF.CheckType(self,ents_metamethods)
	local phys = getPhysObject(unwrap(self))
	if not phys then return false, "entity has no physics object or is not valid" end
	return phys:GetAngleVelocity()
end

-- Returns the mins and maxs of the entity's bounding box
-- @shared
-- @return The mins and maxs of the entity's bounding box
function ents_methods:obb()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:OBBMins(),ent:OBBMaxs()
end

--- Returns the x, y, z size of the entity's outer bounding box (local to the entity)
-- @shared
-- @return The outer bounding box size
function ents_methods:obbSize()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:OBBMaxs() - ent:OBBMins()
end

--- Returns the world position of the entity's outer bounding box
-- @shared
-- @param loc - If true then return as local position
-- @return The position vector of the outer bounding box center
function ents_methods:obbCenter(loc)
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	if loc then return ent:OBBCenter() end
	return ent:LocalToWorld(ent:OBBCenter())
end

--- Returns the radius of the entity's bounding box
-- @shared
-- @return The radius number
function ents_methods:radius()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:BoundingRadius()
end

-- Returns the mins and max of the physics object
-- @shared
-- @return The mins and max of the physics object
function ents_methods:aabb()
	SF.CheckType(self,ents_metamethods)
	local phys = getPhysObject(unwrap(self)) 	
	if not phys then return false, "entity has no physics object or is not valid" end
	return phys:GetAABB()
end

-- Returns the x, y, z size of the physics object
-- @shared
-- @return The the x, y, z size of the physics object
function ents_methods:aabbSize()
	SF.CheckType(self,ents_metamethods)
	local phys = getPhysObject(unwrap(self))
	if not phys then return false, "entity has no physics object or is not valid" end
	local min,max = phys:GetAABB()
	return max - min
end

--- Returns the world position of the entity's mass center
-- @shared
-- @param loc - If true then return as local position
-- @return The position vector of the mass center
function ents_methods:massCenter(loc)
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	if loc then return ent:GetMassCenter() end
	return ent:LocalToWorld(ent:GetMassCenter())
end

--- Returns the mass of the entity
-- @shared
-- @return The numerical mass
function ents_methods:mass()
	SF.CheckType(self,ents_metamethods)
	local phys = getPhysObject(unwrap(self))
	if not phys then return false, "entity has no physics object or is not valid" end
	return phys:GetMass()
end

--- Gets the volume of the entity
-- @shared
-- @return Returns the volume of the entity
function ents_methods:volume()
	SF.CheckType(self,ents_metamethods)
	local phys = getPhysObject(unwrap(self))
	if not phys then return false, "entity has no physics object or is not valid" end
	return phys:GetVolume()
end

--- Returns the principle moments of inertia of the entity
-- @shared
-- @return The principle moments of inertia as a vector
function ents_methods:inertia()
	SF.CheckType(self,ents_metamethods)
	local phys = getPhysObject(unwrap(self))
	if not phys then return false, "entity has no physics object or is not valid" end
	return phys:GetInertia()
end

--- Converts a vector/angle in entity local space to world space
-- @shared
-- @param data Local space vector
-- @return Returns the transformed vector/angle
function ents_methods:toWorld(data)
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	
	if type(data) == "Vector" then
		return ent:LocalToWorld(data)
	elseif type(data) == "Angle" then
		return ent:LocalToWorldAngles(data)
	else
		SF.CheckType(data, "angle or vector") -- force error
	end
end

--- Converts a vector/angle in world space to entity local space
-- @shared
-- @param data Local space vector
-- @return Returns the transformed vector/angle
function ents_methods:toLocal(data)
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	
	if type(data) == "Vector" then
		return ent:WorldToLocal(data)
	elseif type(data) == "Angle" then
		return ent:WorldToLocalAngles(data)
	else
		SF.CheckType(data, "angle or vector") -- force error
	end
end

--- Transforms an axis local to entity to a global axis
-- @shared
-- @param localAxis Local space vector
-- @return Returns the transformed vector
function ents_methods:toWorldAxis(localAxis)
	SF.CheckType(self,ents_metamethods)
	SF.CheckType(localAxis,"Vector")
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end

	return ent:LocalToWorld(localAxis)-ent:GetPos()
end

--- Transforms a world axis to an axis local to entity
-- @shared
-- @param worldAxis Local space vector
-- @return Returns the transformed vector
function ents_methods:toWorldAxis(worldAxis)
	SF.CheckType(self,ents_metamethods)
	SF.CheckType(worldAxis,"Vector")
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end

	return ent:WorldToLocal(worldAxis)+ent:GetPos()
end

--- Performs a Ray OBBox intersection with the entity
-- @param point The position vector
-- @return Returns the closest point on the edge of the entity's bounding box to the given vector
function ents_methods:nearestPoint(point)
	SF.CheckType(self,ents_metamethods)
	SF.CheckType(point,"Vector")
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:NearestPoint(point)
end

--- Gets the entity's eye angles
-- @shared
-- @return Returns the direction a player/npc/ragdoll is looking as a world-oriented angle
function ents_methods:eyeAngles()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:EyeAngles()
end

--- Gets the entity's eye position
-- @shared
-- @return Returns the position of an Player/NPC's view, or two vectors for ragdolls (one for each eye)
function ents_methods:eyePos()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:EyePos()
end

-- ---------------- Look methods  -------- --

--- Get material of entity
-- @shared
-- @return Returns material name
function ents_methods:material()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:GetMaterial() or ""
end

--- Get current skin of entity
-- @shared
-- @return Returns skin number
function ents_methods:skin()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:GetSkin() or 0
end

--- Get number of skins of entity
-- @shared
-- @return Returns number of skins
function ents_methods:skinCount()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:SkinCount() or 0
end

-- ---------------- Attachments methods  -------- --

--- Get attachment position
-- @shared
-- @param attachment Attachment ID or name
-- @return Position of attachment
function ents_methods:attachmentPos(attachment)
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	if type(attachment) == "string" then
		attachment = ent:LookupAttachment(attachment)
	elseif not type(attachment) == "number" then
		SF.CheckType(attachment,"string or number") -- force error
	end
	local attach = ent:GetAttachment(attachment)
	return attach.Pos
end

--- Get attachment angle
-- @shared
-- @param attachment Attachment ID or name
-- @return Angle of attachment
function ents_methods:attachmentAng(attachment)
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	if type(attachment) == "string" then
		attachment = ent:LookupAttachment(attachment)
	elseif not type(attachment) == "number" then
		SF.CheckType(attachment,"string or number") -- force error
	end
	local attach = ent:GetAttachment(attachment)
	return attach.Ang
end
