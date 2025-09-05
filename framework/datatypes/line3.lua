
local module = {}

-- create the module
local line3 = {}
line3.__index = line3

-- check if an object is a vector
local function isLine3(t)
	return getmetatable(t) == line3
end

-- makes a new vector
local function new(v1, v2)
	if isLine3(v1) then
		local Obj = {
			["from"] = vector3(v1.from);
			["to"] = vector3(v1.to);
		}
		return setmetatable(Obj, line3)
	elseif vector3.isVector3(v1) and vector3.isVector3(v2) then
		assert(v1 ~= v2, "line3.new(v1, v2) requires arguments v1 and v2 to be different vector3s.")
		return setmetatable({from = vector3(v1.x, v1.y, v1.z), to = vector3(v2.x, v2.y, v2.z)}, line3)
	else
		error("line3.new(v1, v2) only accepts two vector3s as arguments, or a line3 as v1.")
	end
end



function line3:closestTo(pos)
	local dir = self.to - self.from
	local length = dir:getMag()
	dir = dir:norm()
	
	local toPos = pos - self.from
	local projectionLength = toPos:dot(dir)
	
	if projectionLength < 0 then
		return self.from
	elseif projectionLength > length then
		return self.to
	else -- somewhere in between
		return self.from + dir * projectionLength
	end
end



-- magic math from ChatGPT don't ask me about it. I remember some of this from high school though
function line3:intersectSphere(pos, radius)
	local d = self.to - self.from
	local f = self.from - pos
	
	local a = d:dot(d)
	local b = 2 * f:dot(d)
	local c = f:dot(f) - radius^2
	
	local discriminant = b^2 - 4 * a * c
	
	if discriminant < 0 then
		return nil -- no intersection
	else
		discriminant = math.sqrt(discriminant)
		
		local t1 = (-b - discriminant) / (2 * a)
		local t2 = (-b + discriminant) / (2 * a)
		
		local intersection1 = self.from + d * t1
		local intersection2 = self.from + d * t2
		
		if discriminant == 0 then
			return intersection1 -- one intersection
		else
			return intersection1, intersection2 -- two intersections
		end
	end
end


-- Moller Trumbore implementation, returns intersection with 3d triangle or nil
function line3:intersectTriangle(v1, v2, v3)
	local direction = (self.to - self.from):setMag(1)

	-- use dot-product to check if parallel. If so, no intersection is found
	local edge1 = v2 - v1
	local edge2 = v3 - v1
	local perpendicular1 = direction:cross(edge2)
	local determinant = edge1:dot(perpendicular1)

	if math.abs(determinant) < 0.000001 then
		return nil
	end

	local detInv = 1 / determinant
	local delta = self.from - v1
	local u = detInv * delta:dot(perpendicular1) -- barycentric coordinate 1

	if u < 0 or u > 1 then
		return nil
	end

	local perpendicular2 = delta:cross(edge1)
	local v = detInv * direction:dot(perpendicular2) -- barycentric coordinate 2
	if v < 0 or u + v > 1 then
		return nil
	end

	-- calculate distance to intersection
	local t = detInv * edge2:dot(perpendicular2)
	if t < 0 or t > self:getLength() then -- intersection behind the ray
		return nil
	end
	
	local intersection = self.from + direction * t
	return intersection
end


-- returns a copy of a vector3
function line3:clone()
	return new(self)
end

-- get the magnitude of a vector3
function line3:getLength()
	return (self.to - self.from):getMag()
end


-- set the magnitude of a vector
function line3:getCenter()
	return (self.from + self.to) / 2
end


-- returns the vector going from the line's start to its end
function line3:toVector3()
	return self.to - self.from
end

-- return coordinates in array form
function line3:array()
	return {self.from.x, self.from.y, self.from.z, self.to.x, self.to.y, self.to.z}
end


-- return coordinates as a tuple
function line3:unpack()
	return self.from.x, self.from.y, self.from.z, self.to.x, self.to.y, self.to.z
end



-- meta function to check if line3s have the same values
function line3.__eq(a,b)
	assert(isLine3(a) and isLine3(b), "__eq: wrong argument types (expected <line3> and <line3>)")
	return a.from == b.from and a.to == b.to
end


-- meta function to add a vector3 to a line3
function line3.__add(a, b)
	assert(isLine3(a) and vector3.isVector3(b), "add: wrong argument types: (expected <line3> and <vector3>)")
	return new(a.from + b, a.to + b)
end


-- meta function to subtract a vector3 from a line3
function line3.__sub(a, b)
	assert(isLine3(a) and vector3.isVector3(b), "add: wrong argument types: (expected <line3> and <vector3>)")
	return new(a.from - b, a.to - b)
end

-- meta function to make the line3 negative
function line3.__unm(a)
	return new(-a.from, -a.to)
end


-- meta function to change how line3s appear as string
function line3:__tostring()
	return "{" .. tostring(self.from) .. ", " .. tostring(self.to) .. "}"
end


-- pack up and return module
module.new = new
module.isLine3 = isLine3
return setmetatable(module, {__call = function(_,...) return new(...) end})
