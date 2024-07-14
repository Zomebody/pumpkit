
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




function Camera3:moveTo(x, y, z)
	local pos = nil
	if type(x) == "number" then
		pos = vector3(x, y, z)
	elseif vector3.isVector3(x) then
		pos = x
	end
	self.Position = pos or self.Position
end


-- move the camera in world-space
function Camera3:move(x, y, z)
	local displacement = nil
	if type(x) == "number" then
		displacement = vector3(x, y, z)
	elseif vector3.isVector3(x) then
		displacement = x
	end

	self.Position = self.Position + displacement
end


-- move the camera in local space, so respecting the current rotation that is applied
function Camera3:moveLocal(x, y, z, order)
	local displacement = nil
	if type(x) == "number" then
		displacement = vector3(x, y, z)
	elseif vector3.isVector3(x) then
		displacement = x
	end

	local rotationMatrix = self:getRotationMatrix(order)
	local v4 = vector4(displacement.x, displacement.y, displacement.z, 0)
	local transformedDisplacement = rotationMatrix * v4
	self.Position = self.Position + vector3(transformedDisplacement.x, transformedDisplacement.y, transformedDisplacement.z)
end



-- rotate the camera in world-space, so along the world-axes instead of the local axes
function Camera3:rotate(rx, ry, rz)
	local rotation = nil
	if type(rx) == "number" then
		rotation = vector3(rx, ry, rz)
	elseif vector3.isVector3(rx) then
		rotation = rx
	end
	self.Rotation = self.Rotation + rotation
end


-- rotate the camera in local space, so relative to the camera view instead of the world view
--[[
function Camera3:rotateLocal(rx, ry, rz, order)
	if type(rx) == "number" then
		local localRotation = vector3(rx, ry, rz)
		local rotationMatrix = self:getRotationMatrix(order)
		local localRotationMatrix = matrix4.fromEuler(localRotation, order) -- or 'XYZ', 'ZYX', etc. depending on your needs
		local newRotationMatrix = rotationMatrix * localRotationMatrix

		self.Rotation = newRotationMatrix:toEuler(order) -- Convert back to Euler angles
	elseif vector3.isVector3(rx) then
		local rotationMatrix = self:getRotationMatrix(order)
		local localRotationMatrix = matrix4.fromEuler(rx, order) -- or 'XYZ', 'ZYX', etc. depending on your needs
		local newRotationMatrix = rotationMatrix * localRotationMatrix

		self.Rotation = newRotationMatrix:toEuler(order) -- Convert back to Euler angles
	end
end
]]


function Camera3:getRotationMatrix(order)
	return matrix4.fromEuler(self.Rotation, order) -- or 'XYZ', 'ZYX', etc. depending on your needs
end


local function new(x, y, z)
	-- init parameters
	local pos = nil
	if type(x) == "number" then
		pos = vector3(x, y, z)
	else
		pos = vector3(x)
	end

	local Obj = {
		["Position"] = pos;
		["Rotation"] = vector3(0, 0, 0); -- rotation in radians
		["FieldOfView"] = math.rad(70); -- vertical FoV
	}

	return setmetatable(Obj, Camera3)
end



----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

-- pack up and return module
module.new = new
module.isCamera3 = isCamera3
return setmetatable(module, {__call = function(_, ...) return new(...) end})



