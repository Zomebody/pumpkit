
----------------------------------------------------[[ == BASE OBJECTS == ]]----------------------------------------------------

-- camera3 is a top-down camera that rotates using a rotation along the Z-axis, and has a tilt along the local X-axis

local connection = require("framework.connection")

local module = {}

local Camera3 = {}
Camera3.__index = Camera3
Camera3.__tostring = function(tab) return "{Camera3: " .. tostring(tab.Id) .. "}" end



----------------------------------------------------[[ == METHODS == ]]----------------------------------------------------

--[[

	properties:
	- position
	- yaw
	- pitch
	methods:
	- moveLocal(vector3): relative to the camera's space
	- moveFlat(vector3): ignores pitch, but not yaw
	- move(vector3): moves in world space coordinates
	- set(position, yaw, pitch)
	- screenToRay(x, y): returns a ray with magnitude 1 in the direction of where you clicked
	- worldPointToScreen(vector3)
	- renderScene(scene3)

]]

-- check if an object is a camera3
local function isCamera3(t)
	return getmetatable(t) == Camera3
end



function Camera3:move(vec3)
	self.Position = self.Position + vec3
	-- update shader variables
	if self.Scene3 ~= nil then
		self.Scene3.Shader:send("cameraPosition", self.Position:array())
	end
end



function Camera3:set(vec3, rotZ, tilt, offset)
	self.Position = vector3(vec3)
	self.Rotation = rotZ
	self.Tilt = tilt
	if offset ~= nil then
		self.Offset = offset
	end


	-- update shader variables
	if self.Scene3 ~= nil then
		self.Scene3.Shader:send("cameraPosition", self.Position:array())
		self.Scene3.Shader:send("cameraRotation", self.Rotation)
		self.Scene3.Shader:send("cameraTilt", self.Tilt)
		if offset ~= nil then
			self.Scene3.Shader:send("cameraOffset", self.Offset)
		end
	end
end



function Camera3:moveFlat(vec3)
	local absX = vec3.x * math.cos(self.Rotation) - vec3.y * math.sin(self.Rotation)
	local absY = vec3.x * math.sin(self.Rotation) + vec3.y * math.cos(self.Rotation)
	self.Position = self.Position + vector3(absX, absY, vec3.z)
	if self.Scene3 ~= nil then
		self.Scene3.Shader:send("cameraPosition", self.Position:array())
	end
end



function Camera3:rotate(amount)
	self.Rotation = self.Rotation + amount
	if self.Scene3 ~= nil then
		self.Scene3.Shader:send("cameraRotation", self.Rotation)
	end
end



function Camera3:tilt(amount)
	self.Tilt = self.Tilt + amount
	if self.Scene3 ~= nil then
		self.Scene3.Shader:send("cameraTilt", self.Tilt)
	end
end


function Camera3:offset(amount)
	self.Offset = self.Offset + amount
	print(self.Scene3)
	if self.Scene3 ~= nil then
		self.Scene3.Shader:send("cameraOffset", self.Offset)
	end
end



function Camera3:attach(theScene)
	assert(scene3.isScene3(theScene), "Camera3:attach(scene3) requires the first argument to be a scene3")
	if theScene.Camera3 ~= nil then
		theScene.Camera3:detach()
	end

	if self.Scene3 ~= nil then
		self:detach()
	end

	self.Scene3 = theScene
	theScene.Camera3 = self
	if self.Events.Attached then
		connection.doEvents(self.Events.Attached, theScene)
	end
	if theScene.Events.CameraAttached then
		connection.doEvents(theScene.Events.CameraAttached, self)
	end
end



function Camera3:detach()
	if self.Scene3 ~= nil then
		local theScene = self.Scene3
		theScene.Camera3 = nil
		self.Scene3 = nil
		if self.Events.Detached then
			connection.doEvents(self.Events.Detached, theScene)
		end
		if theScene.Events.CameraDetached then
			connection.doEvents(theScene.Events.CameraDetached, self)
		end
	end
end



function Camera3:setFOV(fov)
	self.FieldOfView = fov

	-- update the scene's field-of-view if this camera is attached to one
	if self.Scene3 ~= nil then
		self.Scene3.Shader:send("fieldOfView", fov)
	end
end

-- TODO: Camera3:moveLocal()




-- returns a line3
--[[
function Camera3:screenToRay(cameraWidth, cameraHeight, cameraOffset, screenX, screenY, worldZ)
	screenY = cameraHeight - screenY

	-- Calculate the view-projection matrix
	local viewProjectionMatrix = calculatePerspectiveViewProjectionMatrix(self.Position, self.Rotation, self.Tilt, cameraWidth, cameraHeight, self.FieldOfView, cameraOffset)
	
	-- Invert the view-projection matrix
	local inverseViewProjectionMatrix = viewProjectionMatrix:invert()

	-- Convert screen coordinates to NDC
	local ndcX = 2 * (screenX / cameraWidth) - 1
	local ndcY = 1 - 2 * (screenY / cameraHeight)
	local ndcZ = 1 -- We're considering the far plane for the ray direction

	-- Create a 4D vector in NDC space (homogeneous coordinates)
	local ndcPos = vector4(ndcX, ndcY, ndcZ, 1)

	-- Transform the NDC position by the inverse view-projection matrix
	local worldPos4D = inverseViewProjectionMatrix * ndcPos

	-- Divide by w to get the 3D world position
	local worldPos = vector3(
		worldPos4D.x / worldPos4D.w,
		worldPos4D.y / worldPos4D.w,
		worldPos4D.z / worldPos4D.w
	)

	-- The worldPos represents a point on the ray from the camera through the screen point.
	-- To find where it intersects the z=0 plane, we'll do a ray-plane intersection.
	
	-- Ray start point (camera position)
	local viewDirection = getViewDirection(self.Rotation, self.Tilt)

	local rayStart = self.Position - viewDirection * cameraOffset
	
	-- Ray direction
	local rayDir = vector3(
		worldPos.x - rayStart.x,
		worldPos.y - rayStart.y,
		worldPos.z - rayStart.z
	)
	
	-- Calculate intersection with the z = 0 plane
	local t = (worldZ - rayStart.z) / rayDir.z
	local worldX = rayStart.x + t * rayDir.x
	local worldY = rayStart.y + t * rayDir.y
	
	return vector3(worldX, worldY, worldZ)
end
]]






--[[

for now the only camera type is a 'pivot camera', which is located at a given coordinate looking down, then rotates along the Z-axis, then the X-axis, and then moves backwards by some number of units

]]

local function new(p)
	if p == nil then
		p = vector3(0, 0, 0)
	end
	assert(vector3.isVector3(p), "camera3.new(pos) expects 'pos' to be a vector3.")

	local Obj = {
		["Position"] = vector3(p);
		["Rotation"] = 0; -- rotation in radians along the Z-axis
		["Tilt"] = 0; -- 0 = top-down, -90 = looking from the side
		["Offset"] = 0;
		["FieldOfView"] = math.rad(70); -- vertical FoV

		["Scene3"] = nil; -- reference to the scene3 that has this camera attached to it

		["Events"] = {};
	}

	return setmetatable(Obj, Camera3)
end



----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

-- pack up and return module
module.new = new
module.isCamera3 = isCamera3
return setmetatable(module, {__call = function(_, ...) return new(...) end})



