
local module = {}

-- create the module
local vector3 = {}
vector3.__index = vector3

-- check if an object is a vector
local function isVector3(t)
	return getmetatable(t) == vector3
end

-- get a random function from Love2d or base lua, in that order.
local rand = math.random
if love and love.math then rand = love.math.random end

-- makes a new vector
local function new(x, y, z)
	if isVector3(x) then
		return setmetatable({x = x.x or 0, y = x.y or 0, z = x.z or 0}, vector3)
	else
		return setmetatable({x = x or 0, y = y or 0, z = z or 0}, vector3)
	end
end



-- makes a vector with a random direction
local function random()
	local theta = math.random() * 2 * math.pi  -- random angle from 0 to 2 pi
	local phi = math.acos(2 * math.random() - 1)  -- random angle for acos to distribute points evenly over the sphere
	local x = math.sin(phi) * math.cos(theta)
	local y = math.sin(phi) * math.sin(theta)
	local z = math.cos(phi)
	return new(x, y, z)
end

-- set the values of the vector to something new
function vector3:set(x, y, z)
	if isVector3(x) then self.x, self.y, self.z = x.x, x.y, x.z;return self end
	self.x, self.y, self.z = x or self.x, y or self.y, z or self.z
	return self
end

-- replace the values of a vector with the values of another vector
function vector3:replace(v)
	assert(isVector3(v), "replace: wrong argument type: (expected <vector3>, got "..type(v)..")")
	self.x, self.y, self.z = v.x, v.y, v.z
	return self
end

-- returns a copy of a vector
function vector3:clone()
	return new(self.x, self.y, self.z)
end

-- get the magnitude of a vector
function vector3:getMag()
	return math.sqrt(self.x^2 + self.y^2 + self.z^2)
end



-- set the magnitude of a vector
function vector3:setMag(mag)
	self:norm()
	local v = self * mag
	self:replace(v)
	return self
end



-- meta function to make vectors negative
-- ex: (negative) -vector(5,6) is the same as vector(-5,-6)
function vector3.__unm(v)
	return new(-v.x, -v.y, -v.z)
end

-- meta function to add vectors together
-- ex: (vector(5,6) + vector(6,5)) is the same as vector(11,11)
function vector3.__add(a, b)
	assert(isVector(a) and isVector(b), "add: wrong argument types: (expected <vector3> and <vector3>)")
	return new(a.x + b.x, a.y + b.y, a.z + b.z)
end

-- meta function to subtract vectors
function vector3.__sub(a, b)
	assert(isVector3(a) and isVector3(b), "sub: wrong argument types: (expected <vector3> and <vector3>)")
	return new(a.x - b.x, a.y - b.y, a.z - b.z)
end

-- meta function to multiply vectors
function vector3.__mul(a, b)
	if type(a) == 'number' then 
		return new(a * b.x, a * b.y, a * b.z)
	elseif type(b) == 'number' then
		return new(a.x * b, a.y * b, a.z * b)
	else
		assert(isVector3(a) and isVector3(b),  "mul: wrong argument types: (expected <vector3> or <number>)")
		return new(a.x * b.x, a.y * b.y, a.z * b.z)
	end
end

-- meta function to divide vectors
function vector3.__div(a, b)
	assert(isVector3(a) and type(b) == "number", "div: wrong argument types (expected <vector3> and <number>)")
	return new(a.x / b, a.y / b, a.z / b)
end

-- meta function to check if vectors have the same values
function vector3.__eq(a, b)
	assert(isVector3(a) and isVector3(b), "eq: wrong argument types (expected <vector3> and <vector3>)")
	return a.x == b.x and a.y == b.y and a.z == b.z
end

-- meta function to change how vectors appear as string
-- ex: print(vector(2,8)) - this prints '(2,8)'
function vector3:__tostring()
	return "(" .. self.x .. ", " .. self.y .. ", " .. self.z .. ")"
end

-- get the distance between two vectors
function vector3.dist(a, b)
	assert(isVector3(a) and isVector3(b), "dist: wrong argument types (expected <vector3> and <vector3>)")
	local dx = b.x - a.x
	local dy = b.y - a.y
	local dz = b.z - a.z
	return math.sqrt(dx^2 + dy^2 + dz^2)
end

-- return the dot product of the vector
function vector3:dot(v)
	assert(isVector3(v), "dot: wrong argument type (expected <vector3>, got "..type(v)..")")
	return self.x * v.x + self.y * v.y + self.z * v.z
end


-- normalize the vector (give it a magnitude of 1)
function vector3:norm()
	local m = self:getMag()
	if m ~= 0 then
		self:replace(self / m)
	end
	return self
end

-- limit the vector to a certain magnitude
function vector3:limit(max)
	assert(type(max) == 'number', "limit: wrong argument type (expected <number>)")
	local mSq = self:magSq()
	if mSq > max^2 then
		self:setMag(max)
	end
	return self
end

-- Clamp each axis between max and min's corresponding axis
function vector3:clamp(min3, max3)
	assert(isVector(min) and isVector(max), "clamp: wrong argument type (expected <vector3> and <vector3>)")
	local x = math.min( math.max( self.x, min.x ), max.x )
	local y = math.min( math.max( self.y, min.y ), max.y )
	local z = math.min( math.max( self.z, min.z ), max.z )
	self:set(x, y, z)
	return self
end


-- returns the smallest angle between the two vectors
function vector3:angleDiff(v)
	assert(isVector3(v), "angleDiff: wrong argument type (expected <vector3>, got " .. type(v) .. ")")
	local dot = self:dot(v)
	local mag1 = self:getMag()
	local mag2 = v:getMag()
	local cosine = dot / (mag1 * mag2)
	cosine = math.max(-1, math.min(cosine, 1)) -- Clamp cosine between -1 and 1 to avoid errors due to floating-point precision
	return math.acos(cosine)
end




-- return x and y of vector as a regular array
function vector3:array()
	return {self.x, self.y, self.z}
end

-- return x and y of vector, unpacked from table
function vector3:unpack()
	return self.x, self.y, self.z
end


-- pack up and return module
module.new = new
module.random = random
module.isVector3 = isVector3
return setmetatable(module, {__call = function(_,...) return new(...) end})
