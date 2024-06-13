
local getpath = require("framework.getpath")
local vector = require(getpath(..., "vector"))

local module = {}
-- create the module
local bezier = {}
bezier.__index = bezier

local new


-- check if an object is a bezier
local function isBezier(t)
	return getmetatable(t) == bezier
end



-- returns a copy of a bezier
function bezier:clone()
	return new(self.Points)
end


-- return coordinates in array form
function bezier:array()
	return {self.Points:unpack()}
end


-- return coordinates as a tuple
function bezier:unpack()
	return self.Points:unpack()
end


function bezier:getPoint(t)
	assert(type(t) == "number" and t >= 0 and t <= 1, "bezier:getPoint(t) expects argument t to be a number between 0 and 1")
	local points = self.Points
	while #points > 1 do
		local newPoints = {}
		for i = 1, #points - 1 do
			local p1 = points[i]
			local p2 = points[i + 1]
			local x = (1 - t) * p1.x + t * p2.x
			local y = (1 - t) * p1.y + t * p2.y
			table.insert(newPoints, vector(x, y))
		end
		points = newPoints
	end
	return points[1]
end


-- makes a new bezier
new = function(...)
	local t = {...}
	assert(#t > 0, "bezier.new(...) expects at least one argument, given is 0.")
	if type(t[1]) == "table" and not vector.isVector(t[1]) then
		t = t[1]
	end
	local Obj = {
		["Points"] = {};
	}
	for i = 1, #t do
		assert(vector.isVector(t[i]), "bezier.new(...) only accepts vectors or a table of vectors (got " .. type(t[i]) .. ")")
		Obj.Points[i] = vector(t[i].x, t[i].y)
	end

	return setmetatable(Obj, bezier)
end

-- meta function to add a vector to a bezier to offset the bezier
function bezier.__add(a, b)
	assert(isBezier(a) and vector.isVector(b), "add: wrong argument types: (expected <bezier> and <vector>)")
	local points = {}
	for i = 1, #a.Points do
		points[i] = a.Points[i] + b
	end
	return new(points)
end



-- pack up and return module
module.new = new
module.isBezier = isBezier
return setmetatable(module, {__call = function(_,...) return new(...) end})


