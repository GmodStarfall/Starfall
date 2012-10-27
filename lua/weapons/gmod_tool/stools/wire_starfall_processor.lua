TOOL.Category		= "Wire - Control"
TOOL.Name			= "Starfall - Processor"
TOOL.Command		= nil
TOOL.ConfigName		= ""
TOOL.Tab			= "Wire"

-- ------------------------------- Sending / Recieving ------------------------------- --
include("starfall/sflib.lua")

local MakeSF
local RequestSend

TOOL.ClientConVar[ "Model" ] = "models/jaanus/wiretool/wiretool_siren.mdl"
cleanup.Register( "starfall_processor" )

if SERVER then
	util.AddNetworkString( "starfall_processor_upload" )
	util.AddNetworkString( "starfall_processor_requpload" )

	net.Receive("starfall_processor_upload", function(len, ply)
		local ent = net.ReadEntity()
		if not ent or not ent:IsValid() then
			ErrorNoHalt("SF: Player "..ply:GetName().." tried to send code to a nonexistant entity.\n")
			return
		end
		
		if ent:GetClass() ~= "gmod_wire_starfall_processor" then
			ErrorNoHalt("SF: Player "..ply:GetName().." tried to send code to a non-starfall processor entity.\n")
			return
		end
		
		local mainfile = net.ReadString()
		local numfiles = net.ReadInt( 8 )

		local task = {
			mainfile = mainfile,
			files = {},
		}
		
		for i=1,numfiles do
			local filename = net.ReadString()
			local code = net.ReadString()
			task.files[filename] = code
		end
		
		ent:CodeSent(ply,task)
	end)
	
	RequestSend = function(ply, ent)
		net.Start("starfall_processor_requpload")
		net.WriteEntity(ent)
		net.Send(ply)
	end
	
	CreateConVar('sbox_maxstarfall_processor', 10, {FCVAR_REPLICATED,FCVAR_NOTIFY,FCVAR_ARCHIVE})
	
	function MakeSF( pl, Pos, Ang, model)
		if not pl:CheckLimit( "starfall_processor" ) then return false end

		local sf = ents.Create( "gmod_wire_starfall_processor" )
		if not IsValid(sf) then return false end

		sf:SetAngles( Ang )
		sf:SetPos( Pos )
		sf:SetModel( model )
		sf:Spawn()

		sf.owner = pl

		pl:AddCount( "starfall_processor", sf )

		return sf
	end
else
	language.Add( "tool.wire_starfall_processor.name", "Starfall - Processor (Wire)" )
    language.Add( "tool.wire_starfall_processor.desc", "Spawns a starfall processor" )
    language.Add( "tool.wire_starfall_processor.0", "Primary: Spawns a processor / uploads code, Secondary: Opens editor" )
	language.Add( "sboxlimit.wire_starfall_processor", "You've hit the Starfall processor limit!" )
	language.Add( "undone_Wire Starfall Processor", "Undone Starfall Processor" )
	
	net.Receive("starfall_processor_requpload", function(len, ply)
		if not SF.Editor.editor then return end
		
		local ent = net.ReadEntity()
		local code = SF.Editor.getCode()
		
		local ok, buildlist = SF.Editor.BuildIncludesTable()
		if ok then
			net.Start("starfall_processor_upload")
				net.WriteEntity(ent)
				net.WriteString(buildlist.mainfile)
				net.WriteInt(table.Count( buildlist.files ), 8)
				for name, file in pairs(buildlist.files) do
					net.WriteString(name)
					net.WriteString(file)
				end
				
			net.SendToServer()
		else
			WireLib.AddNotify("File not found: "..buildlist,NOTIFY_ERROR,7,NOTIFYSOUND_ERROR1)
		end
	end)
end

function TOOL:LeftClick( trace )
	if not trace.HitPos then return false end
	if trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end

	if trace.Entity:IsValid() and trace.Entity:GetClass() == "gmod_wire_starfall_processor" then
		RequestSend(self:GetOwner(),trace.Entity)
		return true
	end
	
	self:SetStage(0)

	local model = self:GetClientInfo( "Model" )
	local ply = self:GetOwner()
	if not self:GetSWEP():CheckLimit( "starfall_processor" ) then return false end

	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90

	local sf = MakeSF( ply, trace.HitPos, Ang, model)

	local min = sf:OBBMins()
	sf:SetPos( trace.HitPos - trace.HitNormal * min.z )

	local const = WireLib.Weld(sf, trace.Entity, trace.PhysicsBone, true)

	undo.Create("Wire Starfall Processor")
		undo.AddEntity( sf )
		undo.AddEntity( const )
		undo.SetPlayer( ply )
	undo.Finish()

	ply:AddCleanup( "starfall_processor", sf )
	
	RequestSend(ply,sf)

	return true
end

function TOOL:RightClick( trace )
	if SERVER then self:GetOwner():SendLua("SF.Editor.open()") end
	return false
end

function TOOL:Reload(trace)
	return false
end

function TOOL:DrawHUD()
end

function TOOL:Think()
end

if CLIENT then
	local lastclick = CurTime()
	
	local function GotoDocs(button)
		gui.OpenURL("http://colonelthirtytwo.net/sfdoc/")
	end
	
	local function FileBrowserOnFileClick(self)
		SF.Editor.init()
		if dir == self.File.FileDir and CurTime() - lastclick < 1 then
			SF.Editor.editor:Open(dir)
		else
			dir = self.File.FileDir
			SF.Editor.editor:LoadFile(dir)
		end
		lastclick = CurTime()
	end
	
	function TOOL.BuildCPanel(panel)
		panel:AddControl("Header", { Text = "#Tool_wire_starfall_processor_name", Description = "#Tool_wire_starfall_processor_desc" })
		
		local modelPanel = WireDermaExts.ModelSelect(panel, "wire_starfall_processor_Model", list.Get("Wire_gate_Models"), 2)
		panel:AddControl("Label", {Text = ""})
		
		local docbutton = vgui.Create("DButton" , panel)
		panel:AddPanel(docbutton)
		docbutton:SetText("Starfall Documentation")
		docbutton.DoClick = GotoDocs
		
		local filebrowser = vgui.Create("wire_expression2_browser")
		panel:AddPanel(filebrowser)
		filebrowser:Setup("Starfall")
		filebrowser:SetSize(235,400)
		filebrowser.OnFileClick = FileBrowserOnFileClick
		
		local openeditor = vgui.Create("DButton", panel)
		panel:AddPanel(openeditor)
		openeditor:SetText("Open Editor")
		openeditor.DoClick = SF.Editor.open
	end
end
