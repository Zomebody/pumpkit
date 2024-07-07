
----------------------------------------------------[[ == BASE OBJECTS == ]]----------------------------------------------------

local module = {
	["TotalCreated"] = 0;
	["AllCameras"] = {}; -- list of all cameras that have been created
}

local Camera = {}
Camera.__index = Camera
Camera.__tostring = function(tab) return "{Camera: " .. tostring(tab.Id) .. "}" end



----------------------------------------------------[[ == HELPER FUNCTIONS == ]]----------------------------------------------------

local function rotateVec3(v, rotation)
	-- apply yaw
	local cy = math.cos(rotation.y)
	local sy = math.sin(rotation.y)
	local x1 = cy * v.x + sy * v.z
	local z1 = cy * v.z - sy * v.x
	local y1 = v.y

	-- apply pitch
	local cx = math.cos(rotation.x)
	local sx = math.sin(rotation.x)
	local y2 = cx * y1 - sx * z1
	local z2 = sx * y1 + cx * z1
	local x2 = x1

	-- apply roll
	local cz = math.cos(rotation.z)
	local sz = math.sin(rotation.z)
	local x3 = cz * x2 - sz * y2
	local y3 = sz * x2 + cz * y2
	local z3 = z2

	return vector3(x3, y3, z3)
end



----------------------------------------------------[[ == METHODS == ]]----------------------------------------------------

-- check if an object is a camera3
local function isCamera3(t)
	return getmetatable(t) == Camera3
end



function Camera:move(x, y, z)
	if type(x) == "number" then
		x = vector3(x, y, z)
	end

	self.Position = self.Position + x
end



function Camera:moveTo(x, y, z, rx, ry, rz)
	-- init parameters
	local pos = nil
	local rot = nil
	if type(x) == "number" then
		pos = vector3(x, y, z)
		if type(rx) == "number" then
			rot = vector3(rx, ry, rz)
		else
			rot = vector3(rx)
		end
	else
		pos = vector3(x)
		if type(y) == "number" then
			rot = vector3(y, z, rx)
		else
			rot = vector3(y)
		end
	end

	self.Position = pos
	self.Rotation = rot
end



function Camera:moveLocal(x, y, z)
	if type(x) == "number" then
		x = vector3(x, y, z)
	end

	local rotatedTranslation = rotateVec3(vector3(x), self.Rotation)
	self.Position = self.Position + rotatedTranslation
end



function Camera:rotate(rx, ry, rz)
	if type(x) == "number" then
		rx = vector3(rx, ry, rz)
	end

	self.Rotation = self.Rotation + vector3(rx)
end



function Camera:rotateLocal(rx, ry, rz)
	if type(x) == "number" then
		rx = vector3(rx, ry, rz)
	end

	local rotatedRotation = rotateVec3(vector3(rx), self.Rotation)
	self.Rotation = self.Rotation + rotatedRotation
end



local function new(x, y, z, rx, ry, rz)

	-- init parameters
	local pos = nil
	local rot = nil
	if type(x) == "number" then
		pos = vector3(x, y, z)
		if type(rx) == "number" then
			rot = vector3(rx, ry, rz)
		else
			rot = vector3(rx)
		end
	else
		pos = vector3(x)
		if type(y) == "number" then
			rot = vector3(y, z, rx)
		else
			rot = vector3(y)
		end
	end

	local Obj = {
		["Position"] = pos;
		["Rotation"] = rot;
		["FieldOfView"] = math.rad(70); -- vertical FoV
	}

	return setmetatable(Obj, Camera3)
end



----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

-- pack up and return module
module.new = new
module.isCamera3 = isCamera3
return setmetatable(module, {__call = function(_, ...) return new(...) end})



