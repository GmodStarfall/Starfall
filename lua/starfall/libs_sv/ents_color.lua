-------------------------------------------------------------------------------
-- Server color functions
-------------------------------------------------------------------------------

assert(SF.Entities)

local ents_methods = SF.Entities.Methods
local ents_metatable = SF.Entities.Metatable

local isValid = SF.Entities.IsValid
local canModify = SF.Entities.CanModify

local wrap, unwrap = SF.Entities.Wrap, SF.Entities.Unwrap

local clamp = math.Clamp

local function fixColor(r,g,b,a)
	return Color(clamp(tonumber(r) or 0,0,255),
		clamp(tonumber(g) or 0,0,255),
		clamp(tonumber(b) or 0,0,255),
		clamp(tonumber(a) or 255,0,255))
end

local function compareColor(c1,c2)
	if not c1.r == c2.r then return false end
	if not c1.g == c2.g then return false end
	if not c1.b == c2.b then return false end
	if not c1.a == c2.a then return false end
	return true
end

-- ------------------------- Methods ------------------------- --

--- Sets the entity color
-- @param r Red
-- @param g Green
-- @param b Blue
-- @param a Optional Alpha
-- @return Returns true if sucessfull
function ents_methods:setColor(r,g,b,a)
	SF.CheckType(self,ents_metatable)

	local ent = unwrap(self)
	if not isValid(ent) then return false, "invalid entity" end
	if not canModify(SF.instance.player, ent) or SF.instance.permissions:checkPermission("Modify All Entities") then return false, "access denied" end

	local old_color = ent:GetColor()
	local old_rmode = ent:GetRenderMode()

	SF.CheckType(r, "number")
	SF.CheckType(g, "number")
	SF.CheckType(b, "number")
	if a then 
		SF.CheckType(a, "number")
		if ent:IsPlayer() and old_color.a then
			a = old_color.a
		end
	else
		a = old_color.a or 0
	end

	local new_color = fixColor(r, g, b, a)

	ent:SetRenderMode(new_color.a == 255 and RENDERMODE_NORMAL or RENDERMODE_TRANSALPHA)
	ent:SetColor(new_color)

	if not compareColor(ent:GetColor(), new_color) then
		ent:SetRenderMode(old_rmode)
		return false, "setting color failed"
	end

	return true
end

--- Sets the entity alpha
-- @param a Alpha
-- @return Returns true if sucessfull
function ents_methods:setAlpha(a)
	SF.CheckType(self,ents_metatable)
	SF.CheckType(a, "number")

	local ent = unwrap(self)
	if not isValid(ent) then return false, "invalid entity" end
	if not canModify(SF.instance.player, ent) or SF.instance.permissions:checkPermission("Modify All Entities") then return false, "access denied" end

	if ent:IsPlayer() then return false, "cannot set alpha to player" end

	local old_color = ent:GetColor()
	local old_rmode = ent:GetRenderMode()
	local new_color = Color(old_color.r,old_color.g,old_color.b,clamp(a, 0, 255))

	ent:SetRenderMode(new_color.a == 255 and RENDERMODE_NORMAL or RENDERMODE_TRANSALPHA)
	ent:SetColor(new_color)

	if not ent:GetColor().a == new_color.a then 
		ent:SetRenderMode(old_rmode)
		return false, "setting alpha failed"
	end

	return true
end
