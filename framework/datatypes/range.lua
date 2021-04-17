
local module = {}

local range = {}
range.__index = range


-- check if an object is a range
local function isRange(r)
	return getmetatable(r) == range
end

local function new(a, b)
	local Obj = {
		["Min"] = math.min(a, b);
		["Max"] = math.max(a, b);
		["Size"] = nil;
	}
	Obj.Size = Obj.Max - Obj.Min
	return setmetatable(Obj, range)
end


-- returns true if the given range intersects this range
function range:intersects(r)
	if module.isRange(r) then
		return (self.Min <= r.Max and self.Max >= r.Min)
	end
	return false
end

-- https://scicomp.stackexchange.com/questions/26258/the-easiest-way-to-find-intersection-of-two-intervals
-- returns a new range that is the intersection with the other range
function range:intersection(r)
	if module.isRange(r) then
		if self:intersects(r) then
			return new(math.max(self.Min, r.Min), math.min(self.Max, r.Max))
		end
	end
	return nil
end

function range:clamp(x)
	if x > self.Max then
		x = self.Max
	elseif x < self.Min then
		x = self.Min
	end
	return x
end

function range:contains(x)
	return self.Min >= x and self.Max <= x
end

function range:clone()
	return new(self.Min, self.Max)
end


local a = (2 * math.atan(2)) / math.pi

function range:randomInt(mode)
	assert(self.Min % 1 == 0 and self.Max % 1 == 0, "method function:randomInt() cannot produce an output for non-integer ranges")
	if mode == nil or mode == "default" then
		return love.math.random(self.Min, self.Max)
	elseif mode == "concentrated" then
		local x = love.math.random()
		local step = 1 / self.Size
		return self.Min + math.ceil((0.25 * math.tan(math.pi * a * (x - 0.5)) + 0.5) * self.Size)
		--return self.Min + math.ceil(((x < 0.5) and math.sqrt(math.sqrt(2 * x)) / 2 or -math.sqrt(math.sqrt(2 - 2 * x)) / 2 + 1) * self.Size)
	end
end

-- returns a random decimal number between the range's min and max
function range:randomDecimal(mode)
	if mode == nil or mode == "default" then
		return self.Min + love.math.random() * (self.Size)
	elseif mode == "concentrated" then
		local x = love.math.random()
		return self.Min + (0.25 * math.tan(math.pi * a * (x - 0.5)) + 0.5) * self.Size
		--return self.Min + ((x < 0.5) and math.sqrt(math.sqrt(2 * x)) / 2 or -math.sqrt(math.sqrt(2 - 2 * x)) / 2 + 1) * self.Size
	end
end

function range:__tostring()
	return "[" .. tostring(self.Min) .. ", " .. tostring(self.Max) .. "]"
end

function range:__add(v)
	if module.isRange(v) then
		return new(self.Min + v.Min, self.Max + v.Max)
	else
		return new(self.Min + v, self.Max + v)
	end
end

function range:__sub(v)
	if module.isRange(v) then
		return new(self.Min - v.Min, self.Max - v.Max)
	else
		return new(self.Min - v, self.Max - v)
	end
end

function range:__unm()
	return new(-self.Max, -self.Min)
end

function range:__mul(v)
	if module.isRange(v) then
		return new(self.Min * v.Min, self.Max * v.Max)
	else
		return new(self.Min * v, self.Max * v)
	end
end

function range:__div(v)
	if module.isRange(v) then
		return new(self.Min / v.Min, self.Max / v.Max)
	else
		return new(self.Min / v, self.Max / v)
	end
end


module.new = new
module.isRange = isRange
return setmetatable(module, {__call = function(_, ...) new(...) end})


