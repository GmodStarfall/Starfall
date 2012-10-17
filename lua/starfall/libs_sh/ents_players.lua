-------------------------------------------------------------------------------
-- Player functions.
-------------------------------------------------------------------------------

assert(SF.Entities)

SF.Players = {}
local player_methods, player_metamethods = SF.Typedef("Player", SF.Entities.Metatable)

SF.Players.Methods = player_methods
SF.Players.Metatable = player_metamethods

-- Overload entity wrap functions to handle players
local dsetmeta = debug.setmetatable
local old_ent_wrap = SF.Entities.Wrap
function SF.Entities.Wrap(obj)
	local w = old_ent_wrap(obj)
	if type(obj) == "Player" then
		dsetmeta(w, player_metamethods)
	end
	return w
end

local function isValid(entity)
	return SF.Entities.IsValid(entity) and entity:IsPlayer()
end

-- ------------------------- Entity Methods ------------------------- --

local ents_methods = SF.Entities.Methods
local ents_metatable = SF.Entities.Metatable

local wrap, unwrap = SF.Entities.Wrap, SF.Entities.Unwrap

function ents_methods:isPlayer( )
	SF.CheckType( self, ents_metatable )
	local ent = unwrap( self )
	if not SF.Entities.IsValid(ent) then return false, "invalid entity" end
	return ent:IsPlayer()
end

-- ---------------------------- Player methods ---------------------------------- --

function player_methods:alive( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end	
	return ent:Alive()
end

function player_methods:armor( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end	
	return ent:Armor()
end

function player_methods:crouching( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end	
	return ent:Crouching()
end

function player_methods:deaths( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end	
	return ent:Deaths()
end

function player_methods:flashlightIsOn( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end	
	return ent:FlashlightIsOn()
end

function player_methods:frags( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end	
	return ent:Frags()
end

function player_methods:aimVector( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end	
	return ent:GetAimVector()
end

function player_methods:fov()
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	return ent:GetFOV()
end

function player_methods:jumpPower( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end	
	return ent:GetJumpPower()
end

function player_methods:maxSpeed( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end	
	return ent:GetMaxSpeed()
end

function player_methods:name( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end	
	return ent:GetName()
end

function player_methods:runSpeed( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end	
	return ent:GetRunSpeed()
end

function player_methods:shootPos( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end	
	return ent:GetShootPos()
end

function player_methods:inVehicle( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end	
	return ent:InVehicle()
end

function player_methods:isAdmin( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end	
	return ent:IsAdmin( )
end

function player_methods:isBot( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end	
	return ent:IsBot( )
end

function player_methods:isConnected( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end	
	return ent:IsConnected( )
end

function player_methods:isSuperAdmin( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end	
	return ent:IsSuperAdmin( )
end

function player_methods:isUserGroup( group )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end	
	return ent:IsUserGroup( group )
end

function player_methods:isFrozen( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end	
	return ent:IsFrozen( )
end

function player_methods:name()
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end	
	return ent:Name()
end

function player_methods:nick()
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end	
	return ent:Nick()
end

function player_methods:ping()
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end	
	return ent:Ping()
end

function player_methods:steamID( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end	
	return ent:SteamID()
end

function player_methods:steamID64( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end	
	return ent:SteamID64( )
end

function player_methods:team( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end	
	return ent:Team()
end

function player_methods:teamName( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end	
	return team.GetName(ent:Team())
end

function player_methods:uniqueID( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end	
	return ent:UniqueID()
end

function player_methods:userID()
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end	
	return ent:UserID()
end

if CLIENT then
	function player_methods:getFriendStatus( )
		SF.CheckType( self, player_metamethods )
		local ent = unwrap( self )
		if not isValid(ent) then return false, "invalid entity" end		
		return ent:GetFriendStatus( )
	end
	
	function player_methods:isMuted( )
		SF.CheckType( self, player_metamethods )
		local ent = unwrap( self )
		if not isValid(ent) then return false, "invalid entity" end		
		return ent:IsMuted( )
	end
end

-- ---------------- Tools / Weapons functions  -------- --

function player_methods:weapon(weaponclassname)
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return nil, "invalid entity" end

	if weaponclassname then
		SF.CheckType(weaponclassname,"string")
		return wrap(ent:GetWeapon(weaponclassname))
	else
		return wrap(ent:GetActiveWeapon())
	end
end

function player_methods:ammoCount(ammo_type)
	SF.CheckType( self, player_metamethods )
	
	if type(ammo_type) == "number" then
		ammo_type = tostring(ammo_type)
	elseif not type(ammo_type) == "string" then
		SF.CheckType(ammo_type,"string or number") -- force error
	end
	
	local ent = unwrap( self )
	if not isValid(ent) then return nil, "invalid entity" end

	return ent:GetAmmoCount(ammo_type)
end

function player_methods:tool()
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return nil, "invalid entity" end

	local weapon = ent:GetActiveWeapon()
	if not weapon and weapon:IsValid() and weapon:IsWeapon() then return "" end
	if weapon:GetClass() ~= "gmod_tool" then return "" end

	return weapon.Mode
end

