
local wire_library = {}
--- Wire library. Handles wire inputs/outputs, wirelinks, etc.
SF.Libraries.Register("wire",wire_library)

SF.Wire = {}
SF.Wire.Library = wire_library

local wirelink_metatable = {}
local wlwrap, wlunwrap = SF.CreateWrapper(wirelink_metatable)

---
-- @class table
-- @name SF.Wire.WlMetatable
SF.Wire.WlMetatable = wirelink_metatable

---
-- @class function
-- @name SF.Wire.WlWrap
-- @param wirelink
SF.Wire.WlWrap = wlwrap

---
-- @class function
-- @name SF.Wire.WlUnwrap
-- @param wrapped
SF.Wire.WlUnwrap = wlunwrap

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

local outputConverters =
{
	NORMAL = function(data)
		SF.CheckType(data,"number",1)
		return data
	end,
	STRING = function(data)
		SF.CheckType(data,"string",1)
		return data
	end,
	VECTOR = function(data)
		SF.CheckType(data,"Vector",1)
		return data
	end,
	ANGLE = function(data)
		SF.CheckType(data,"Angle",1)
		return data
	end
}

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
	
	if ent.sharedscreen then
		print( "sharedscreen is true" )
		for k, v in ipairs( ent.Inputs ) do
			local value = ent.Inputs[k].Value
			ent:TriggerValue( k, value )
		end
	end
end

--- Creates/Modifies wire outputs. All wire ports must begin with an uppercase
-- letter and contain only alphabetical characters.
-- @param names An array of output names. May be modified by the function.
-- @param types An array of output types. May be modified by the function.
function wire_library.createOutputs(names, types)
	SF.CheckType(names,"table")
	SF.CheckType(types,"table")
	local ent = SF.instance.data.entity
	if not ent then error("No entity to create outputs on",2) end
	
	if #names ~= #types then error("Table lengths not equal",2) end
	for i=1,#names do
		local newname = names[i]
		local newtype = types[i]
		if type(newname) ~= "string" then error("Non-string output name: "..newname,2) end
		if type(newtype) ~= "string" then error("Non-string output type: "..newtype,2) end
		newtype = newtype:upper()
		if not newname:match("^[A-Z][a-zA-Z]*$") then error("Invalid output name: "..newname,2) end
		if not outputConverters[newtype] then error("Invalid/unsupported output type: "..newtype,2) end
		names[i] = newname
		types[i] = newtype
	end
	
	WireLib.AdjustSpecialOutputs(ent,names,types)
end

--- Returns the wirelink representing this entity. This is how you read inputs.
function wire_library.self()
	local ent = SF.instance.data.entity
	if not ent then error("No entity",2) end
	return wlwrap(ent)
end

-- ------------------------- Wirelink ------------------------- --

--- Retrieves an output. Returns nil if the input doesn't exist.
wirelink_metatable.__index = function(self,k)
	SF.CheckType(self,wirelink_metatable)
	if wirelink_metatable[k] and k:sub(1,2) ~= "__" then return wirelink_metatable[k]
	else
		local wl = wlunwrap(self)
		if not wl or not wl:IsValid() or not wl.extended then return end -- TODO: What is wl.extended?
		
		if type(k) == "number" then
			if not wl.ReadCell then return nil
			else return wl:ReadCell(k) end
		else
			local output = wl.Outputs[k]
			if not output or not inputConverters[output.Type] then return end
			return inputConverters[output.Type](output.Value)
		end
	end
end

--- Writes to an input.
wirelink_metatable.__newindex = function(self,k,v)
	SF.CheckType(self,wirelink_metatable)
	local wl = wlunwrap(self)
	if not wl or not wl:IsValid() or not wl.extended then return end -- TODO: What is wl.extended?
	if type(k) == "number" then
		SF.CheckType(v,"number")
		if not wl.WriteCell then return end
		
	else
		local input = wl.Inputs[k]
		if not input or not outputConverters[input.Type] then return end
		Wire_TriggerOutput(wl,input.Name,outputConverters[input.Type](v))
	end
end

SF.Typedef("Wirelink",wirelink_metatable)

--- Checks if a wirelink is valid. (ie. doesn't point to an invalid entity)
function wirelink_metatable:isValid()
	SF.CheckType(self,wirelink_metatable)
	return wlunwrap(self) and true or false
end

--- Returns the type of input name, or nil if it doesn't exist
function wirelink_metatable:inputType(name)
	SF.CheckType(self,wirelink_metatable)
	local wl = wlunwrap(self)
	if not wl then return end
	local input = wl.Inputs[name]
	return input and input.Type
end

--- Returns the type of output name, or nil if it doesn't exist
function wirelink_metatable:outputType(name)
	SF.CheckType(self,wirelink_metatable)
	local wl = wlunwrap(self)
	if not wl then return end
	local output = wl.Outputs[name]
	return output and output.Type
end

--- Returns the entity that the wirelink represents
function wirelink_metatable:entity()
	SF.CheckType(self,wirelink_metatable)
	return SF.Entities.Wrap(wlunwrap(self))
end

--- Returns a table of all of the wirelink's inputs
function wirelink_metatable:inputs()
	SF.CheckType(self,wirelink_metatable)
	local wl = wlunwrap(self)
	if not wl then return nil end
	local inputs = {}
	for i=1,#wl.Inputs do
		inputs[i] = wl.Inputs[i].Name
	end
	return inputs
end

--- Returns a table of all of the wirelink's outputs
function wirelink_metatable:outputs()
	SF.CheckType(self,wirelink_metatable)
	local wl = wlunwrap(self)
	if not wl then return nil end
	local outputs = {}
	for i=1,#wl.Outputs do
		outputs[i] = wl.Outputs[i].Name
	end
	return outputs
end

--- Checks if an input is wired.
function wirelink_metatable:isWired(name)
	SF.CheckType(self,wirelink_metatable)
	SF.CheckType(name,"string")
	local wl = wlunwrap(self)
	if not wl then return nil end
	local input = wl.Inputs[name]
	if input and input.Src and input.Src:IsValid() then return true
	else return false end
end

-- ------------------------- Easy-Access Metatable ------------------------- --
-- TODO: Replace with a wirelink to instance.data.entity
local wire_ports_metatable = {}

function wire_ports_metatable:__index(name)
	SF.CheckType(name,"string")
	local instance = SF.instance
	local ent = instance.data.entity
	if not ent then error("No entity",2) end

	local input = ent.Inputs[name]
	if not (input and input.Src and input.Src:IsValid()) then
		return nil
	end
	return inputConverters[ent.Inputs[name].Type](ent.Inputs[name].Value)
end

function wire_ports_metatable:__newindex(name,value)
	SF.CheckType(name,"string")

	local instance = SF.instance
	local ent = instance.data.entity
	if not ent then error("No entity",2) end

	local output = ent.Outputs[name]
	if not output then return end
	
	Wire_TriggerOutput(ent, name, outputSerializers[output.Type](value))
end

SF.Typedef("Ports",wire_ports_metatable)
wire_library.ports = setmetatable({},wire_ports_metatable)
