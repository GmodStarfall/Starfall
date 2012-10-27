AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()
	self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NOCLIP) -- TODO: custom movetype hook?
	self:DrawShadow( false )
end

function ENT:SetScale(scale)
	umsg.Start("starfall_hologram_scale")
		umsg.Short(self.Entity:EntIndex())
		umsg.Float(scale.x)
		umsg.Float(scale.y)
		umsg.Float(scale.z)
	umsg.End()
end

function ENT:UpdateClip(index, enabled, origin, normal, islocal)
	umsg.Start("starfall_hologram_clip")
		umsg.Short(self.Entity:EntIndex())
		umsg.Short(index)
		umsg.Bool(enabled)
		umsg.Vector(origin)
		umsg.Vector(normal)
		umsg.Bool(islocal)
	umsg.End()
end
