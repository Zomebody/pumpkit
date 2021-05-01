
local getpath = require("framework.getpath")
local vector = require(getpath(..., "vector"))

local module = {}
-- create the module
local line = {}
line.__index = line

local new


-- check if an object is a line
local function isLine(t)
	return getmetatable(t) == line
end


-- replace the values of a line with the values of another line
function line:replace(l)
	assert(isLine(l), "replace: wrong argument type: (expected <line>, got " .. type(l) .. ")")
	self.from.x = l.from.x
	self.from.y = l.from.y
	self.to.x = l.to.x
	self.to.y = l.to.y
	self.normal = (self.to - self.from):rotate(math.pi / 2):norm()
	return self
end


-- returns a copy of a line
function line:clone()
	return new(self.from, self.to)
end


-- returns the length of a line
function line:getLength()
	return (self.to - self.from):getmag()
end


-- returns the vector going from the line's start to its end
function line:toVector()
	return self.to - self.from
end


-- returns the center of a line
function line:getCenter()
	return (self.from + self.to) / 2
end


-- returns the interpolated position on the line at progress *a* where 0 <= a <= 1
function line:interpolation(a)
	return self.from + (self.to - self.from) * a
end

-- returns the vector on the line that is closest to vector v. If inf == true, treat the line as if it extends infinitely on both sides
-- https://stackoverflow.com/questions/3120357/get-closest-Vector-to-a-line
function line:closestTo(v, inf)
	local vecAP = vector.new(v.x - self.from.x, v.y - self.from.y)
	local vecAB = vector.new(self.to.x - self.from.x, self.to.y - self.from.y)
	local magnitudeAB = vecAB.x^2 + vecAB.y^2
	local productABAP = (vecAP.x * vecAB.x) + (vecAP.y * vecAB.y)
	local distance = productABAP / magnitudeAB
	if distance < 0 and inf ~= true then
		return vector.new(self.from.x, self.from.y)
	elseif distance > 1 and inf ~= true then
		return vector.new(self.to.x, self.to.y)
	else
		return vector.new(self.from.x + vecAB.x * distance, self.from.y + vecAB.y * distance)
	end
end


-- set the positions of the line to new vectors
function line:moveTo(from, to)
	if isLine(from) then
		self.from.x = from.from.x
		self.from.y = from.from.y
		self.to.x = from.to.x
		self.to.y = from.to.y
		return
	end
	if from ~= nil then
		self.from.x = from.x
		self.from.y = from.y
	end
	if to ~= nil then
		self.to.x = to.x
		self.to.y = to.y
	end
	self.normal = (self.to - self.from):rotate(math.pi / 2):norm()
	return self
end


-- moves the line in a certain direction
function line:shift(x, y)
	if vector.isVector(x) then
		self.from:set(self.from.x + x.x, self.from.y + x.y)
		self.to:set(self.to.x + x.x, self.to.y + x.y)
	else
		self.from:set(self.from.x + x, self.from.y + y)
		self.to:set(self.to.x + x, self.to.y + y)
	end
end


-- returns the distance between the point on the line closest to vector v, and v itself. If inf == true, treat the line as if it extends infinitely on both sides
function line:disTo(v, inf)
	local closestPoint = self:closestTo(v, inf)
	return v:dist(closestPoint)
end


-- returns a vector describing the point at which this line intersects line lin2
-- http://www.jeffreythompson.org/collision-detection/line-line.php
function line:intersect(lin2)
	local uA = ((lin2.to.x - lin2.from.x) * (self.from.y - lin2.from.y) - (lin2.to.y - lin2.from.y) * (self.from.x - lin2.from.x)) / ((lin2.to.y - lin2.from.y) * (self.to.x - self.from.x) - (lin2.to.x - lin2.from.x) * (self.to.y - self.from.y))
	local uB = ((self.to.x - self.from.x) * (self.from.y - lin2.from.y) - (self.to.y - self.from.y) * (self.from.x - lin2.from.x)) / ((lin2.to.y - lin2.from.y) * (self.to.x - self.from.x) - (lin2.to.x - lin2.from.x) * (self.to.y - self.from.y))
	-- if uA and uB are between 0 to 1, lines are colliding
	if uA >= 0 and uA <= 1 and uB >= 0 and uB <= 1 then
		local interX = self.from.x + (uA * (self.to.x - self.from.x));
		local interY = self.from.y + (uA * (self.to.y - self.from.y));
		return vector.new(interX, interY)
	end
	return nil
end


-- returns a vector describing the point at which this line intersects the circle at position v with radius r
function line:intersectCircle(v, r)
	local d = self.to - self.from -- direction vector of ray, from start to end
	local f = self.from - v -- vector from center of circle to start of ray
	local a = d:dot(d)
	local b = f:dot(d) * 2
	local c = f:dot(f) - r^2
	local discriminant = (b * b) - (4 * a * c)
	if discriminant < 0 then
		return nil
	else
		discriminant = math.sqrt(discriminant)
		local t1 = (-b - discriminant) / (2 * a)
		local t2 = (-b + discriminant) / (2 * a)
		if t1 >= 0 and t1 <= 1 then -- hit the circle from outside
			return self.from + d * t1, 1
		elseif t2 >= 0 and t2 <= 1 then -- hit the circle from inside
			return self.from + d * t2, -1
		end
		-- if neither of above, the line segment either falls short, is past the circle, or is fully inside the circle
	end
	return nil
end


-- returns true if this line intersects line arg1, or in the case of a circle, intersects the circle at vector arg1 with radius arg2
function line:intersects(arg1, arg2)
	if isLine(arg1) then
		return self:intersect(arg1) ~= nil
	else
		return self:intersectCircle(arg1, arg2) ~= nil
	end
end


-- returns true if the line separates the vectors v1 and v2, so i.e. if they are on other sides of the line
function line:separates(v1, v2)
	local d1 = (self.to.x - self.from.x) * (v1.y - self.from.y) - (self.to.y - self.from.y) * (v1.x - self.from.x)
	local d2 = (self.to.x - self.from.x) * (v2.y - self.from.y) - (self.to.y - self.from.y) * (v2.x - self.from.x)
	if d1 == 0 or d2 == 0 or ((d1 > 0 and d2 < 0) or (d1 < 0 and d2 > 0)) then
		return true
	end
	return false
end


-- repositions 'to' to be a position onto the line such that (line:len()) returns mag
function line:setMag(mag)
	self.to = self.from + (self.to - self.from):setMag(mag)
	return self
end


-- returns two lines parallel to the line segment. They're positioned to the left and right exactly *dis* units away
function line:getTwoParallels(dis)
	local perpendicular = (self.to - self.from):rotate(math.pi / 2):setMag(dis)
	return new(self.from + perpendicular, self.to + perpendicular), new(self.from - perpendicular, self.to - perpendicular)
end


-- meta function to check if lines have the same values
function line.__eq(a,b)
	assert(isLine(a) and isLine(b), "__eq: wrong argument types (expected <line> and <line>)")
	return a.from == b.from and a.to == b.to
end


-- meta function to change how lines appear as string
-- ex: print(vector(2,8)) - this prints '(2,8)'
function line:__tostring()
	return "{" .. self.from .. ", " .. self.to .. "}"
end


-- return coordinates in array form
function line:array()
	return {self.from.x, self.from.y, self.to.x, self.to.y}
end


-- return coordinates as a tuple
function line:unpack()
	return self.from.x, self.from.y, self.to.x, self.to.y
end


-- makes a new line
new = function(from, to, x2, y2)
	if type(from) == "number" then
		from = vector(from, to)
		to = vector(x2, y2)
	else
		from = (from == nil) and (vector.new()) or (from:clone())
		to = (to == nil) and (vector.new()) or (to:clone())
	end
	local Obj = {
		["from"] = from;
		["to"] = to;
		["normal"] = (to - from):rotate(math.pi / 2):norm()
	}
	return setmetatable(Obj, line)
end



-- pack up and return module
module.new = new
module.isLine = isLine
return setmetatable(module, {__call = function(_,...) return new(...) end})


