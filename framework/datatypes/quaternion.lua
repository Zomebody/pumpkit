
local module = {}

-- create the module
local quaternion = {}
quaternion.__index = quaternion

-- check if an object is a vector
local function isQuaternion(t)
	return getmetatable(t) == quaternion
end



-- makes a new quaternion
local function new(x, y, z, w)
	if isQuaternion(x) then
		return setmetatable({x = x.x or 0, y = x.y or 0, z = x.z or 0, w = x.w or 0}, quaternion)
	else
		return setmetatable({x = x or 0, y = y or 0, z = z or 0, w = w or 0}, quaternion)
	end
end




-- helper function for interpolate
local function lerp(a, b, t)
	return a + (b - a) * t
end

-- helper function for interpolate
local function slerp(q1, q2, t)
	local dot = q1.x * q2.x + q1.y * q2.y + q1.z * q2.z + q1.w * q2.w
	if dot < 0 then
		q2 = -q2
		dot = -dot
	end

	dot = math.min(1, math.max(-1, dot))
	local theta = math.acos(dot)
	local sinTheta = math.sin(theta)
	if sinTheta < 0.001 then
		return new(
			lerp(q1.x, q2.x, t),
			lerp(q1.y, q2.y, t),
			lerp(q1.z, q2.z, t),
			lerp(q1.w, q2.w, t)
		):norm()
	end

	-- interpolation weights
	local w1 = math.sin((1 - t) * theta) / sinTheta
	local w2 = math.sin(t * theta) / sinTheta

	return new(
		q1.x * w1 + q2.x * w2,
		q1.y * w1 + q2.y * w2,
		q1.z * w1 + q2.z * w2,
		q1.w * w1 + q2.w * w2
	):norm()
end



local function exp(v3)
	local angle = v3:getMag()
	if angle < 1e-6 then
		-- return identity
		return new(0, 0, 0, 1)
	else
		local axis = v3 / angle
		local sinHalfAngle = math.sin(angle / 2)
		local cosHalfAngle = math.cos(angle / 2)
		return new(
			axis.x * sinHalfAngle,
			axis.y * sinHalfAngle,
			axis.z * sinHalfAngle,
			cosHalfAngle
		)
	end
end



-- set the values of the quaternion to something new
function quaternion:set(x, y, z, w)
	if isQuaternion(x) then self.x, self.y, self.z, self.w = x.x, x.y, x.z, x.w; return self end
	self.x, self.y, self.z, self.w = x or self.x, y or self.y, z or self.z, w or self.w
	return self
end

-- replace the values of a quaternion with the values of another quaternion
function quaternion:replace(v)
	assert(isQuaternion(v), "replace: wrong argument type: (expected <quaternion>, got "..type(v)..")")
	self.x, self.y, self.z, self.w = v.x, v.y, v.z, v.w
	return self
end

-- returns a copy of a quaternion
function quaternion:clone()
	return new(self.x, self.y, self.z, self.w)
end

-- get the magnitude of a quaternion
function quaternion:getMag()
	return math.sqrt(self.x^2 + self.y^2 + self.z^2 + self.w^2)
end


-- set the magnitude of a quaternion
function quaternion:setMag(mag)
	self:norm()
	local v = self * mag
	self:replace(v)
	return self
end



function quaternion:inverse()
	return new(-self.x, -self.y, -self.z, self.w)
end


function quaternion:log()
	local v = vector3(self.x, self.y, self.z)
	local length = v:getMag()
	if length < 1e-6 then return vector3(0, 0, 0) end
	local theta = math.acos(self.w)
	return v:norm() * theta
end




-- meta function to make quaternions negative
function quaternion.__unm(v)
	return new(-v.x, -v.y, -v.z, -v.w)
end




local function multQuatVec3(q, v)
	local n1 = self.x * 2
	local n2 = self.y * 2
	local n3 = self.z * 2
	local n4 = self.x * n1
	local n5 = self.y * n2
	local n6 = self.z * n3
	local n7 = self.x * n2
	local n8 = self.x * n3
	local n9 = self.y * n3
	local n10 = self.w * n1
	local n11 = self.w * n2
	local n12 = self.w * n3
	local x = (((1 - (n5 + n6)) * v.x) + ((n7 - n12) * v.y)) + ((n8 + n11) * v.z)
	local y = (((n7 + n12) * v.x) + ((1 - (n4 + n6)) * v.y)) + ((n9 - n10) * v.z)
	local z = (((n8 - n11) * v.x) + ((n9 + n10) * v.y)) + ((1 - (n4 + n5)) * v.z)
	return vector3(x, y, z)
end

-- meta function to multiply quaternions
function quaternion.__mul(a, b)
	if type(a) == 'number' then 
		return new(a * b.x, a * b.y, a * b.z, a * b.w)
	elseif type(b) == 'number' then
		return new(a.x * b, a.y * b, a.z * b, a.w * b)
	elseif vector3.isVector3(a) then
		return multQuatVec3(b, a)
	elseif vector3.isVector3(b) then
		return multQuatVec3(a, b)
	else
		-- https://github.com/thegrb93/StarfallEx/blob/master/lua/starfall/libs_sh/quaternion.lua#L60
		local w1, x1, y1, z1 = a.w, a.x, a.y, a.z
		local w2, x2, y2, z2 = b.w, b.x, b.y, b.z
		return new(
			w1*x2 + x1*w2 + y1*z2 - z1*y2, -- x
			w1*y2 - x1*z2 + y1*w2 + z1*x2, -- y
			w1*z2 + x1*y2 - y1*x2 + z1*w2, -- z
			w1*w2 - x1*x2 - y1*y2 - z1*z2  -- w
		)
	end
end

-- meta function to divide quaternions
function quaternion.__div(a, b)
	assert(isQuaternion(a) and type(b) == "number", "div: wrong argument types (expected <quaternion> and <number>)")
	return new(a.x / b, a.y / b, a.z / b, a.w / b)
end


-- meta function to check if quaternions have the same values
function quaternion.__eq(a, b)
	assert(isQuaternion(a) and isQuaternion(b), "eq: wrong argument types (expected <quaternion> and <quaternion>)")
	return a:dot(b) > 0.999999 -- two different quaterions could achieve the same rotation with different values!
end


-- meta function to change how quaternions appear as string
function quaternion:__tostring()
	return "(" .. self.x .. ", " .. self.y .. ", " .. self.z .. ", " .. self.w .. ")"
end



function quaternion:dot(v)
	assert(isQuaternion(v), "dot: wrong argument type (expected <quaternion>, got "..type(v)..")")
	return self.x * v.x + self.y * v.y + self.z * v.z + self.w * v.w
end

-- normalize the quaternion (give it a magnitude of 1)
function quaternion:norm()
	local m = self:getMag()
	if m ~= 0 then
		self:set(self.x / m, self.y / m, self.z / m, self.w / m)
	end
	return self
end





-- return x and y of quaternion as a regular array
function quaternion:array()
	return {self.x, self.y, self.z, self.w}
end

-- return x and y of quaternion, unpacked from table
function quaternion:unpack()
	return self.x, self.y, self.z, self.w
end


-- pack up and return module
module.new = new
module.isQuaternion = isQuaternion
module.exp = exp -- exponential mapping, i.e. converting angular velocity (axis-angle form) into a unit quaternion
module.slerp = slerp
return setmetatable(module, {__call = function(_,...) return new(...) end})
