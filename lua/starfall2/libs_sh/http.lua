------------------------------------------------------------------------
-- Initialize                                                         --
------------------------------------------------------------------------
local http_lib = { }

SF.Libraries.Register("http",http_lib)

------------------------------------------------------------------------
-- Local Library                                                      --
------------------------------------------------------------------------

local function http_callback( args, content, size )
	local instance = args[1]
	local func = args[2]
	local url = args[3]
	
	if not instance.error then
		instance:runFunction( func, content, size, url )
	end
end

------------------------------------------------------------------------
-- Library                                                            --
------------------------------------------------------------------------
function http_lib.get( url, func )
	local instance = SF.instance
	
	http.Get( url, "", http_callback, instance, func, url )
end
