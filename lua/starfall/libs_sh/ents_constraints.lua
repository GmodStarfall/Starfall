-------------------------------------------------------------------------------
-- Shared constrains functions
-------------------------------------------------------------------------------

assert(SF.Entities)

SF.Constraints = {}

--- Constrains functions. Allows some basic constrains information and manipulation.
--- <br> Permissions: Manipulate Constraints - allows constraint manipulation
-- @shared
local constraints_library, _ = SF.Libraries.Register("ents_constraints")

SF.Constraints.Library = constraints_library

local ents_methods = SF.Entities.Methods
local ents_metatable = SF.Entities.Metatable

local wrap, unwrap = SF.Entities.Wrap, SF.Entities.Unwrap

local isValid = SF.Entities.IsValid

-- ---------------------Helper functions --------------------- --

-- caps("heLlO") == "Hello"
local function caps(text)
	local capstext = text:sub(1,1):upper() .. text:sub(2):lower()
	if capstext == "Nocollide" then return "NoCollide" end
	if capstext == "Advballsocket" then return "AdvBallsocket" end
	return capstext
end

-- Returns con.Ent1 or con.Ent2, whichever is not equivalent to ent. Optionally subscripts con with num beforehand.
local function ent1or2(ent,con,num)
	if not con then return nil end
	if num then
		con = con[num]
		if not con then return nil end
	end
	if con.Ent1==ent then return con.Ent2 end
	return con.Ent1
end

-- ------------------------- Methods ------------------------- --

--- Is the entity constrained to something?
-- @shared
-- @return Returns true if entity is constrained
function ents_methods:isConstrained()
	SF.CheckType(self,ents_metatable)

	local ent = unwrap(self)
	if not isValid(ent) then return false, "invalid entity" end

	if not constraint.HasConstraints(ent) then return false end

	return true
end

--- Get number of directly constrained entities
-- @shared
-- @param constraintType Optional: One of constraint types ( AdvBallsocket, Axis, Ballsocket, Elastic, Hydraulic, Keepupright, Motor, Muscle, NoCollide, Pulley, Rope, Slider, Weld, Winch )
-- @return Returns number of directly constrained entities constrained by specified constraint type
function ents_methods:hasConstraints(constraintType)
	SF.CheckType(self,ents_metatable)
	
	local ent = unwrap(self)
	if not isValid(ent) then return 0, "invalid entity" end

	if not constraintType then
		return #constraint.GetTable(ent)
	end
	
	SF.CheckType(constraintType,"string")

	local constype = caps(constraintType)
	local ConTable = constraint.GetTable(ent)
	local count = 0
	for k, con in ipairs(ConTable) do
		if con.Type == constype then
			count = count + 1
		end
	end

	return count
end

--- Get all entities constrained to this entity
-- @shared
-- @return Returns array containing all entities directly or indirectly constrained to entity
function ents_methods:getConstraints()
	SF.CheckType(self,ents_metatable)

	local ent = unwrap(self)
	if not isValid(ent) then return {}, "invalid entity" end

	if not constraint.HasConstraints(ent) then return {} end

	local keytable = constraint.GetAllConstrainedEntities(ent)
	local array = {}
	local count = 0
	for _,child in pairs(keytable) do
		if isValid(child) and child ~= ent then
			table.insert(array, wrap(child))
		end
	end
	return array
end

--- Get the welded entity
-- @shared
-- @param index Optional: The nth index
-- @return Returns the nth entity this entity was welded to
function ents_methods:isWeldedTo(index)
	SF.CheckType(self,ents_metatable)

	if index then
		SF.CheckType(index,"number")
	end

	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end

	if not constraint.HasConstraints(ent) then return nil, "entity is not constrained" end

	local w_ent = nil
	if index then
		w_ent = ent1or2(ent, constraint.FindConstraint(ent, "Weld"), math.floor(index))
	else
		w_ent = ent1or2(ent, constraint.FindConstraint(ent, "Weld"))
	end

	if not isValid(w_ent) then return nil, "no welded entity found" end

	return wrap(w_ent)
end

--- Gets the constrained entity
-- @shared
-- @param index Optional: The nth index
-- @param constraintType Optional: One of constraint types ( AdvBallsocket, Axis, Ballsocket, Elastic, Hydraulic, Keepupright, Motor, Muscle, NoCollide, Pulley, Rope, Slider, Weld, Winch )
-- @return Returns the nth entity this entity is constrained to
function ents_methods:isConstrainedTo(index, constraintType)
	SF.CheckType(self,ents_metatable)

	if index then
		SF.CheckType(index,"number")
	end

	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end

	if not constraint.HasConstraints(ent) then return nil, "entity is not constrained" end

	local w_ent = nil
	if constraintType then
		SF.CheckType(constraintType,"string")
		
		if index then
			w_ent = ent1or2(ent, constraint.FindConstraints(ent, caps(constraintType)), math.floor(index))
		else
			w_ent = ent1or2(ent, constraint.FindConstraints(ent, caps(constraintType)))
		end
	else
		local index = index or 1
		w_ent =  ent1or2(ent, constraint.GetTable(ent), math.floor(index))
	end

	if not isValid(w_ent) then return nil, "no constrained entity found" end

	return wrap(w_ent)
end

--- Is the entity parented to something?
-- @shared
-- @return Return true if entity is parented
function ents_methods:isParented()
	SF.CheckType(self,ents_metatable)

	local ent = unwrap(self)
	if not isValid(ent) then return false, "invalid entity" end
	local parent = ent:GetParent()

	if not isValid(parent) then return false end

	return true
end

--- Gets the entity's parent
-- @shared
-- @return The parent entity or nil
function ents_methods:parent()
	SF.CheckType(self,ents_metatable)

	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	local parent = ent:GetParent()
	
	if not isValid(parent) then return nil, "not parented" end

	return wrap(parent)
end
