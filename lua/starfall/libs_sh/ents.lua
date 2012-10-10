-------------------------------------------------------------------------------
-- Shared entity library functions
-------------------------------------------------------------------------------

SF.Entities = {}

local ents_methods, ents_metamethods = SF.Typedef("Entity")
local wrap, unwrap = SF.CreateWrapper(ents_metamethods,true,true)

SF.Players = {}

local player_methods, player_metamethods = SF.Typedef("Player")
local pl_wrap, pl_unwrap = SF.CreateWrapper(player_metamethods,true,true)
--- Entities Library
-- @shared
local ents_lib, _ = SF.Libraries.Register("ents")

-- This is slightly more efficient
function ValidEntity(ent)
	return ent and ent:IsValid()
end

-- ------------------------- Internal functions ------------------------- --

SF.Entities.Wrap = wrap
SF.Entities.Unwrap = unwrap
SF.Entities.Methods = ents_methods
SF.Entities.Metatable = ents_metamethods
SF.Entities.Library = ents_lib

SF.Players.Wrap = wrap
SF.Players.Unwrap = unwrap
SF.Players.Methods = player_methods
SF.Players.Metatable = player_metamethods

-- ------------------------- Player API functions ------------------------- --

local old_wrap = wrap
local old_unwrap = unwrap

local function ent_wrap( ent )
	if type( ent ) == "Player" then
		return pl_wrap( ent )
	else
		return old_wrap( ent )
	end
end

local function ent_unwrap( ent )
	if debug.getmetatable( ent ) == player_metamethods then
		return pl_unwrap( ent )
	else
		return old_unwrap( ent )
	end
end

wrap = ent_wrap
unwrap = ent_unwrap
SF.Entities.Wrap = wrap
SF.Entities.Unwrap = unwrap


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
		return wrap(ent)
	else return nil end
end

--- Returns whoever created the script
function ents_lib.owner()
	return wrap(SF.instance.player)
end

--- Same as ents_lib.owner() on the server. On the client, returns the local player
-- @name ents_lib.player
-- @class function
-- @return Either the owner (server) or the local player (client)
if SERVER then
	ents_lib.player = ents_lib.owner
else
	function ents_lib.player()
		return wrap(LocalPlayer())
	end
end

--[[
--- Returns whoever created the script
function ents_lib.owner()
	return wrap(SF.instance.player)
end

--- Same as ents_lib.owner() on the server.
function ents_lib.player()
	return wrap(SF.instance.player)
end
]]
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
-- @return The position vector of the outer bounding box center
function ents_methods:obbCenter()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:LocalToWorld(ent:OBBCenter())
end

--- Returns the world position of the entity's mass center
-- @shared
-- @return The position vector of the mass center
function ents_methods:massCenter()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:LocalToWorld(ent:GetMassCenter())
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

--- Returns the principle moments of inertia of the entity
-- @shared
-- @return The principle moments of inertia as a vector
function ents_methods:inertia()
	SF.CheckType(self,ents_metamethods)
	
	local ent = unwrap(self)
	local phys = getPhysObject(ent)
	if not phys then return false, "entity has no physics object or is not valid" end
	
	return phys:GetInertia()
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

--- Returns the angular velocity of the entity
-- @shared
-- @return The angular velocity vector
function ents_methods:angVelVector()
	SF.CheckType(self,ents_metamethods)
	local phys = getPhysObject(unwrap(self)) 	
	if not phys then return false, "entity has no physics object or is not valid" end	
	return phys:GetAngleVelocity()
end

--- Converts a vector in entity local space to world space
-- @shared
-- @param data Local space vector
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

--- Converts a vector in world space to entity local space
-- @shared
-- @param data Local space vector
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

--- Gets the model of an entity
-- @shared
function ents_methods:model()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:GetModel()
end

--- Gets the entitiy's eye angles
-- @shared
function ents_methods:eyeAngles()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:EyeAngles()
end

--- Gets the entity's eye position
-- @shared
function ents_methods:eyePos()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:EyePos()
end

--- Gets the entity's parent
-- @shared
-- @return The parent entity
function ents_methods:parent()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:GetParent()
end

-- ------------------------- Player Methods ------------------------- --

player_methods.__index = SF.Entities.Methods

function player_methods:alive( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	
	return ent:Alive()
end

function player_methods:armor( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	
	return ent:Armor()
end

function player_methods:crouching( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	
	return ent:Crouching()
end

function player_methods:deaths( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	
	return ent:Deaths()
end

function player_methods:flashlightIsOn( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	
	return ent:FlashlightIsOn()
end

function player_methods:frags( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	
	return ent:Frags()
end

function player_methods:getActiveWeapon( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	
	return ent:GetActiveWeapon():ClassName()
end

function player_methods:getAimVector( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	
	return ent:GetAimVector()
end

function player_methods:getFOV()
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	
	return ent:GetFOV()
end

function player_methods:getJumpPower( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	
	return ent:GetJumpPower()
end

function player_methods:getMaxSpeed( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	
	return ent:GetMaxSpeed()
end

function player_methods:getName( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	
	return ent:GetName()
end

function player_methods:getRunSpeed( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	
	return ent:GetRunSpeed()
end

function player_methods:getShootPos( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	
	return ent:GetShootPos()
end

function player_methods:inVehicle( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	
	return ent:InVehicle()
end

function player_methods:isAdmin( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	
	return ent:IsAdmin( )
end

function player_methods:isBot( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	
	return ent:IsBot( )
end

function player_methods:isConnected( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	
	return ent:IsConnected( )
end

function player_methods:isFrozen( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	
	return ent:IsFrozen( )
end

function player_methods:isNPC( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	
	return ent:IsNPC( )
end

function player_methods:isPlayer( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	
	return ent:IsPlayer()
end

function player_methods:isSuperAdmin( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	
	return ent:IsSuperAdmin( )
end

function player_methods:isUserGroup( group )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	
	return ent:IsUserGroup( group )
end

function player_methods:name()
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	
	return ent:Name()
end

function player_methods:nick()
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	
	return ent:Nick()
end

function player_methods:ping()
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	
	return ent:Ping()
end

function player_methods:steamID( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	
	return ent:SteamID( )
end

function player_methods:steamID64( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	
	return ent:SteamID64( )
end

function player_methods:team( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	
	return ent:Team()
end

function player_methods:getTeamName( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	
	return team.GetName( ent:Team( ) )
end

function player_methods:uniqueID( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	
	return ent:UniqueID() 
end

function player_methods:userID()
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	
	return ent:UserID() 
end

-- ------------------------- Client Methods ------------------------- --

if CLIENT then
	function player_methods:getFriendStatus( )
		SF.CheckType( self, player_metamethods )
		local ent = unwrap( self )
		
		return ent:GetFriendStatus( )
	end
	
	function player_methods:isMuted( )
		SF.CheckType( self, player_metamethods )
		local ent = unwrap( self )
		
		return ent:IsMuted( )
	end
	
end
