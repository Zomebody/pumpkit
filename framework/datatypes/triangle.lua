
local module = {}

local triangle = {}
triangle.__index = triangle


-- check if an object is a triangle
local function isTriangle(t)
	return getmetatable(t) == triangle
end


-- create a new line object, which contains a list of line objects describing the shape of the triangle
local function new(v1, v2, v3) -- list of points
	if isTriangle(v1) then
		return new(unpack(v1:getPoints()))
	else -- arguments are vectors
		local tri = {
			["Line1"] = line2(v1, v2);
			["Line2"] = line2(v2, v3);
			["Line3"] = line2(v3, v1);
		}
		return setmetatable(tri, triangle)
	end
end


-- returns a copy of all points making up the triangle
function triangle:getPoints()
	return {vector2(self.Line1.from), vector2(self.Line2.from), vector2(self.Line3.from)}
end


function triangle:shift(x, y)
	self.Line1:shift(x, y)
	self.Line2:shift(x, y)
	self.Line3:shift(x, y)
end


-- get the total circumference length of the triangle
function triangle:getPerimeter()
	return self.Line1:getLength() + self.Line2:getLength() + self.Line3:getLength()
end


-- returns the total surface area of the triangle using Heron's formula
function triangle:getSurfaceArea()
	local a = self.Line1:getLength()
	local b = self.Line2:getLength()
	local c = self.Line3:getLength()
	local sp = (a + b + c) / 2 -- sp = semi-perimeter
	return math.sqrt(sp * (sp - a) * (sp - b) * (sp - c))
end


-- return an identical copy of the given triangle
function triangle:clone()
	return new(self.Line1.from, self.Line2.from, self.Line3.from)
end


-- return all points making up the vector as a list of 'x1, y1, x2, y2, ...''
function triangle:unpack()
	return self.Line1.from.x, self.Line1.from.y, self.Line2.from.x, self.Line2.from.y, self.Line3.from.x, self.Line3.from.y
end


-- TODO: this calls encloses() and closestTo() but closestTo() also calls encloses() again. That's kind of inefficient don't you think?
-- return the distance from the given vector to the closest point on the triangle
function triangle:dist(vec)
	assert(vector2.isVector2(vec), "triangle:dist(vec) expects argument 'vec' to be of type <vector2>, given: " .. tostring(vec))
	if self:encloses(vec) then
		return 0
	end
	local closestPoint = self:closestTo(vec)
	return closestPoint:dist(vec)
end


-- return the location on the triangle closest to the given vector
function triangle:closestTo(vec)
	assert(vector2.isVector2(vec), "triangle:closestTo(vec) expects argument 'vec' to be of type <vector2>, given: " .. tostring(vec))
	if self:encloses(vec) then
		return vector2(vec)
	end
	local dis1 = self.Line1:dist(vec)
	local dis2 = self.Line2:dist(vec)
	local dis3 = self.Line3:dist(vec)
	if dis1 < dis2 and dis1 < dis3 then
		return self.Line1:closestTo(vec)
	elseif dis2 < dis3 then
		return self.Line2:closestTo(vec)
	else
		return self.Line3:closestTo(vec)
	end
end


-- returns true if the given vector is inside the triangle (TODO: what about on the edge of the triangle?)
function triangle:encloses(v)
	assert(vector2.isVector2(v), "triangle:encloses(v) takes one argument of type <vector>, given: " .. tostring(v))
	-- calculate barycentric coordinates
	local v1 = self.Line1.from
	local v2 = self.Line2.from
	local v3 = self.Line3.from
	local detT = (v2.y - v3.y) * (v1.x - v3.x) + (v3.x - v2.x) * (v1.y - v3.y)
	local alpha = ((v2.y - v3.y) * (v.x - v3.x) + (v3.x - v2.x) * (v.y - v3.y)) / detT
	local beta = ((v3.y - v1.y) * (v.x - v3.x) + (v1.x - v3.x) * (v.y - v3.y)) / detT
	local gamma = 1 - alpha - beta

	-- check if the point is inside the triangle
	return alpha >= 0 and beta >= 0 and gamma >= 0
end



function triangle:intersectLine(l, margin) -- margin argument should normally be used because floating points are a problem :<
	if margin == nil then
		margin = 0.1^8
	end
	assert(line2.isLine2(l), "triangle:intersectLine(l) takes one argument of type <line2>, given: " .. tostring(v))

	-- try to have the line intersect all 3 sides of the triangle and store the intersection in an array
	local intersections = {}
	-- if no intersection takes place, intersect() returns nil, meaning nothing is added to the array
	table.insert(intersections, self.Line1:intersect(l))
	table.insert(intersections, self.Line2:intersect(l))
	table.insert(intersections, self.Line3:intersect(l))
	
	if #intersections == 1 then -- you intersected only one of the lines, so you went from inside the triangle to outside, or from outside the triangle to inside!
		return intersections[1]
	elseif #intersections == 2 then
		-- there is an edge-case where you hit *exactly* the corner of the triangle, in which case there are two intersections counted
		-- if that happens, compare if exactly either the starting point or end point is inside the triangle, in which case there was only really one intersection point
		local startEnclosed = self:encloses(l.from)
		local endEnclosed = self:encloses(l.to)
		if startEnclosed == endEnclosed then -- you pierced through exactly the corner, so return both points
			if intersections[1]:dist(l.from) < intersections[2]:dist(l.from) then
				return intersections[1], intersections[2]
			else
				return intersections[2], intersections[1]
			end
		else -- only one intersection took place, i.e. you went from outside the triangle to inside the triangle (or the other way around) and hit the exact corner doing so
			return intersections[1]
		end
	elseif #intersections == 3 then -- three points only ever happens when you hit at least one corner exactly! That means at least two of the points are the exact same location
		-- it also means you pierced through the triangle, going from outside to inside back to outside the triangle
		-- so all that's needed now is to find one duplicate position, remove it, then return the other two positions (in the right order)
		if intersections[2]:dist(intersections[3]) < margin then -- if 2 and 3 are the same, that means that point 1 is different from both!
			if intersections[1]:dist(l.from) < intersections[2]:dist(l.from) then
				return intersections[1], intersections[2]
			else
				return intersections[2], intersections[1]
			end
		else
			if intersections[2]:dist(l.from) < intersections[3]:dist(l.from) then
				return intersections[2], intersections[3]
			else
				return intersections[3], intersections[2]
			end
		end
	end
	return nil
end



function triangle:circumcenter()
	local v1 = self.Line1.from
	local v2 = self.Line2.from
	local v3 = self.Line3.from

	local d = 2 * (v1.x * (v2.y - v3.y) + v2.x * (v3.y - v1.y) + v3.x * (v1.y - v2.y))

	-- if d=0, ux and uy will be nan. Happens if the triangle has a volume of 0 (it's a line)
	if d < 0.00000001 then
		-- return the center of the longest line, and its diameter / 2
		local l1, l2, l3 = self.Line1:getLength(), self.Line2:getLength(), self.Line3:getLength()
		if l1 > l2 and l1 > l3 then
			return self.Line1:getCenter(), l1 / 2
		elseif l2 > l3 then
			return self.Line2:getCenter(), l2 / 2
		else
			return self.Line3:getCenter(), l3 / 2
		end
	end

	local ux = ((v1.x^2 + v1.y^2) * (v2.y - v3.y) + (v2.x^2 + v2.y^2) * (v3.y - v1.y) + (v3.x^2 + v3.y^2) * (v1.y - v2.y)) / d
	local uy = ((v1.x^2 + v1.y^2) * (v3.x - v2.x) + (v2.x^2 + v2.y^2) * (v1.x - v3.x) + (v3.x^2 + v3.y^2) * (v2.x - v1.x)) / d

	local center = vector2(ux, uy)
	return vector2(ux, uy), center:dist(self.Line1.from)
end




-- meta function to add a vector to a triangle
function triangle.__add(a, b)
	assert(isTriangle(a) and vector2.isVector2(b), "add: wrong argument types: (expected <triangle> and <vector2>)")
	local points = a:getPoints()
	for i = 1, #points do
		points[i] = points[i] + b
	end
	return new(unpack(points))
end


-- meta function to subtract a vector from a triangle
function triangle.__sub(a, b)
	assert(isTriangle(a) and vector2.isVector2(b), "add: wrong argument types: (expected <triangle> and <vector2>)")
	local points = a:getPoints()
	for i = 1, #points do
		points[i] = points[i] - b
	end
	return new(unpack(points))
end


-- meta function to change how triangles appear as string
function triangle:__tostring()
	return "{triangle: " .. tostring(self.Line1.from) .. ", " .. tostring(self.Line2.from) .. ", " .. tostring(self.Line3.from) .. "}"
end







-- pack up and return module
module.new = new
module.isTriangle = isTriangle
return setmetatable(module, {__call = function(_, ...) return new(...) end})

