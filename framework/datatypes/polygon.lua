
local getpath = require("framework.getpath")
local vector = require(getpath(..., "vector"))
local line = require(getpath(..., "line"))

local module = {}

local polygon = {}
polygon.__index = polygon


-- check if an object is a polygon
local function isPolygon(t)
	return getmetatable(t) == polygon
end


-- create a new line object, which contains a list of line objects describing the shape of the polygon
local function new(...) -- list of points
	local points = {...}
	local pol = nil
	if isPolygon(points[1]) then
		return new(points[1]:getPoints())
	else -- arguments are vectors
		pol = {
			["Lines"] = {};
		}
		if #points < 3 then
			error("Polygon must be constructed from at least 3 vectors")
		else
			local n = #points
			for i = 1, n do
				if i == n then
					pol.Lines[#pol.Lines + 1] = line(points[i], points[1])
				else
					pol.Lines[#pol.Lines + 1] = line(points[i], points[i + 1])
				end
			end
		end
	end

	return setmetatable(pol, polygon)
end


-- returns a copy of all points making up the polygon
function polygon:getPoints()
	local points = {}
	for i = 1, #self.Lines do
		points[#points + 1] = vector(self.Lines[i].from)
	end
	return points
end


-- get the total circumference length of the polygon
function polygon:getPerimeter()
	local size = 0
	for i = 1, #self.Lines do
		size = size + self.Lines[i]:getLength()
	end
	return size
end


-- returns true if the polygon is convex
function polygon:isConvex()
	return love.math.isConvex(self:unpack())
end


-- returns true if the polygon is concave (not convex)
function polygon:isConcave()
	return not self:isConvex()
end


-- returns the total surface area of the polygon (assuming the shape is simple: no overlapping edges)
function polygon:getSurfaceArea()
	local tris = love.math.triangulate(self:unpack())
	local surfaceArea = 0
	local left
	local right
	local top
	local bottom
	for i = 1, #tris do
		left = math.min(tris[i][1], tris[i][3], tris[i][5])
		right = math.max(tris[i][1], tris[i][3], tris[i][5])
		top = math.max(tris[i][2], tris[i][4], tris[i][6])
		bottom = math.min(tris[i][2], tris[i][4], tris[i][6])
		surfaceArea = surfaceArea + ((right - left) * (top - bottom)) / 2
	end
	return surfaceArea
end


-- return an identical copy of the given polygon
function polygon:clone()
	return new(self:getPoints())
end


-- return all points making up the vector as a list of 'x1, y1, x2, y2, ...''
function polygon:unpack()
	local pointsArray = {}
	for i = 1, #self.Lines do
		table.insert(pointsArray, self.Lines[i].from.x)
		table.insert(pointsArray, self.Lines[i].from.y)
	end
	return unpack(pointsArray)
end


-- returns true if the given vector is inside the polygon (TODO: what about on the edge of the polygon?)
function polygon:encloses(v)
	assert(vector.isVector(v), "polygon:encloses(v) takes one argument of type <vector>, given: " .. tostring(v))
	-- vars
	local left = self.Lines[1].from.x
	local right = self.Lines[1].from.x
	local top = self.Lines[1].from.y
	local bottom = self.Lines[1].from.y
	local n = #self.Lines

	-- get bounding box edges
	for i = 2, n do
		if self.Lines[i].from.x < left then
			left = self.Lines[i].from.x
		elseif self.Lines[i].from.x > right then -- if x < left, then it can NEVER be x > right because left <= right
			right = self.Lines[i].from.x
		end
		if self.Lines[i].from.y < bottom then
			bottom = self.Lines[i].from.y
		elseif self.Lines[i].from.y > top then -- if x < bottom, then it can NEVER be x > top because bottom <= top
			top = self.Lines[i].from.y
		end
	end

	-- check if the point falls outside the bounding box (which is a very quick calculation and succeeds very often!)
	if v.x < left or v.x > right or v.y < bottom or v.y > top then
		return false
	end

	-- otherwise, check how many lines the point hits when drawing a line downwards. Even number = outside polygon, odd number = inside polygon
	local hits = 0
	local h
	for i = 1, n do
		local seg = self.Lines[i]
		left = math.min(seg.from.x, seg.to.x)
		right = math.max(seg.from.x, seg.to.x)
		bottom = math.min(seg.from.y, seg.to.y)
		top = math.max(seg.from.y, seg.to.y)
		if v.x >= left and v.x < right then -- one check is >= and the other is < to prevent edge-cases where you draw a line downwards on the border of two lines (which would then count as 2 hits!)
			if seg.from.x < seg.to.x then -- line goes from left to right
				h = seg:interpolation((v.x - left) / (right - left)).y
			else -- line goes from right to left
				h = seg:interpolation(1 - ((v.x - left) / (right - left))).y
			end
			if v.y >= h then -- if on the edge of the polygon, then count it as inside
				hits = hits + 1
			end
		end
	end
	if hits % 2 == 1 then
		return true -- only one line was hit, so you were inside the bounding box
	end
	return false
end




-- meta function to add a vector to a polygon
function polygon.__add(a, b)
	assert(isPolygon(a) and vector.isVector(b), "add: wrong argument types: (expected <polygon> and <vector>)")
	local points = a:getPoints()
	for i = 1, #points do
		points[i] = points[i] + b
	end
	return new(unpack(points))
end


-- meta function to subtract a vector from a polygon
function polygon.__sub(a, b)
	assert(isPolygon(a) and vector.isVector(b), "add: wrong argument types: (expected <polygon> and <vector>)")
	local points = a:getPoints()
	for i = 1, #points do
		points[i] = points[i] - b
	end
	return new(unpack(points))
end


-- meta function to change how polygons appear as string
function polygon:__tostring()
	local s = "{"
	for i = 1, #self.Lines do
		if i ~= #self.Lines then
			s = s .. tostring(self.Lines[i].from) .. ", "
		else
			s = s .. tostring(self.Lines[i].from)
		end
	end
	s = s .. "}"
	return s
end







-- pack up and return module
module.new = new
module.isPolygon = isPolygon
return setmetatable(module, {__call = function(_, ...) return new(...) end})

