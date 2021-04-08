
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

-- generates a color with a random hue, saturation and value. Saturation and value are skewed to be higher values than lower (to prioritize bright saturated colors)
local function random()
	local h = love.math.random() * 360
	local s = math.sqrt(love.math.random())
	local v = math.sqrt(love.math.random())
	return fromHSV(h, s, v)
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

-- https://www.rapidtables.com/convert/color/rgb-to-hsl.html
function color:getHSL()

end

-- https://www.rapidtables.com/convert/color/rgb-to-hsv.html
function color:getHSV()
	local cmin = math.min(math.min(self.r, self.g), self.b)
	local cmax = math.max(math.max(self.r, self.g), self.b)

	if cmin == cmax then return 0 end

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

function color:getHue()

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
	assert(r~=nil and g~=nil and b~=nil, "color:set(r, g, b, a) requires at least 3 arguments to be supplied")
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


function color:__tostring()
	return "(" .. math.floor(self.r * 255 + 0.5) .. ", " .. math.floor(self.g * 255 + 0.5) .. ", " .. math.floor(self.b * 255 + 0.5) .. ", " .. math.floor(self.a * 1000) / 1000 .. ")"
end


-- pack up and return module
module.new = new
module.fromRGB = fromRGB
module.fromHSV = fromHSV
module.fromHex = fromHex
module.random = random
module.isColor = isColor
return setmetatable(module, {__call = function(_, ...) return new(...) end})




