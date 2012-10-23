-------------------------------------------------------------------------------
-- Shared color functions
-------------------------------------------------------------------------------

assert(SF.Entities)

SF.Color = {}

--- Color functions. Enables getting / setting of entity color / material / skin.
-- @shared
local color_library, _ = SF.Libraries.Register("color")

SF.Color.Library = color_library

local ents_methods = SF.Entities.Methods
local ents_metatable = SF.Entities.Metatable

local wrap, unwrap = SF.Entities.Wrap, SF.Entities.Unwrap

local isValid = SF.Entities.IsValid


--- Convert HSV to RGB
-- @param h Hue
-- @param s Saturation
-- @param v Value
-- @return Red,Green,Blue values
function color_library.hsv2rgb(h,s,v)
	SF.CheckType(h,"number")
	SF.CheckType(s,"number")
	SF.CheckType(v,"number")

	local c = HSVToColor(h,s,v)
	return c.r, c.g, c.b
end

--- Converts RGB to HSV
-- @param r Red
-- @param g Green
-- @param b Blue	
-- @return Hue,Saturation,Value values
function color_library.rgb2hsv(r,g,b)
	SF.CheckType(h,"number")
	SF.CheckType(s,"number")
	SF.CheckType(v,"number")

	return ColorToHSV(Color(r,g,b))
end

local function hue2rgb(p,q,t)
	if t < 0 then t = t + 1 end
	if t > 1 then t = t - 1 end
	if t < 1/6 then return p + (q - p) * 6 * t end
	if t < 1/2 then return q end
	if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
	return p
end

--- Convert HSL to RGB
-- @param h Hue
-- @param s Saturation
-- @param l Lightness
-- @return Red,Green,Blue values
function color_library.hsl2rgb(h,s,l)
	SF.CheckType(h,"number")
	SF.CheckType(s,"number")
	SF.CheckType(l,"number")

	local r = 0
   local g = 0
   local b = 0

	if s == 0 then
		r = l
      g = l
      b = l
	else
		local q = l + s - l * s
		if l < 0.5 then q = l * (1 + s) end
		local p = 2 * l - q
		r = hue2rgb(p, q, h + 1/3)
		g = hue2rgb(p, q, h)
		b = hue2rgb(p, q, h - 1/3)
	end

	return math.floor(r * 255), math.floor(g * 255), math.floor(b * 255)
end

--- Converts RGB to HSL
-- @param r Red
-- @param g Green
-- @param b Blue	
-- @return Hue,Saturation,Lightness values
function color_library.rgb2hsl(r,g,b)
	SF.CheckType(r,"number")
	SF.CheckType(g,"number")
	SF.CheckType(b,"number")

  	r = r / 255
  	g = g / 255
  	b = b / 255
	local max = math.max(r, g, b)
   local min = math.min(r, g, b)
	local h = (max + min) / 2
	local s = h
   local l = h

	if max == min then
		h = 0
      s = 0
	else
		local d = max - min
		s =  d / (max + min)
		if l > 0.5 then s = d / (2 - max - min) end
		if max == r then
			if g < b then
				h = (g - b) / d + 6
			else
				h = (g - b) / d + 0
			end
		elseif max == g then
			h = (b - r) / d + 2
		elseif max == b then
			h = (r - g) / d + 4
		end
		h = h / 6
	end

	return h, s, l
end

local converters = {}
converters[0] = function(r, g, b)
	local r = math.Clamp(math.floor(r/28),0,9)
	local g = math.Clamp(math.floor(g/28),0,9)
	local b = math.Clamp(math.floor(b/28),0,9)

	return r*100000+g*10000+b*1000
end
converters[1] = false
converters[2] = function(r, g, b)
	return math.floor(r)*65536+math.floor(g)*256+math.floor(b)
end
converters[3] = function(r, g, b)
	return math.floor(r)*1000000+math.floor(g)*1000+math.floor(b)
end


--- Converts the RGB color to a number in digital screen format
-- @param r Red
-- @param g Green
-- @param b Blue
-- @param mode Specifies a mode, either 0, 2 or 3, corresponding to Digital Screen color modes
-- @return Digital format number
function color_library.rgb2digi(r, g, b, mode)
	SF.CheckType(r,"number")
	SF.CheckType(g,"number")
	SF.CheckType(b,"number")
	SF.CheckType(mode,"number")

	local conv = converters[mode]
	if not conv then return 0, "wrong mode" end
	return conv(r, g, b)
end

-- ------------------------- Methods ------------------------- --

--- Get entity color
-- @shared
-- @return Red,Green,Blue,Alpha values
function ents_methods:getColor()
	SF.CheckType(self,ents_metatable)

	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end

	local c = ent:GetColor()
	return c.r, c.g, c.b, c.a
end

--- Get entity alpha
-- @shared
-- @return Alpha
function ents_methods:getAlpha()
	SF.CheckType(self,ents_metatable)

	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end

	local c = ent:GetColor()
	return c.a or 0
end
