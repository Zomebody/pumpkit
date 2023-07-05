
local module = {}

local range = {}
range.__index = range


-- check if an object is a range
local function isRange(r)
	return getmetatable(r) == range
end

local function new(a, b)
	local Obj = {
		["min"] = math.min(a, b);
		["max"] = math.max(a, b);
		["size"] = nil;
	}
	Obj.size = Obj.max - Obj.min
	return setmetatable(Obj, range)
end


-- returns true if the given range intersects this range
function range:intersects(r)
	if module.isRange(r) then
		return (self.min <= r.max and self.max >= r.min)
	end
	return false
end

-- https://scicomp.stackexchange.com/questions/26258/the-easiest-way-to-find-intersection-of-two-intervals
-- returns a new range that is the intersection with the other range
function range:intersection(r)
	if module.isRange(r) then
		if self:intersects(r) then
			return new(math.max(self.min, r.min), math.min(self.max, r.max))
		end
	end
	return nil
end

function range:clamp(x)
	if x > self.max then
		x = self.max
	elseif x < self.min then
		x = self.min
	end
	return x
end

function range:interpolate(x)
	return self.min + (self.max - self.min) * x
end

function range:contains(x)
	return self.min >= x and self.max <= x
end

function range:clone()
	return new(self.min, self.max)
end


local a = (2 * math.atan(2)) / math.pi

function range:randomInt(mode)
	assert(self.min % 1 == 0 and self.max % 1 == 0, "method function:randomInt() cannot produce an output for non-integer ranges")
	if mode == nil or mode == "default" then
		return love.math.random(self.min, self.max)
	elseif mode == "concentrated" then
		local x = love.math.random()
		local step = 1 / self.size
		return self.min + math.ceil((0.25 * math.tan(math.pi * a * (x - 0.5)) + 0.5) * self.size)
		--return self.min + math.ceil(((x < 0.5) and math.sqrt(math.sqrt(2 * x)) / 2 or -math.sqrt(math.sqrt(2 - 2 * x)) / 2 + 1) * self.size)
	end
end

-- returns a random decimal number between the range's min and max
function range:randomDecimal(mode)
	if mode == nil or mode == "default" then
		return self.min + love.math.random() * (self.size)
	elseif mode == "concentrated" then
		local x = love.math.random()
		return self.min + (0.25 * math.tan(math.pi * a * (x - 0.5)) + 0.5) * self.size
		--return self.min + ((x < 0.5) and math.sqrt(math.sqrt(2 * x)) / 2 or -math.sqrt(math.sqrt(2 - 2 * x)) / 2 + 1) * self.size
	end
end

function range:__tostring()
	return "[" .. tostring(self.min) .. ", " .. tostring(self.max) .. "]"
end

function range:__add(v)
	if module.isRange(v) then
		return new(self.min + v.min, self.max + v.max)
	else
		return new(self.min + v, self.max + v)
	end
end

function range:__sub(v)
	if module.isRange(v) then
		return new(self.min - v.min, self.max - v.max)
	else
		return new(self.min - v, self.max - v)
	end
end

function range:__unm()
	return new(-self.max, -self.min)
end

function range:__mul(v)
	if module.isRange(v) then
		return new(self.min * v.min, self.max * v.max)
	else
		return new(self.min * v, self.max * v)
	end
end

function range:__div(v)
	if module.isRange(v) then
		return new(self.min / v.min, self.max / v.max)
	else
		return new(self.min / v, self.max / v)
	end
end


module.new = new
module.isRange = isRange
return setmetatable(module, {__call = function(_, ...) return new(...) end})


