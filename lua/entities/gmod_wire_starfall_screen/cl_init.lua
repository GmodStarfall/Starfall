include('shared.lua')

ENT.RenderGroup = RENDERGROUP_OPAQUE

include("starfall2/SFLib.lua")
include("libtransfer/libtransfer.lua")


local context = SF.CreateContext(nil, nil, nil, nil, SF.Libraries.CreateLocalTbl{"screen"})
datastream.Hook("sf_screen_download",function(handler, id, encoded, decoded)
	for i=1,#decoded do
		data = decoded[i]
		local ent = data.ent
		if not ent or ent:GetClass() ~= "gmod_wire_starfall_screen" then
			ErrorNoHalt("SF Screen data sent to wrong entity: "..tostring(ent))
			return
		end
		
		ent:CodeSent(data.files, data.main, data.owner)
	end
end)

usermessage.Hook("starfall_shared_screen_input", function( data )
	local screen = Entity( data:ReadShort() )
	screen:InputChange( data )
end)

function ENT:InputChange( data )
	local sourceent = Entity( data:ReadShort() )
	local inputname = data:ReadString()
	local value
	
	
	local inval = self.Inputs[inputname]
	
	if inval.Type == "NORMAL" then
		value = data:ReadFloat()
	elseif inval.Type == "ENTITY" then
		value = data:ReadShort()
	elseif inval.Type == "STRING" then
		value = data:ReadString()
	elseif inval.Type == "ANGLE" then
		value = Angle( data:ReadFloat(), data:ReadFloat(), data:ReadFloat() )
	elseif inval.Type == "VECTOR" then
		value = Vector( data:ReadFloat(), data:ReadFloat(),  data:ReadFloat() )
	end
	
	inval.Src = sourceent
	inval.Value = value
	self:RunScriptHook( "input", inputname, value )
end

function ENT:Initialize()
	self.gpu = GPULib.WireGPU(self)
	self.Inputs = { }
end

function ENT:Think()
	if self.instance and not self.instance.error then
		self.instance:resetOps()
	end
end

function ENT:OnRemove()
	self.gpu:Finalize()
	if self.instance then
		self.instance:deinitialize()
	end
end

function ENT:Error(msg)
	ErrorNoHalt("Screen of ".. (self.owner and self.owner:Nick() or "<unknown>") .." errored: "..msg.."\n")
	WireLib.AddNotify(self.owner, msg, NOTIFY_ERROR, 7, NOTIFYSOUND_ERROR1)
	if self.instance then
		self.instance:deinitialize()
		self.instance = nil
	end
	self:SetOverlayText("Starfall Screen\nInactive (Error)")
end

function ENT:CodeSent(files, main, owner)
	self.owner = owner
	local ok, instance = SF.Compiler.Compile(files,context,main,owner,{ent=self,screen={}})
	if not ok then self:Error(instance) return end
	
	self.instance = instance
	instance.data.entity = self
	local ok, msg = instance:initialize()
	if not ok then self:Error(msg) end
	
	function self.renderfunc()
		self.instance.data.screen.isRendering = true
		self:RunScriptHook("render")
		if self.instance then self.instance.data.screen.isRendering = nil end
	end
end

function ENT:RunScriptHook(hook, ...)
	if self.instance and not self.instance.error and self.instance.hooks[hook:lower()] then
		local ok, rt = self.instance:runScriptHook(hook, ...)
		if not ok then self:Error(rt)
		else return rt end
	end
end

function ENT:Draw()
	self:DrawModel()
	Wire_Render(self)
	if self.instance and not self.instance.error and self.instance.hooks["render"] then
		--render.Clear( 0, 0, 0, 255 )
		self.gpu:RenderToGPU(self.renderfunc)
	end
	self.gpu:Render()
end
