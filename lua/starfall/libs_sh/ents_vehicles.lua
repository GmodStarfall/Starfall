-------------------------------------------------------------------------------
-- Vehicle functions
-------------------------------------------------------------------------------

assert(SF.Entities)

SF.Vehicles = {}
local vehicle_methods, vehicle_metamethods = SF.Typedef("Vehicle", SF.Entities.Metatable)

SF.Vehicles.Methods = vehicle_methods
SF.Vehicles.Metatable = vehicle_metamethods

-- Overload entity wrap functions to handle vehicles
local dsetmeta = debug.setmetatable
local old_ent_wrap = SF.Entities.Wrap
function SF.Entities.Wrap(obj)
	local w = old_ent_wrap(obj)
	if type(obj) == "Vehicle" then
		dsetmeta(w, vehicle_metamethods)
	end
	return w
end

-- ------------------------- Entity Methods ------------------------- --

local ents_methods = SF.Entities.Methods
local ents_metatable = SF.Entities.Metatable

local wrap, unwrap = SF.Entities.Wrap, SF.Entities.Unwrap

local isValid = SF.Entities.IsValid

--- Is the entity vehicle?
-- @return Returns true if entity is vehicle
function ents_methods:isVehicle()
	SF.CheckType(self,ents_metatable)

	local ent = unwrap(self)
	if not isValid(ent) then return false, "invalid entity" end

	return ent:IsVehicle()
end

-- ------------------------- Vehicle Methods ------------------------- --

--- Locks vehicle pod
-- @param lock Lock?
function vehicle_methods:lockPod(lock)
	SF.CheckType(self,vehicle_metamethods)
	SF.CheckType(lock,"boolean")

	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end

	if not ent:IsVehicle() then return false, "not a vehicle" end

	if not SF.Entities.GetOwner(ent) == SF.instance.player then return false, "access denied" end

	if lock then
		ent:Fire("Lock", "", 0)
	else
		ent:Fire("Unlock", "", 0)
	end
end

--- Kill vehicle driver
function vehicle_methods:killDriver()
	SF.CheckType(self,vehicle_metamethods)

	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end

	if not ent:IsVehicle() then return false, "not a vehicle" end

	if not SF.Entities.GetOwner(ent) == SF.instance.player then return false, "access denied" end

	local ply = ent:GetDriver()
	if ply and ply:IsValid() and ply:IsPlayer() then ply:Kill() end
end

--- Ejects driver from vehicle
function vehicle_methods:ejectDriver()
	SF.CheckType(self,vehicle_metamethods)

	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end

	if not ent:IsVehicle() then return false, "not a vehicle" end

	if not SF.Entities.GetOwner(ent) == SF.instance.player then return false, "access denied" end

	local ply = ent:GetDriver()
	if ply and ply:IsValid() and ply:IsPlayer() then ply:ExitVehicle() end
end

--- Get vehicle driver
-- @return Returns vehicle driver
function vehicle_methods:driver()
	SF.CheckType(self,vehicle_metamethods)

	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end

	if not ent:IsVehicle() then return nil, "not a vehicle" end

	local ply = ent:GetDriver()
	if ply and ply:IsValid() and ply:IsPlayer() then return nil, "invalid driver" end

	return wrap(ply)
end

--- Get vehicle passenger if available
-- @return Returns vehicle passenger
function vehicle_methods:passenger()
	SF.CheckType(self,vehicle_metamethods)

	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end

	if not ent:IsVehicle() then return nil, "not a vehicle" end

	local ply = ent:GetPassenger()
	if ply and ply:IsValid() and ply:IsPlayer() then return nil, "invalid passenger" end

	return wrap(ply)
end
