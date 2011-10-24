
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

include("starfall2/SFLib.lua")
include("libtransfer/libtransfer.lua")

local context = SF.CreateContext()
local screens = {}

hook.Add("PlayerInitialSpawn","sf_screen_download",function(ply)
	local tbl = {}
	for _,s in pairs(screens) do
		tbl[#tbl+1] = {
			ent = s,
			owner = s.owner,
			files = s.task.files,
			main = s.task.mainfile,
		}
	end
	if #tbl > 0 then
		datastream.StreamToClients(ply,"sf_screen_download",tbl)
	end
end)

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	self.Inputs = WireLib.CreateInputs(self, {})
	self.Outputs = WireLib.CreateOutputs(self, {})
	
	local r,g,b,a = self:GetColor()
end

function ENT:OnRestore()
end

function ENT:Compile(codetbl, mainfile)
	local ok, instance = SF.Compiler.Compile(codetbl,context,mainfile,self.owner)
	if not ok then self:Error(instance) return end
	self.instance = instance
	instance.data.entity = self
	
	local ok, msg = instance:initialize()
	if not ok then
		self:Error(msg)
		return
	end
	self:SetOverlayText("Starfall Processor\nActive")
end

function ENT:Error(msg, override)
	ErrorNoHalt("Screen of "..self.owner:Nick().." errored: "..msg.."\n")
	WireLib.ClientError(msg, self.owner)
	if self.instance then
		self.instance:deinitialize()
		self.instance = nil
	end
	self:SetOverlayText("Starfall Processor\nInactive (Error)")
end

function ENT:CodeSent(ply, task)
	if ply ~= self.owner then return end
	self.task = task
	datastream.StreamToClients(player.GetHumans(), "sf_screen_download",
		{{
			ent = self,
			owner = ply,
			files = task.files,
			main = task.mainfile,
		}})
	screens[self] = self
	
	local ppdata = {}
	
	SF.Preprocessor.ParseDirectives(task.mainfile, task.files[task.mainfile], {}, ppdata)
	
	if ppdata.sharedscreen then self:Compile(task.files, task.mainfile) end
end

function ENT:Think()
	self.BaseClass.Think(self)
	self:NextThink(CurTime())
	
	if self.instance and not self.instance.error then
		self.instance:resetOps()
		self:RunScriptHook("think")
	end
	
	return true
end

function ENT:OnRemove()
	if not self.instance then return end
	screens[self] = nil
	self.instance:deinitialize()
	self.instance = nil
end

function ENT:TriggerInput(key, value)
	if self.instance and not self.instance.error then
		self.instance:runScriptHook("input",key,value)
	end
	if self.instance.ppdata.sharedscreen then
		umsg.Start("starfall_shared_screen_input");
			umsg.Short( self:EntIndex() )
			umsg.String( key )
			if type( value ) == "number" then
				umsg.Float( value )
			elseif type( value ) == "string" then
				umsg.String( value )
			elseif type( value ) == "table" then
				local list = { }
				if value.x then
					list[1] = value.x
					list[2] = value.y
					list[3] = value.z
				elseif value.pitch then
					list[1] = value.pitch
					list[2] = value.yaw
					list[3] = value.roll
				end
				
				umsg.Float( list[1] )
				umsg.Float( list[2] )
				umsg.Float( list[3] )
			end
		umsg.End();
	end
end

function ENT:ReadCell(address)
	return tonumber(self:RunScriptHook("readcell",address)) or 0
end

function ENT:WriteCell(address, data)
	self:RunScriptHook("writecell",address,data)
end

function ENT:RunScriptHook(hook, ...)
	if self.instance and not self.instance.error and self.instance.hooks[hook:lower()] then
		local ok, rt = self.instance:runScriptHook(hook, ...)
		if not ok then self:Error(rt)
		else return rt end
	end
end

function ENT:ApplyDupeInfo(ply, ent, info, GetEntByID, GetConstByID)
	self.BaseClass.ApplyDupeInfo(self, ply, ent, info, GetEntByID, GetConstByID)
end
