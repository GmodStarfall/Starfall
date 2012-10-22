------ NPC server functions ----

assert(SF.NPC)

local function isValid(entity)
	return (SF.Entities.IsValid(entity) and entity:IsNPC())
end

local npc_methods = SF.NPC.Methods 
local npc_metamethods = SF.NPC.Metatable

function npc_methods:npcGoWalk(pos)
	SF.CheckType( self, npc_metamethods )
	SF.CheckType( pos, "Vector" )
	local ent = SF.Entities.Unwrap( self )
	if not isValid(ent) then return nil, "invalid npc entity" end
	if not SF.Entities.GetOwner(ent) == SF.instance.player then return false, "access denied" end

	ent:SetLastPosition( pos )
	ent:SetSchedule( SCHED_FORCED_GO )
end

function npc_methods:npcGoRun(pos)
	SF.CheckType( self, npc_metamethods )
	SF.CheckType( pos, "Vector" )
	local ent = SF.Entities.Unwrap( self )
	if not isValid(ent) then return nil, "invalid npc entity" end
	if not SF.Entities.GetOwner(ent) == SF.instance.player then return false, "access denied" end

	ent:SetLastPosition( pos )
	ent:SetSchedule( SCHED_FORCED_GO_RUN )
end

function npc_methods:npcAttack()
	SF.CheckType( self, npc_metamethods )
	local ent = SF.Entities.Unwrap( self )
	if not isValid(ent) then return nil, "invalid npc entity" end
	if not SF.Entities.GetOwner(ent) == SF.instance.player then return false, "access denied" end
	ent:SetSchedule( SCHED_MELEE_ATTACK1 )
end

function npc_methods:npcShoot()
	SF.CheckType( self, npc_metamethods )
	local ent = SF.Entities.Unwrap( self )
	if not isValid(ent) then return nil, "invalid npc entity" end
	if not SF.Entities.GetOwner(ent) == SF.instance.player then return false, "access denied" end
	if !ent:HasCondition( COND_NO_WEAPON ) then return, "no weapon" end
	ent:SetSchedule( SCHED_RANGE_ATTACK1 )
end

function npc_methods:npcFace(pos)
	SF.CheckType( self, npc_metamethods )
	SF.CheckType(pos,"Vector")
	local ent = SF.Entities.Unwrap( self )
	if not isValid(ent) then return nil, "invalid npc entity" end
	if not SF.Entities.GetOwner(ent) == SF.instance.player then return false, "access denied" end
	local Vec = pos - ent:GetPos()
	local ang = Vec:Angle()
	ent:SetAngles( Angle(0,ang.y,0) )
end

function npc_methods:npcGiveWeapon(weaponName)
	SF.CheckType( self, npc_metamethods )

	if not weaponName then weaponName = "smg1" end

	SF.CheckType(weaponName,"string")

	local ent = SF.Entities.Unwrap( self )
	if not isValid(ent) then return nil, "invalid npc entity" end
	if not SF.Entities.GetOwner(ent) == SF.instance.player then return false, "access denied" end

	local weapon = ent:GetActiveWeapon()
	if weapon and weapon:IsValid() then
		if weapon:GetClass() == "weapon_"..weaponName then return end
		weapon:Remove()
	end

	ent:Give( "ai_weapon_"..weaponName )
end

function npc_methods:npcStop()
	SF.CheckType( self, npc_metamethods )
	local ent = SF.Entities.Unwrap( self )
	if not isValid(ent) then return nil, "invalid npc entity" end
	if not SF.Entities.GetOwner(ent) == SF.instance.player then return false, "access denied" end
	ent:SetSchedule( SCHED_NONE )
end

function npc_methods:npcGetTarget()
	SF.CheckType( self, npc_metamethods )
	local ent = SF.Entities.Unwrap( self )
	if not isValid(ent) then return nil, "invalid npc entity" end
	if not SF.Entities.GetOwner(ent) == SF.instance.player then return false, "access denied" end
	return SF.Entities.Wrap(ent:GetEnemy())
end

function npc_methods:npcSetTarget(target)
	SF.CheckType( self, npc_metamethods )
	local ent = SF.Entities.Unwrap( self )
	if not isValid(ent) then return nil, "invalid npc entity" end
	if not SF.Entities.GetOwner(ent) == SF.instance.player then return false, "access denied" end

	target = SF.Entities.Unwrap(ent)
	if target and target:IsValid() and (target:IsNPC() or target:IsPlayer()) then
		ent:SetEnemy(target)
	end

	if not ent:GetEnemy() == target then return false end

	return true
end
