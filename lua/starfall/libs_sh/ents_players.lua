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

function ents_methods:isPlayer()
	SF.CheckType( self, ents_metatable )
	local ent = unwrap( self )
	if not SF.Entities.IsValid(ent) then return false, "invalid entity" end
	return ent:IsPlayer()
end

-- ---------------------------- Player methods ---------------------------------- --

function player_methods:isAlive( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end
	return ent:Alive()
end

function player_methods:armor( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:Armor()
end

function player_methods:isCrouching( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end
	return ent:Crouching()
end

function player_methods:deaths( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:Deaths()
end

function player_methods:isFlashlightOn( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end
	return ent:FlashlightIsOn()
end

function player_methods:frags( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:Frags()
end

function player_methods:fov()
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	return ent:GetFOV()
end

function player_methods:jumpPower( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:GetJumpPower()
end

function player_methods:maxSpeed( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:GetMaxSpeed()
end

function player_methods:runSpeed( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:GetRunSpeed()
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

function player_methods:inNoclip()
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end	
	return ent:GetMoveType() ~= MOVETYPE_NOCLIP
end

function player_methods:timeConnected()
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return nil, "invalid entity" end
	then return ent:TimeConnected()
end

function player_methods:name()
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:Name()
end

function player_methods:nick()
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:Nick()
end

function player_methods:ping()
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:Ping()
end

function player_methods:steamID( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:SteamID()
end

function player_methods:steamID64( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:SteamID64( )
end

function player_methods:team( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:Team()
end

function player_methods:uniqueID( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:UniqueID()
end

function player_methods:userID()
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:UserID()
end

if CLIENT then
	function player_methods:getFriendStatus( )
		SF.CheckType( self, player_metamethods )
		local ent = unwrap( self )
		if not isValid(ent) then return nil, "invalid entity" end
		return ent:GetFriendStatus( )
	end
	
	function player_methods:isMuted( )
		SF.CheckType( self, player_metamethods )
		local ent = unwrap( self )
		if not isValid(ent) then return false, "invalid entity" end
		return ent:IsMuted( )
	end
end

function player_methods:eye()
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:GetAimVector()
end

function player_methods:eyeAngles()
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:EyeAngles()
end

--- Equivalent to rangerOffset(16384, <this>:shootPos(), <this>:eye()), but faster (causing less lag)
function player_methods:eyeTrace()
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return nil, "invalid entity" end
	local ret = ent:GetEyeTraceNoCursor()
	ret.RealStartPos = ent:GetShootPos()
	if ret.Entity then ret.Entity = wrap(ret.Entity) end -- wrap the entity
	return ret
end

function player_methods:shootPos( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:GetShootPos()
end

function player_methods:aimVector( )
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:GetAimVector()
end

function player_methods:aimEntity()
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return nil, "invalid entity" end

	local hit = this:GetEyeTraceNoCursor().Entity
	if not SF.Entities.IsValid(hit) then return nil end
	return wrap(hit)
end

function player_methods:aimPos()
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:GetEyeTraceNoCursor().HitPos
end

function player_methods:aimNormal()
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:GetEyeTraceNoCursor().HitNormal
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

-- ---------------- Key functions  ----------------------- --

function player_methods:keyAttack1()
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end
	return ent:KeyDown(IN_ATTACK)
end

function player_methods:keyAttack2()
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end
	return ent:KeyDown(IN_ATTACK2)
end

function player_methods:keyUse()
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end
	return ent:KeyDown(IN_USE)
end

function player_methods:keyCancel()
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end
	return ent:KeyDown(IN_CANCEL)
end

function player_methods:keyReload()
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end
	return ent:KeyDown(IN_RELOAD)
end

function player_methods:keyZoom()
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end
	return ent:KeyDown(IN_ZOOM)
end

function player_methods:keyJump()
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end
	return ent:KeyDown(IN_JUMP)
end

function player_methods:keyDuck()
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end
	return ent:KeyDown(IN_DUCK)
end

function player_methods:keyMoveForward()
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end
	return ent:KeyDown(IN_FORWARD)
end

function player_methods:keyMoveBack()
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end
	return ent:KeyDown(IN_BACK)
end

function player_methods:keyMoveLeft()
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end
	return ent:KeyDown(IN_MOVELEFT)
end

function player_methods:keyMoveRight()
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end
	return ent:KeyDown(IN_MOVERIGHT)
end

function player_methods:keyTurnLeft()
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end
	return ent:KeyDown(IN_LEFT)
end

function player_methods:keyTurnRight()
	SF.CheckType( self, player_metamethods )
	local ent = unwrap( self )
	if not isValid(ent) then return false, "invalid entity" end
	return ent:KeyDown(IN_RIGHT)
end