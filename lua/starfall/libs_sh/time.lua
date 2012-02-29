
local timerx = timerx

--- Deals with time and timers.
-- @shared
local time_library, _ = SF.Libraries.Register("time")

-- ------------------------- Time ------------------------- --

--- Same as GLua's CurTime()
function time_library.curTime()
	return CurTime()
end

--- Same as GLua's RealTime()
function time_library.realTime()
	return RealTime()
end

--- Same as GLua's SysTime()
function time_library.sysTime()
	return SysTime()
end

-- ------------------------- Timers ------------------------- --

local function timercb(instance, tname, realname, func,...)
	if instance and not instance.error then
		instance:runFunction(func,...)
	else
		timerx.Remove(realname)
	end
end

local function mangle_timer_name(instance, name)
	return tostring(instance).."_"..name
end

--- Creates (and starts) a timer
-- @param name The timer name
-- @param delay The time, in seconds, to set the timer to.
-- @param reps The repititions of the timer. 0 = infinte, nil = 1
-- @param func The function to call when the timer is fired
-- @param ... Arguments to func
-- @return The timer as a table. This can be modified, but shouldn't
function time_library.create(name, delay, reps, func, ...)
	SF.CheckType(name,"string")
	SF.CheckType(delay,"number")
	reps = SF.CheckType(reps,"number",0,1)
	SF.CheckType(func,"function")
	
	local instance = SF.instance
	local timername = mangle_timer_name(instance,name)
	
	return timerx.Create(timername, delay, reps, timercb, instance, name, timername, func, ...)
end

--- Creates (and starts) a simple timer. This timer cannot be adjusted, paused, or removed
-- @param name The timer name
-- @param delay The time, in seconds, to set the timer to.
-- @param func The function to call when the timer is fired
-- @param ... Arguments to func
-- @return nil
function time_library.simple(delay, func, ...)
	SF.CheckType(delay,"number")
	SF.CheckType(func,"function")
	timerx.Simple( delay, timercb, SF.instance, nil, nil, func, ... )
end

-- Adjusts a timer. Creates the timer if it doesn't exist (if delay, reps, and func are not nil).
-- @param name The timer name
-- @param delay The time, in seconds, to set the timer to (optional)
-- @param reps The repetitions of the timer. 0 = infinite (optional)
-- @param func The function to call when the timer is fired (optional)
-- @param ... Arguments to func
-- @return The timer as a table. This can be modified, but shouldn't
function time_library.adjust(name,delay,reps,func,...)
	SF.CheckType(name,"string")
	
	local instance = SF.instance
	local timername = mangle_timer_name(instance,name)
	
	return timerx.Adjust(timername,delay,reps,func,...)
end

-- Starts a paused timer
-- @param name The timer name
-- @return true/false on success/failure
function time_library.start(name)
	SF.CheckType(name,"string")

	local instance = SF.instance
	local timername = mangle_timer_name(instance,name)
	
	return timerx.Start(timername)
end


-- Pauses a timer
-- @param name The timer name
-- @return true/false on success/failure
function time_library.pause(name)
	SF.CheckType(name,"string")

	local instance = SF.instance
	local timername = mangle_timer_name(instance,name)
	
	return timerx.Pause(timername)
end

--- Removes a timer
-- @param name Timer name
-- @return true/false on success/failure
function time_library.remove(name)
	SF.CheckType(name,"string")
	local instance = SF.instance
	local timername = mangle_timer_name(instance,name)
	
	return timerx.Remove(timername)
end

--- Gets the timer. If no timer is specified, returns all timers.
-- @param name Timer name (optional)
-- @return true/false on success/failure
function time_library.get(name)
	SF.CheckType(name,"string")
	local instance = SF.instance
	local timername = mangle_timer_name(instance,name)
	return timerx.Get(timername)
end

-- Check is a timer exists
-- @param name Time name
-- @return true/false
function time_library.exists(name)
	SF.CheckType(name,"string")
	local instance = SF.instance
	local timername = mangle_timer_name(instance,name)
	return timerx.Exists(timername)
end



local string_sub = string.sub
local function deinit(instance)
	local namepart = tostring(instance)

	local timers = timerx.Get()
	for i=#timers,1,-1 do -- Loop backwards so we can remove timers without causing issues
		local name = timers[i].name
		if name then -- Make sure it isn't a simple timer
			if string_sub(name,1,#namepart) == namepart then
				timerx.Remove(name)
			end
		end
	end
end
SF.Libraries.AddHook("deinitialize",deinit)
