
local module = {}

local color = {}
color.__index = color


-- check if an object is a color
local function isColor(t)
	return getmetatable(t) == color
end


local function new(r, g, b, a)
	local col = nil
	if isColor(r) then
		col = {
			["r"] = r.r == nil and 1 or r.r;
			["g"] = r.g == nil and 1 or r.g;
			["b"] = r.b == nil and 1 or r.b;
			["a"] = r.a == nil and 1 or r.a;
		}
	else
		col = {
			["r"] = r == nil and 1 or r;
			["g"] = g == nil and 1 or g;
			["b"] = b == nil and 1 or b;
			["a"] = a == nil and 1 or a;
		}
	end

	return setmetatable(col, color)
end

local function fromRGB(r, g, b)
	return new(r/255, g/255, b/255)
end

local function fromHex(hexString)
	if hexString:sub(1, 1) == "#" then
		hexString = hexString:sub(2)
	end
	local numbers = {}
	for component in hexString:gmatch("..") do
		numbers[#numbers + 1] = tonumber(component, 16) / 255
	end
	return new(unpack(numbers))
end


local hexMatch = "^#?" .. ("[A-Fa-f0-9]"):rep(6) .. "$" -- start with a '#' optionally, followed by 6 characters that are HEX values
local function isHex(s)
	return string.match(s, hexMatch) ~= nil
end


local function fromHSV(h, s, v)
	local c = v * s
	local x = c * (1 - math.abs((h / 60) % 2 - 1))
	local m = v - c
	if 0 <= h and h < 60 then
		r = c + m
		g = x + m
		b = m
	elseif 60 <= h and h < 120 then
		r = x + m
		g = c + m
		b = m
	elseif 120 <= h and h < 180 then
		r = m
		g = c + m
		b = x + m
	elseif 180 <= h and h < 240 then
		r = m
		g = x + m
		b = c + m
	elseif 240 <= h and h < 300 then
		r = x + m
		g = m
		b = c + m
	elseif 300 <= h and h < 360 then
		r = c + m
		g = m
		b = x + m
	else
		r = m
		g = m
		b = m
	end
	return new(r, g, b)
end

-- https://www.rapidtables.com/convert/color/hsl-to-rgb.html
function fromHSL(h, s, l)
	h = h % 360
	local c = (1 - math.abs(2 * l - 1)) * s
	local x = c * (1 - math.abs(((h / 60) % 2) - 1))
	local m = l - c/2
	local r, g, b = 0, 0, 0
	if 0 <= h and h < 60 then
		r, g, b = c, x, 0
	elseif 60 <= h and h < 120 then
		r, g, b = x, c, 0
	elseif 120 <= h and h < 180 then
		r, g, b = 0, c, x
	elseif 180 <= h and h < 240 then
		r, g, b = 0, x, c
	elseif 240 <= h and h < 300 then
		r, g, b = x, 0, c
	elseif 300 <= h and h <= 360 then
		r, g, b = c, 0, x
	end
	return new(r + m, g + m, b + m)
end

-- generates a color with a random hue, saturation and value. Saturation and value are skewed to be higher values than lower (to prioritize bright saturated colors)
local function random()
	local h = love.math.random() * 360
	local s = math.sqrt(love.math.random())
	local v = math.sqrt(love.math.random())
	return fromHSV(h, s, v)
end

-- interpolate(from, to, x), where 'from' is a starting color, 'to' is a destination color and 'x' is how far along you are
local function interpolate(from, to, x)
    local h1, s1, l1 = from:getHSL()
	local h2, s2, l2 = to:getHSL()

	--https://gist.github.com/shaunlebron/8832585
	local da = (h2 - h1) % 360
	local v = 2 * da % 360 - da
	local h = h1 + v * x
	local s = s1 + (s2 - s1) * x
	local l = l1 + (l2 - l1) * x
	local interpolated = fromHSL(h, s, l)
	-- alpha channel is interpolated linearly
	interpolated.a = from.a + (to.a - from.a) * x
	return interpolated
	--return fromHSL(h, s, l)
end

-- return an array representing the color
function color:array()
	return {self.r, self.g, self.b, self.a}
end

-- return the color components as a tuple
function color:components()
	return self.r, self.g, self.b, self.a
end

-- copy the color
function color:clone()
	return new(self.r, self.g, self.b, self.a)
end

-- darken the color by some amount, where 1 = pitch black and 0 = no change
function color:darken(v)
	self.r = self.r * (1 - v)
	self.g = self.g * (1 - v)
	self.b = self.b * (1 - v)
	return self
end

-- lighten the color by some amount, where 1 = pure white and 0 = no change
function color:lighten(v)
	self.r = math.min(1, self.r + (1 - self.r) * v)
	self.g = math.min(1, self.g + (1 - self.g) * v)
	self.b = math.min(1, self.b + (1 - self.b) * v)
	return self
end

-- make the color black-white.
function color:grayscale()
	-- calculate luminance
	local luminance = self.r * 0.299 + self.g * 0.587 + 0.114 * self.b -- source: https://www.w3.org/TR/AERT/#color-contrast
	self:set(luminance, luminance, luminance)
	return self
end


function color:getHue()
	local cmax = math.max(self.r, self.g, self.b)
	local cmin = math.min(self.r, self.g, self.b)
	local d = cmax - cmin
	local h = 0
	if d == 0 then
		h = 0
	elseif cmax == self.r then
		h = 60 * (((self.g - self.b) / d) % 6)
	elseif cmax == self.g then
		h = 60 * (((self.b - self.r) / d) + 2)
	elseif cmax == self.b then
		h = 60 * (((self.r - self.g) / d) + 4)
	end
	return h
end


-- https://www.rapidtables.com/convert/color/rgb-to-hsl.html
function color:getHSL()
	local cmax = math.max(self.r, self.g, self.b)
	local cmin = math.min(self.r, self.g, self.b)
	local d = cmax - cmin
	local h = 0
	if d == 0 then
		h = 0
	elseif cmax == self.r then
		h = 60 * (((self.g - self.b) / d) % 6)
	elseif cmax == self.g then
		h = 60 * (((self.b - self.r) / d) + 2)
	elseif cmax == self.b then
		h = 60 * (((self.r - self.g) / d) + 4)
	end
	local l = (cmax + cmin) / 2
	local s = 0
	if d ~= 0 then
		s = d / (1 - math.abs(2 * l - 1))
	end
	return h, s, l
end

-- https://www.rapidtables.com/convert/color/rgb-to-hsv.html
function color:getHSV()
	local cmin = math.min(math.min(self.r, self.g), self.b)
	local cmax = math.max(math.max(self.r, self.g), self.b)

	if cmin == cmax then return 0, 0, cmin end

	local hue = 0
	if cmax == self.r then
		hue = ((self.g - self.b) / (cmax - cmin)) % 6
	elseif cmax == self.g then
		hue = 2 + (self.b - self.r) / (cmax - cmin)
	elseif cmax == self.b then
		hue = 4 + (self.r - self.g) / (cmax - cmin)
	end
	hue = hue * 60
	if hue < 0 then
		hue = hue + 360
	end

	local sat = 0
	if cmax ~= 0 then
		sat = (cmax - cmin) / cmax
	end

	local val = cmax

	return math.floor(hue + 0.5) % 360, sat, val
end

-- butterfly image response
-- https://stackoverflow.com/questions/8507885/shift-hue-of-an-rgb-color
-- shifts the hue of a color by a certain number of degrees, keeping saturation and value the same
function color:shiftHue(deg)
	local cosA = math.cos(math.rad(deg))
	local sinA = math.sin(math.rad(deg))
	local m00 = cosA + (1 - cosA) / 3
	local m01 = 1/3 * (1 - cosA) - math.sqrt(1/3) * sinA
	local m02 = 1/3 * (1 - cosA) + math.sqrt(1/3) * sinA
	local m10 = 1/3 * (1 - cosA) + math.sqrt(1/3) * sinA
	local m11 = cosA + 1/3 * (1 - cosA)
	local m12 = 1/3 * (1 - cosA) - math.sqrt(1/3) * sinA
	local m20 = 1/3 * (1 - cosA) - math.sqrt(1/3) * sinA
	local m21 = 1/3 * (1 - cosA) + math.sqrt(1/3) * sinA
	local m22 = cosA + 1/3 * (1 - cosA)

	local rx = self.r * m00 + self.g * m01 + self.b * m02
	local gx = self.r * m10 + self.g * m11 + self.b * m12
	local bx = self.r * m20 + self.g * m21 + self.b * m22

	self.r = math.min(math.max(rx, 0), 1)
	self.g = math.min(math.max(gx, 0), 1)
	self.b = math.min(math.max(bx, 0), 1)
	return self
end

-- set the rgba components.
function color:set(r, g, b, a)
	assert(r ~= nil and g ~= nil and b ~= nil, "color:set(r, g, b, a) requires at least 3 arguments to be supplied")
	if r > 1 or g > 1 or b > 1 then
		self.r = r / 255
		self.g = g / 255
		self.b = b / 255
	else
		self.r = r
		self.g = g
		self.b = b
	end
	self.a = a == nil and self.a or a
end


-- taken from: https://www.codegrepper.com/code-examples/lua/rgb+to+hex+lua
function color:toHex()
	return string.format("#%02X%02X%02X", math.floor(self.r * 255 + 0.5), math.floor(self.g * 255 + 0.5), math.floor(self.b * 255 + 0.5))
end


function color:__tostring()
	return "(" .. math.floor(self.r * 255 + 0.5) .. ", " .. math.floor(self.g * 255 + 0.5) .. ", " .. math.floor(self.b * 255 + 0.5) .. ", " .. math.floor(self.a * 1000) / 1000 .. ")"
end

function color:__eq(a)
	return math.floor(a.r * 255 + 0.5) == math.floor(self.r * 255 + 0.5) and math.floor(a.g * 255 + 0.5) == math.floor(self.g * 255 + 0.5) and math.floor(a.b * 255 + 0.5) == math.floor(self.b * 255 + 0.5)
end


-- pack up and return module
module.new = new
module.fromRGB = fromRGB
module.fromHSV = fromHSV
module.fromHSL = fromHSL
module.fromHex = fromHex
module.random = random
module.isColor = isColor
module.isHex = isHex
module.interpolate = interpolate
return setmetatable(module, {__call = function(_, ...) return new(...) end})




