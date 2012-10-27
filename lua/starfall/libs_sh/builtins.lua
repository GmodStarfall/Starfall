-------------------------------------------------------------------------------
-- Builtins.
-- Functions built-in to the default environment
-------------------------------------------------------------------------------

local dgetmeta = debug.getmetatable
local _R = debug.getregistry()
--- Built in values. These don't need to be loaded; they are in the default environment.
-- @name builtin
-- @shared
-- @class library
-- @libtbl SF.DefaultEnvironment

-- ------------------------- Lua Ports ------------------------- --
-- This part is messy because of LuaDoc stuff.

--- Same as the Gmod vector type
-- @name SF.DefaultEnvironment.Vector
-- @class function
-- @param x
-- @param y
-- @param z
SF.DefaultEnvironment.Vector = Vector
--- Same as the Gmod angle type
-- @name SF.DefaultEnvironment.Angle
-- @class function
-- @param p Pitch
-- @param y Yaw
-- @param r Roll
SF.DefaultEnvironment.Angle = Angle
--- Same as the Gmod VMatrix type
-- @name SF.DefaultEnvironment.VMatrix
-- @class function
SF.DefaultEnvironment.Matrix = Matrix
--- Same as Lua's tostring
-- @name SF.DefaultEnvironment.tostring
-- @class function
-- @param obj
SF.DefaultEnvironment.tostring = tostring
--- Same as Lua's tonumber
-- @name SF.DefaultEnvironment.tonumber
-- @class function
-- @param obj
SF.DefaultEnvironment.tonumber = tonumber
--- Same as Lua's ipairs
-- @name SF.DefaultEnvironment.ipairs
-- @class function
-- @param tbl
SF.DefaultEnvironment.ipairs = ipairs
--- Same as Lua's pairs
-- @name SF.DefaultEnvironment.pairs
-- @class function
-- @param tbl
SF.DefaultEnvironment.pairs = pairs
--- Same as Lua's type
-- @name SF.DefaultEnvironment.type
-- @class function
-- @param obj
SF.DefaultEnvironment.type = type
--- Same as Lua's next
-- @name SF.DefaultEnvironment.next
-- @class function
-- @param tbl
SF.DefaultEnvironment.next = next
--- Same as Lua's assert. TODO: lua's assert doesn't work.
-- @name SF.DefaultEnvironment.assert
-- @class function
-- @param condition
-- @param msg
SF.DefaultEnvironment.assert = function(ok, msg) if not ok then error(msg or "assertion failed!",2) end end
--- Same as Lua's unpack
-- @name SF.DefaultEnvironment.unpack
-- @class function
-- @param tbl
SF.DefaultEnvironment.unpack = unpack

--- Same as Lua's setmetatable. Doesn't work on most internal metatables
SF.DefaultEnvironment.setmetatable = setmetatable
--- Same as Lua's getmetatable. Doesn't work on most internal metatables
SF.DefaultEnvironment.getmetatable = function(tbl)
	SF.CheckType(tbl,"table")
	return getmetatable(tbl)
end
--- Throws an error. Can't change the level yet.
SF.DefaultEnvironment.error = function(msg) error(msg,2) end

SF.DefaultEnvironment.CLIENT = CLIENT
SF.DefaultEnvironment.SERVER = SERVER

--- Gets the amount of ops used so far
function SF.DefaultEnvironment.opsUsed()
	return SF.instance.ops
end

--- Gets the ops hard quota
function SF.DefaultEnvironment.opsMax()
	return SF.instance.context.ops
end

-- The below modules have the Gmod functions removed (the ones that begin with a capital letter),
-- as requested by Divran

-- Filters Gmod Lua files based on Garry's naming convention.
local function filterGmodLua(lib, original, gm)
	original = original or {}
	gm = gm or {}
	for name, func in pairs(lib) do
		if name:match("^[A-Z]") then
			gm[name] = func
		else
			original[name] = func
		end
	end
	return original, gm
end

-- String library
local string_methods, string_metatable = SF.Typedef("Library: string")
filterGmodLua(string,string_methods)
string_metatable.__newindex = function() end
--- Lua's (not glua's) string library
-- @name SF.DefaultEnvironment.string
-- @class table
SF.DefaultEnvironment.string = setmetatable({},string_metatable)

-- Math library
local math_methods, math_metatable = SF.Typedef("Library: math")
filterGmodLua(math,math_methods)
math_metatable.__newindex = function() end
math_methods.clamp = math.Clamp
math_methods.round = math.Round
math_methods.randfloat = math.Rand
math_methods.calcBSplineN = nil
--- Lua's (not glua's) math library, plus clamp, round, and randfloat
-- @name SF.DefaultEnvironment.math
-- @class table
SF.DefaultEnvironment.math = setmetatable({},math_metatable)

local table_methods, table_metatable = SF.Typedef("Library: table")
filterGmodLua(table,table_methods)
table_metatable.__newindex = function() end
--- Lua's (not glua's) table library
-- @name SF.DefaultEnvironment.table
-- @class table
SF.DefaultEnvironment.table = setmetatable({},table_metatable)

-- ------------------------- Functions ------------------------- --

--- Loads a library.
function SF.DefaultEnvironment.loadLibrary(name)
	SF.CheckType(name,"string")
	local instance = SF.instance
	
	if instance.context.libs[name] then
		return setmetatable({},instance.context.libs[name])
	else
		return SF.Libraries.Get(name)
	end
end

--- Sets a hook function
function SF.DefaultEnvironment.hook(hookname, name, func)
	SF.CheckType(hookname,"string")
	SF.CheckType(name,"string")
	if func then SF.CheckType(func,"function") end
	
	local inst = SF.instance
	local hooks = inst.hooks[hookname:lower()]
	if not hooks then
		hooks = {}
		inst.hooks[hookname:lower()] = hooks
	end
	
	hooks[name] = func
end

if SERVER then
	--- Prints a message to the player's chat. Limited to 255 characters on the server.
	function SF.DefaultEnvironment.print(s)
		SF.instance.player:PrintMessage(HUD_PRINTTALK, tostring(s):sub(1,255))
	end
else
	function SF.DefaultEnvironment.print(s)
		LocalPlayer():PrintMessage(HUD_PRINTTALK, tostring(s))
	end
end

--- Runs an --@include'd script and caches the result.
-- Works pretty much like standard Lua require()
function SF.DefaultEnvironment.require(file)
	SF.CheckType(file, "string")
	local loaded = SF.instance.data.reqloaded
	if not loaded then
		loaded = {}
		SF.instance.data.reqloaded = loaded
	end
	
	if loaded[file] then
		return loaded[file]
	else
		local func = SF.instance.scripts[file]
		if not func then error("Can't find file '"..file.."' (did you forget to --@include it?)",2) end
		loaded[file] = func() or true
		return loaded[file]
	end
end

--- Runs an --@include'd file and returns the result.
-- Pretty much like standard Lua dofile()
function SF.DefaultEnvironment.dofile(file)
	SF.CheckType(file, "string")
	local func = SF.instance.scripts[file]
	if not func then error("Can't find file '"..file.."' (did you forget to --@include it?)",2) end
	return func()
end

-- ------------------------- Restrictions ------------------------- --
-- Restricts access to builtin type's metatables

local function restrict(instance, hook, name, ok, err)
	_R.Vector.__metatable = "Vector"
	_R.Angle.__metatable = "Angle"
	_R.VMatrix.__metatable = "VMatrix"
end

local function unrestrict(instance, hook, name, ok, err)
	_R.Vector.__metatable = nil
	_R.Angle.__metatable = nil
	_R.VMatrix.__metatable = nil
end

SF.Libraries.AddHook("prepare", restrict)
SF.Libraries.AddHook("cleanup", unrestrict)

-- ------------------------- Hook Documentation ------------------------- --

--- Think hook. Called once per game tick
-- @name think
-- @class hook
-- @shared
