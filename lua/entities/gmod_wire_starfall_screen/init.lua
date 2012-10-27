
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

util.AddNetworkString( "sf_screen_download" )

include("starfall/SFLib.lua")
assert(SF, "Starfall didn't load correctly!")

local context = SF.CreateContext()
local screens = {}

hook.Add("PlayerInitialSpawn","sf_screen_download",function(ply)
	local tbl = {}
	for _,s in pairs(screens) do
		tbl[#tbl+1] = {
			ent = s,
			owner = s.owner,
			files = s.task.files or {},
			main = s.task.mainfile or "",
		}
	end
	if #tbl > 0 then
		net.Start( "sf_screen_download" )
			net.WriteTable( tbl )
		net.Send( ply )
	end
end)

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType( 3 )
	
	self.Inputs = WireLib.CreateInputs(self, {})
	self.Outputs = WireLib.CreateOutputs(self, {})
	
	local r,g,b,a = self:GetColor()
end

function ENT:OnRestore()
end

function ENT:UpdateName(state)
	if state ~= "" then state = "\n"..state end
	
	if self.instance and self.instance.ppdata.scriptnames and self.instance.mainfile and self.instance.ppdata.scriptnames[self.instance.mainfile] then
		self:SetOverlayText("Starfall Processor\n"..tostring(self.instance.ppdata.scriptnames[self.instance.mainfile])..state)
	else
		self:SetOverlayText("Starfall Processor"..state)
	end
end

function ENT:Compile(codetbl, mainfile)
	if self.instance then self.instance:deinitialize() end
	
	local ok, instance = SF.Compiler.Compile(codetbl,context,mainfile,self.owner)
	if not ok then self:Error(instance) return end
	self.instance = instance
	instance.data.entity = self
	
	local ok, msg = instance:initialize()
	if not ok then
		self:Error(msg)
		return
	end
	
	self:UpdateName("")
	local a = self:GetColor().a
	self:SetColor( Color( 255, 255, 255, a ) )
end

function ENT:Error(msg, override)
	ErrorNoHalt("Processor of "..self.owner:Nick().." errored: "..msg.."\n")
	WireLib.ClientError(msg, self.owner)
	
	if self.instance then
		self.instance:deinitialize()
		self.instance = nil
	end
	
	self:UpdateName("Inactive (Error)")
	local a = self:GetColor().a
	self:SetColor( Color( 255, 0, 0, a ) )
end

function ENT:CodeSent(ply, task)
	if ply ~= self.owner then return end
	self.task = task
	net.Start( "sf_screen_download" )
		net.WriteTable( {{
			ent = self,
			owner = ply,
			files = task.files,
			main = task.mainfile,
		}} )
	net.Broadcast()
	screens[self] = self

	local ppdata = {}
	
	SF.Preprocessor.ParseDirectives(task.mainfile, task.files[task.mainfile], {}, ppdata)
	
	if ppdata.sharedscreen then 
		self:Compile(task.files, task.mainfile)
		self.sharedscreen = true
	end
end

function ENT:Think()
	self.BaseClass.Think(self)
	self:NextThink(CurTime())
	
	if self.instance and not self.instance.error then
		self.instance:resetOps()
		self:runScriptHook("think")
	end
	
	return true
end

-- Sends a umsg to all clients about the use.
function ENT:Use( activator )
	if activator:IsPlayer() then
		umsg.Start( "starfall_screen_used" )
			umsg.Short( self:EntIndex() )
			umsg.Short( activator:EntIndex() )
		umsg.End( )
	end
	if self.sharedscreen then
		self:runScriptHook( "starfall_used", SF.Entities.Wrap( activator ) )
	end
end

function ENT:OnRemove()
	if not self.instance then return end
	screens[self] = nil
	self.instance:deinitialize()
	self.instance = nil
end

function ENT:TriggerInput(key, value)
	self:runScriptHook("input",key,value)
end

function ENT:BuildDupeInfo()
	local info = self.BaseClass.BuildDupeInfo(self) or {}
	info.starfall = SF.SerializeCode(self.task.files, self.task.mainfile)
	return info
end

function ENT:ApplyDupeInfo(ply, ent, info, GetEntByID)
	self.BaseClass.ApplyDupeInfo(self, ply, ent, info, GetEntByID)
	self.owner = ply
	local code, main = SF.DeserializeCode(info.starfall)
	local task = {files = code, mainfile = main}
	self:CodeSent(ply, task)
end
