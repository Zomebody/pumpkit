
----------------------------------------------------[[ == BASE OBJECTS == ]]----------------------------------------------------

local module = {}

local Camera3 = {}
Camera3.__index = Camera3
Camera3.__tostring = function(tab) return "{Camera3: " .. tostring(tab.Id) .. "}" end



----------------------------------------------------[[ == METHODS == ]]----------------------------------------------------

-- check if an object is a camera3
local function isCamera3(t)
	return getmetatable(t) == Camera3
end




function Camera3:moveTo(x, y, z, rx, ry, rz)
	-- init parameters
	local pos = nil
	local rot = nil
	if type(x) == "number" then
		pos = vector3(x, y, z)
		if type(rx) == "number" then
			rot = vector3(rx, ry, rz)
		elseif vector3.isVector3(rx) then
			rot = vector3(rx)
		else
			rot = nil
		end
	else
		pos = vector3(x)
		if type(y) == "number" then
			rot = vector3(y, z, rx)
		elseif vector3.isVector3(y) then
			rot = vector3(y)
		else
			rot = nil
		end
	end

	self.Position = pos
	if rot ~= nil then
		self.Rotation = rot
	end
end


-- move the camera in world-space
function Camera3:move(x, y, z)
	if type(x) == "number" then
		x = vector3(x, y, z)
	end

	self.Position = self.Position + x
end


-- move the camera in local space, so respecting the current rotation that is applied
function Camera3:moveLocal(x, y, z)
	if type(x) == "number" then
		x = vector3(x, y, z)
	end

	x = x:rotate(self.Rotation.x, self.Rotation.y, self.Rotation.z)
	self.Position = self.Position + x
end



-- rotate the camera in world-space, so along the world-axes instead of the local axes
function Camera3:rotate(rx, ry, rz)
	if type(rx) == "number" then
		rx = vector3(rx, ry, rz)
	end

	self.Rotation = self.Rotation + rx
end


-- rotate the camera in local space, so relative to the camera view instead of the world view
function Camera3:rotateLocal(rx, ry, rz)
	if type(rx) == "number" then
		rx = vector3(rx, ry, rz)
	end

	-- convert local to world
	rx = rx:rotate(self.Rotation.x, self.Rotation.y, self.Rotation.z)

	self.Rotation = self.Rotation + rx
end



local function new(x, y, z, rx, ry, rz)

	-- init parameters
	local pos = nil
	local rot = nil
	if type(x) == "number" then
		pos = vector3(x, y, z)
		if type(rx) == "number" then
			rot = vector3(rx, ry, rz)
		elseif vector3.isVector3(rx) then
			rot = vector3(rx)
		else
			rot = vector3(0, 0, 0)
		end
	else
		pos = vector3(x)
		if type(y) == "number" then
			rot = vector3(y, z, rx)
		elseif vector3.isVector3(y) then
			rot = vector3(y)
		else
			rot = vector3(0, 0, 0)
		end
	end

	local Obj = {
		["Position"] = pos;
		["Rotation"] = rot; -- rotation in radians
		["FieldOfView"] = math.rad(70); -- vertical FoV
	}

	return setmetatable(Obj, Camera3)
end



----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

-- pack up and return module
module.new = new
module.isCamera3 = isCamera3
return setmetatable(module, {__call = function(_, ...) return new(...) end})



