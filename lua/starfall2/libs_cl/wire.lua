
local wire_library = {}
--- Wire library. Handles wire inputs/outputs, wirelinks, etc.
SF.Libraries.Register("wire",wire_library)

SF.Wire = {}
SF.Wire.Library = wire_library


-- ------------------------- Internal Library ------------------------- --

local function identity(data) return data end
local inputConverters =
{
	NORMAL = identity,
	STRING = identity,
	VECTOR = identity,
	ANGLE = identity,
	WIRELINK = function(wl) return wlwrap(wl) end,
}

local WireLib = {}
WireLib.DT = {
	NORMAL = {
		Zero = 0
	},	-- Numbers
	VECTOR = {
		Zero = Vector(0, 0, 0)
	},
	ANGLE = {
		Zero = Angle(0, 0, 0)
	},
	ENTITY = {
		Zero = NULL
	},
	STRING = {
		Zero = ""
	},
}

-- Allow to specify the description and type, like "Name (Description) [TYPE]"
local function ParsePortName(namedesctype, fbtype, fbdesc)
	local namedesc, tp = namedesctype:match("^(.+) %[(.+)%]$")
	if not namedesc then
		namedesc = namedesctype
		tp = fbtype
	end
	
	local name, desc = namedesc:match("^(.+) %((.*)%)$")
	if not name then
		name = namedesc
		desc = fbdesc
	end
	return name, desc, tp
end

function WireLib.AdjustSpecialInputs(ent, names, types, descs)
	types = types or {}
	descs = descs or {}
	local ent_ports = ent.Inputs
	for n,v in ipairs(names) do
		local name, desc, tp = ParsePortName(v, types[n] or "NORMAL", descs and descs[n])
		
		if (ent_ports[name]) then
			if tp ~= ent_ports[name].Type then
				timer.Simple(0, Wire_Link_Clear, ent, name)
				ent_ports[name].Value = WireLib.DT[tp].Zero
				ent_ports[name].Type = tp
			end
			ent_ports[name].Keep = true
			ent_ports[name].Num = n
			ent_ports[name].Desc = descs[n]
		else
			local port = {
				Entity = ent,
				Name = name,
				Desc = desc,
				Type = tp,
				Value = WireLib.DT[ tp ].Zero,
				Material = "tripmine_laser",
				Color = Color(255, 255, 255, 255),
				Width = 1,
				Keep = true,
				Num = n,
			}
			--[[
			local idx = 1
			while (Inputs[idx]) do
				idx = idx+1
			end
			port.Idx = idx
			]]--
			
			ent_ports[name] = port
			--Inputs[idx] = port
		end
	end
	
	return ent_ports
end

--- Adds an input type
-- @param name Input type name. Case insensitive.
-- @param converter The function used to convert the wire data to SF data (eg, wrapping)
function SF.Wire.AddInputType(name, converter)
	inputConverters[name:upper()] = converter
end

--- Adds an output type
-- @param name Output type name. Case insensitive.
-- @param deconverter The function used to check for the appropriate type and convert the SF data to wire data (eg, unwrapping)
function SF.Wire.AddOutputType(name, deconverter)
	outputConverters[name:upper()] = deconverter
end

-- ------------------------- Basic Wire Functions ------------------------- --

--- Creates/Modifies wire inputs. All wire ports must begin with an uppercase
-- letter and contain only alphabetical characters.
-- @param names An array of input names. May be modified by the function.
-- @param types An array of input types. May be modified by the function.
function wire_library.createInputs(names, types)
	SF.CheckType(names,"table")
	SF.CheckType(types,"table")
	local ent = SF.instance.data.entity
	if not ent then error("No entity to create inputs on",2) end
	
	if #names ~= #types then error("Table lengths not equal",2) end
	for i=1,#names do
		local newname = names[i]
		local newtype = types[i]
		if type(newname) ~= "string" then error("Non-string input name: "..newname,2) end
		if type(newtype) ~= "string" then error("Non-string input type: "..newtype,2) end
		newtype = newtype:upper()
		if not newname:match("^[A-Z][a-zA-Z]*$") then error("Invalid input name: "..newname,2) end
		if not inputConverters[newtype] then error("Invalid/unsupported input type: "..newtype,2) end
		names[i] = newname
		types[i] = newtype
	end
	
	WireLib.AdjustSpecialInputs(ent,names,types)
end

-- ------------------------- Easy-Access Metatable ------------------------- --
-- TODO: Replace with a wirelink to instance.data.entity
local wire_ports_metatable = {}

function wire_ports_metatable:__index(name)
	SF.CheckType(name,"string")
	print( "Dereferencing inputs" )
	print( "input name: " .. name )
	
	local instance = SF.instance
	local ent = instance.data.entity
	if not ent then error("No entity",2) end

	local input = ent.Inputs[name]
	
	if not (input and input.Src and input.Src:IsValid()) then
		return nil
	end
	
	return inputConverters[input.Type](input.Value)
end

function wire_ports_metatable:__newindex(name,value)
	error( "Can't set outputs on client side" )
end

SF.Typedef("Ports",wire_ports_metatable)
wire_library.ports = setmetatable({},wire_ports_metatable)
