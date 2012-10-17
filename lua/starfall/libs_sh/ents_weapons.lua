-------------------------------------------------------------------------------
-- Weapon functions.
-------------------------------------------------------------------------------

assert(SF.Entities)

SF.Weapons = {}
local weapon_methods, weapon_metamethods = SF.Typedef("Weapon", SF.Entities.Metatable)

SF.Weapons.Methods = weapon_methods
SF.Weapons.Metatable = weapon_metamethods

-- Overload entity wrap functions to handle NPC
local dsetmeta = debug.setmetatable
local old_ent_wrap = SF.Entities.Wrap
function SF.Entities.Wrap(obj)
	local w = old_ent_wrap(obj)
	if type(obj) == "Weapon" then
		dsetmeta(w, weapon_metamethods)
	end
	return w
end

local function isValid(entity)
	return SF.Entities.IsValid(entity) and entity:IsWeapon()
end

-- ------------------------- Entity Methods ------------------------- --

local ents_methods = SF.Entities.Methods
local ents_metatable = SF.Entities.Metatable

local wrap, unwrap = SF.Entities.Wrap, SF.Entities.Unwrap

function ents_methods:isWeapon()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not SF.Entities.IsValid(ent) then return nil, "invalid entity" end
	return ent:IsWeapon()
end

-- ------------------------- Weapon Methods ------------------------- --

--- Primary ammo type
-- @return Returns the type of ammo that the weapon's primary fire takes.
function weapon_methods:primaryAmmoType()
	SF.CheckType(self,weapon_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:GetPrimaryAmmoType()
end

--- Secondary ammo type
-- @return Returns the type of ammo that the weapon's secondary fire takes.
function weapon_methods:secondaryAmmoType()
	SF.CheckType(self,weapon_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:GetSecondaryAmmoType()
end

--- Get primary clip
-- @return Returns the number of bullets in the primary fire's clip. Returns -1 if the weapon doesn't have a primary fire, or if it doesn't take ammo.
function nweapon_methods:clip1()
	SF.CheckType(self,weapon_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:Clip1()
end

--- Get secondary clip
-- @return Returns the number of bullets in the secondary fire's clip. Returns -1 if the weapon doesn't have a secondary fire, or if it doesn't take ammo.
function weapon_methods:clip2()
	SF.CheckType(self,weapon_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:Clip2()
end
