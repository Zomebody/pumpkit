
local module = {}

-- create the module
local vector4 = {}
vector4.__index = vector4

-- check if an object is a vector
local function isVector4(t)
	return getmetatable(t) == vector4
end


-- makes a new vector
local function new(x, y, z, w)
	if isVector4(x) then
		return setmetatable({x = x.x or 0, y = x.y or 0, z = x.z or 0, w = x.w or 0}, vector4)
	else
		return setmetatable({x = x or 0, y = y or 0, z = z or 0, w = w or 0}, vector4)
	end
end


-- set the values of the vector to something new
function vector4:set(x, y, z, w)
	if isVector4(x) then self.x, self.y, self.z, self.w = x.x, x.y, x.z, x.w; return self end
	self.x, self.y, self.z, self.w = x or self.x, y or self.y, z or self.z, w or self.w
	return self
end

-- replace the values of a vector with the values of another vector4
function vector4:replace(v)
	assert(isVector4(v), "replace: wrong argument type: (expected <vector4>, got "..type(v)..")")
	self.x, self.y, self.z, self.w = v.x, v.y, v.z, v.w
	return self
end

-- returns a copy of a vector4
function vector4:clone()
	return new(self.x, self.y, self.z, self.w)
end

-- get the magnitude of a vector4
function vector4:getMag()
	return math.sqrt(self.x^2 + self.y^2 + self.z^2 + self.w^2)
end


-- set the magnitude of a vector
function vector4:setMag(mag)
	self:norm()
	local v = self * mag
	self:replace(v)
	return self
end



-- meta function to make vectors negative
-- ex: (negative) -vector(5,6) is the same as vector(-5,-6)
function vector4.__unm(v)
	return new(-v.x, -v.y, -v.z, -v.w)
end

-- meta function to add vectors together
-- ex: (vector(5,6) + vector(6,5)) is the same as vector(11,11)
function vector4.__add(a, b)
	assert(isVector4(a) and isVector4(b), "add: wrong argument types: (expected <vector4> and <vector4>)")
	return new(a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w)
end

-- meta function to subtract vectors
function vector4.__sub(a, b)
	assert(isVector4(a) and isVector4(b), "sub: wrong argument types: (expected <vector4> and <vector4>)")
	return new(a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w)
end

-- meta function to multiply vectors
function vector4.__mul(a, b)
	if type(a) == 'number' then 
		return new(a * b.x, a * b.y, a * b.z, a * b.w)
	elseif type(b) == 'number' then
		return new(a.x * b, a.y * b, a.z * b, a.w * b)
	else
		assert(isVector4(a) and isVector4(b),  "mul: wrong argument types: (expected <vector4> or <number>)")
		return new(a.x * b.x, a.y * b.y, a.z * b.z, a.w * b.w)
	end
end

-- meta function to divide vectors
function vector4.__div(a, b)
	assert(isVector4(a) and type(b) == "number", "div: wrong argument types (expected <vector4> and <number>)")
	return new(a.x / b, a.y / b, a.z / b, a.w / b)
end

-- meta function to check if vectors have the same values
function vector4.__eq(a, b)
	assert(isVector4(a) and isVector4(b), "eq: wrong argument types (expected <vector4> and <vector4>)")
	return a.x == b.x and a.y == b.y and a.z == b.z and a.w == b.w
end


-- meta function to change how vectors appear as string
function vector4:__tostring()
	return "(" .. self.x .. ", " .. self.y .. ", " .. self.z .. "," .. self.w .. ")"
end

-- get the distance between two vectors
function vector4.dist(a, b)
	assert(isVector4(a) and isVector4(b), "dist: wrong argument types (expected <vector4> and <vector4>)")
	local dx = b.x - a.x
	local dy = b.y - a.y
	local dz = b.z - a.z
	local dw = b.w - a.w
	return math.sqrt(dx^2 + dy^2 + dz^2 + dw^2)
end

-- normalize the vector (give it a magnitude of 1)
function vector4:norm()
	local m = self:getMag()
	if m ~= 0 then
		self:replace(self / m)
	end
	return self
end

-- limit the vector to a certain magnitude
function vector4:limit(max)
	assert(type(max) == 'number', "limit: wrong argument type (expected <number>)")
	local m = self:getMag()
	if m > max then
		self:setMag(max)
	end
	return self
end




-- return x and y of vector as a regular array
function vector4:array()
	return {self.x, self.y, self.z, self.w}
end

-- return x and y of vector, unpacked from table
function vector4:unpack()
	return self.x, self.y, self.z, self.w
end


-- pack up and return module
module.new = new
module.isVector4 = isVector4
return setmetatable(module, {__call = function(_,...) return new(...) end})
