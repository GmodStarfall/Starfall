-------------------------------------------------------------------------------
-- Server constrains functions
-------------------------------------------------------------------------------

assert(SF.Entities)
assert(SF.Constraints)

local constraints_Library = SF.Constraints.Library

local ents_methods = SF.Entities.Methods
local ents_metatable = SF.Entities.Metatable

local isValid = SF.Entities.IsValid
local canModify = SF.Entities.CanModify

local wrap, unwrap = SF.Entities.Wrap, SF.Entities.Unwrap

--- Permission
SF.Permissions:registerPermission({
	name = "Manipulate Constraints",
	desc = "Allow basic constraints manipulation",
	level = 1,
	value = true,
})

-- ---------------------Helper functions --------------------- --

-- caps("heLlO") == "Hello"
local function caps(text)
	local capstext = text:sub(1,1):upper() .. text:sub(2):lower()
	if capstext == "Nocollide" then return "NoCollide" end
	if capstext == "Advballsocket" then return "AdvBallsocket" end
	return capstext
end

-- ------------------------- Methods ------------------------- --

--- Welds the entity to another entity
-- @param target The target entity we should weld to
-- @param force The amount of force appliable before the weld breaks - Optional
-- @param nocollide Should the entities nocollide? - Optional
-- @param deleteonbreak Delete the entity if target entity is removed? - Optional
-- @param bone1 Optional entity bone nuber
-- @param bone2 Optional target bone number
-- @return Returns true if welding succeeded
function ents_methods:weldTo(target, force, nocollide, deleteonbreak, bone1, bone2)
	SF.CheckType(self,ents_metatable)
	SF.CheckType(target,ents_metatable)

	force = force or 0
	SF.CheckType(force, "number")
	force = math.abs(force)

	nocollide = nocollide or false
	SF.CheckType(nocollide, "boolean")

	deleteonbreak = deleteonbreak or false
	SF.CheckType(deleteonbreak, "boolean")
	
	if bone1 then
		SF.CheckType(bone1, "number")
	else
		bone1 = 0
	end

	if bone2 then
		SF.CheckType(bone2, "number")
	else
		bone2 = 0
	end

	-- check if player is allowed to manipulate constrains
	if not SF.instance.permissions:checkPermission("Manipulate Constraints") then return false, "contraints manipulation not allowed" end

	-- check self
	local ent = unwrap(self)
	if not isValid(ent) then return false, "entity not valid" end
	if ent:IsPlayer() then return false, "cannot weld player" end
	if not canModify(SF.instance.player, ent) or SF.instance.permissions:checkPermission("Modify All Entities") then return false, "access denied" end
	
	-- check target
	local weld_to = unwrap(target)
	if not isValid(weld_to) then return false, "target entity not valid" end
	if ent == weld_to then return false, "cannot weld to self" end
	if weld_to:IsPlayer() then return false, "cannot weld to players" end
	if not canModify(SF.instance.player, weld_to) or SF.instance.permissions:checkPermission("Modify All Entities") then return false, "target access denied" end

	if not util.IsValidPhysicsObject(ent, bone1) and constraint.CanConstrain(ent, bone1) then return false, "cannot weld entity" end
	if not util.IsValidPhysicsObject(weld_to, bone2) and constraint.CanConstrain(weld_to, bone2) then return false, "cannot weld to target" end

	local weld = constraint.Weld(ent, weld_to, bone1, bone2, force, nocollide, deleteonbreak)

	if not weld and weld:IsValid() then return false, "welding failed" end

	return true
end

--- NoCollides the entity with another entity
-- @param target The target entity we should nocollide with
-- @param bone1 Optional entity bone number
-- @param bone2 Optional target bone number
-- @return Returns true if nocolliding succeeded
function ents_methods:noCollideWith(target, bone1, bone2)
	SF.CheckType(self,ents_metatable)
	SF.CheckType(target,ents_metatable)

	if bone1 then
		SF.CheckType(bone1, "number")
	else
		bone1 = 0
	end

	if bone2 then
		SF.CheckType(bone2, "number")
	else
		bone2 = 0
	end

	-- check if player is allowed to manipulate constrains
	if not SF.instance.permissions:checkPermission("Manipulate Constraints") then return false, "contraints manipulation not allowed" end

	-- check self
	local ent = unwrap(self)
	if not isValid(ent) then return false, "entity not valid" end
	if ent:IsPlayer() then return false, "cannot nocollide player" end
	if not canModify(SF.instance.player, ent) or SF.instance.permissions:checkPermission("Modify All Entities") then return false, "access denied" end
	
	-- check target
	local nocollide_with = unwrap(target)
	if not isValid(nocollide_with) then return false, "target entity not valid" end
	if ent == nocollide_with then return false, "cannot nocollide with self" end
	if nocollide_with:IsPlayer() then return false, "cannot nocollide with player" end
	if not canModify(SF.instance.player, nocollide_with) or SF.instance.permissions:checkPermission("Modify All Entities") then return false, "target access denied" end

	if not util.IsValidPhysicsObject(ent, bone1) and constraint.CanConstrain(ent, bone1) then return false, "cannot nocollide entity" end
	if not util.IsValidPhysicsObject(nocollide_with, bone2) and constraint.CanConstrain(nocollide_with, bone2) then return false, "cannot nocollide with target" end

	local nocollide = constraint.NoCollide(ent, nocollide_with, bone1, bone2)

	if not nocollide and nocollide:IsValid() then return false, "nocolliding failed" end

	return true
end

--- Removes constraints of defined type from entity
-- @param constraintType One of constraint types - ( AdvBallsocket, Axis, Ballsocket, Elastic, Hydraulic, Keepupright, Motor, Muscle, NoCollide, Pulley, Rope, Slider, Weld, Winch )
-- @return Returns true on succeed
function ents_methods:removeConstraints(constraintType)
	SF.CheckType(self,ents_metatable)
	SF.CheckType(constraintType,"string")

	-- check if player is allowed to manipulate constrains
	if not SF.instance.permissions:checkPermission("Manipulate Constraints") then return false, "contraints manipulation not allowed" end

	-- check self
	local ent = unwrap(self)
	if not isValid(ent) then return false, "entity not valid" end
	if ent:IsPlayer() then return false, "cannot use on player" end
	if not canModify(SF.instance.player, ent) or SF.instance.permissions:checkPermission("Modify All Entities") then return false, "access denied" end
	
	local bool = constraint.RemoveConstraints(ent, caps(constraintType))
	if not bool then return false, "constraint removal failed" end

	return true
end

--- Removes all constraints from entity
-- @return Returns true on succeed
function ents_methods:removeAllConstraints()
	SF.CheckType(self,ents_metatable)

	-- check if player is allowed to manipulate constrains
	if not SF.instance.permissions:checkPermission("Manipulate Constraints") then return false, "contraints manipulation not allowed" end

	-- check self
	local ent = unwrap(self)
	if not isValid(ent) then return false, "entity not valid" end
	if ent:IsPlayer() then return false, "cannot use on player" end
	if not canModify(SF.instance.player, ent) or SF.instance.permissions:checkPermission("Modify All Entities") then return false, "access denied" end

	constraint.RemoveAll(ent)
	
	if constraint.HasConstraints(ent) then return false, "constraint removal failed" end

	return true
end

--- Sets the entity's parent
-- @param parent The entity we should parent to or nil to deparent
-- @return Returns true if parenting succeeded
function ents_methods:setParent(parent)
	SF.CheckType(self,ents_metatable)

	-- check if player is allowed to manipulate constrains
	if not SF.instance.permissions:checkPermission("Manipulate Constraints") then return false, "contraints manipulation not allowed" end

	local child = unwrap(self)
	if not isValid(child) then return false, "entity not valid" end
	if child:IsPlayer() then return false, "cannot parent player" end
	if not canModify(SF.instance.player, child) or SF.instance.permissions:checkPermission("Modify All Entities") then return false, "access denied" end

	if parent then
		SF.CheckType(parent,ents_metatable)

		local parent = unwrap(parent)
		if not isValid(parent) then return false, "parent entity not valid" end

		-- do not parent to self
		if child == parent then return false, "cannot parent to self" end
		
		-- do not parent to players
		if parent:IsPlayer() then return false, "cannot parent to players" end

		-- can we modify parent?
		if not canModify(SF.instance.player, parent) or SF.instance.permissions:checkPermission("Modify All Entities") then return false, "parent access denied" end

		-- Prevent cyclic parenting ( = crashes )
		local checkparent = parent
		while IsValid(checkparent:GetParent()) do
			checkparent = checkparent:GetParent()
			if checkparent == child then return false, "cyclic parenting detected" end
		end

		child:SetParent(parent)
		
		checkparent = child:GetParent()
		if not checkparent and checkparent:IsValid() and checkparent == parent then return false, "parenting failed" end
	else
		child:SetParent(nil)
		
		local checkparent = child:GetParent()
		if checkparent and checkparent:IsValid() then return false, "deparenting failed" end
	end

	return true
end
