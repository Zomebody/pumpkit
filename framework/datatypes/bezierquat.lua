
local module = {}
-- create the module
local bezierquat = {}
bezierquat.__index = bezierquat

local new


-- check if an object is a bezierquat
local function isBezierquat(t)
	return getmetatable(t) == bezierquat
end

-- returns a copy of a bezier
function bezier:clone()
	return new(self.Quaternions)
end


-- return coordinates in array form
function bezier:array()
	return {self.Quaternions:unpack()}
end


-- return coordinates as a tuple
function bezier:unpack()
	return self.Quaternions:unpack()
end




function bezierquat:deCasteljau(quaternions, t)
	while #quaternions > 1 do
		local newQuats = {}
		for i = 1, #quaternions - 1 do
			newQuats[i] = quaternion.slerp(quaternions[i], quaternions[i + 1], t) -- key difference for quaternion beziers is to use a slerp instead of a lerp like regular beziers
		end
		quaternions = newQuats
	end
	return quaternions[1]
end



function bezierquat:getAngularVelocityAt(a, t)
	assert(type(a) == "number" and a >= 0 and a <= 1, "bezierquat:getAngularVelocityAt(a, t) expects 'a' between 0 and 1.")
	assert(type(t) == "number" and t > 0, "bezierquat:getAngularVelocityAt(a, t) expects positive time step t.")

	local q1 = self:getQuaternion(a)
	local q2 = self:getQuaternion(math.min(1, a + 0.001))
	local delta = q2 * q1:inverse()
	local omega = delta:log() / (0.001 * t)
	return omega
end



function bezierquat:getQuaternion(a)
	assert(type(a) == "number" and a >= 0 and a <= 1, "bezierquat:getQuaternion(a) expects argument a to be a number between 0 and 1.")
	return self:deCasteljau(self.Quaternions, a)
end




-- makes a new bezierquat
local new = function(...)
	local quats = {...}
	assert(#quats > 0, "bezierquat.new(...) expects at least one argument, given are 0 arguments.")
	if type(quats[1]) == "table" then
		quats = quats[1]
	end


	local Obj = {
		["Quaternions"] = {};
	}

	for i = 1, #quats do
		assert(quaternion.isQuaternion(quats[i]), "bezierquat.new(...) expects all inputs to be quaternions.")
		Obj.Quaternions[i] = quaternion(quats[i])
	end


	return setmetatable(Obj, bezierquat)
end






-- pack up and return module
module.new = new
module.isBezierquat = isBezierquat
return setmetatable(module, {__call = function(_,...) return new(...) end})


