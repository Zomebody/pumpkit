
----------------------------------------------------[[ == BASE OBJECTS == ]]----------------------------------------------------

-- camera transform is applied in the order: first zoom -> then rotation x -> then rotation y -> then rotation z
-- whenever the camera's rotation/position changes, calculate a matrix4 which is then sent to the shader
-- the reason for doing all this is to reduce work-load on the GPU side (since the camera won't be moving every frame!). So now instead of calculating the matrix on the GPU each frame, we simply have it computed already
-- another reason for doing it this way is to make it easier to implement particles! Particles will be facing the camera, so we can simply copy the camera's matrix and replace the position component for particles

local connection = require("framework.connection")

local module = {}

local Camera3 = {}
Camera3.__index = Camera3
Camera3.__tostring = function(tab) return "{Camera3: " .. tostring(tab.Position) .. ", " .. tostring(tab.Rotation) .. "}" end



----------------------------------------------------[[ == METHODS == ]]----------------------------------------------------

-- check if an object is a camera3
local function isCamera3(t)
	return getmetatable(t) == Camera3
end



function Camera3:updateCameraMatrices()
	local camMatrix = matrix4():translate(0, 0, self.Offset):rotateX(self.Rotation.x):rotateY(self.Rotation.y):rotateZ(self.Rotation.z):translate(self.Position.x, self.Position.y, self.Position.z)
	self.Matrix = camMatrix
	if self.Scene3 ~= nil then
		local c1, c2, c3, c4 = camMatrix:columns()
		self.Scene3.Shader:send("camMatrix", {c1, c2, c3, c4})
		self.Scene3.ParticlesShader:send("camMatrix", {c1, c2, c3, c4})
	end
end



function Camera3:move(vec3)
	self.Position = self.Position + vec3
	-- update shader variables
	if self.Scene3 ~= nil then
		self:updateCameraMatrices()
	end
end


function Camera3:moveLocal(vec3)
	local localVector = matrix4():rotateX(self.Rotation.x):rotateY(self.Rotation.y):rotateZ(self.Rotation.z):toWorldVector(vec3)
	self.Position = self.Position + localVector
	if self.Scene3 ~= nil then
		self:updateCameraMatrices()
	end
end



function Camera3:set(pos, rot, offset)
	self.Position = vector3(pos)
	if rot ~= nil then
		self.Rotation = vector3(rot)
	end
	if offset ~= nil then
		self.Offset = offset
	end


	-- update shader variables
	if self.Scene3 ~= nil then
		self:updateCameraMatrices()
	end
end



function Camera3:pitch(angle)
	self.Rotation = self.Rotation + vector3(angle, 0, 0)
	self:updateCameraMatrices()
end

function Camera3:yaw(angle)
	self.Rotation = self.Rotation + vector3(0, angle, 0)
	self:updateCameraMatrices()
end

function Camera3:roll(angle)
	self.Rotation = self.Rotation + vector3(0, 0, angle)
	self:updateCameraMatrices()
end


function Camera3:offset(amount)
	self.Offset = self.Offset + amount
	if self.Scene3 ~= nil then
		self:updateCameraMatrices()
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
		self.Scene3.ParticlesShader:send("fieldOfView", fov)

		self:updateCameraMatrices()

		local aspectRatio = self.Scene3.RenderCanvas:getWidth() / self.Scene3.RenderCanvas:getHeight()
		local persp = matrix4.perspective(aspectRatio, fov, 1000, 0.1)
		local c1, c2, c3, c4 = persp:columns()
		Object.SSAOShader:send("perspectiveMatrix", {c1, c2, c3, c4})

	end
end

-- TODO: Camera3:moveLocal()




-- returns a line3 with a length of 1, starting at the camera's position and pointing towards the given coordinate in world space
-- xFactor and yFactor are how far on the x-axis and y-axis you clicked, as numbers from 0 to 1

function Camera3:screenToRay(xFactor, yFactor, aspectRatio)
	if aspectRatio == nil then
		assert(self.Scene3 ~= nil, "Camera3:screenToRay(xFactor, yFactor, aspectRatio, fov) does not work if 'aspectRatio' is nil and no Scene3 is set to fetch an aspect ratio from.")
		
		aspectRatio = self.Scene3.RenderCanvas:getWidth() / self.Scene3.RenderCanvas:getHeight()
	end

	
	-- convert to clip space
	local clipX = 2 * xFactor - 1
	local clipY = 1 - 2 * yFactor
	local clipPosition = vector4(clipX, clipY, -1, 1)

	local invCamProjection = matrix4.perspective(aspectRatio, self.FieldOfView, 1000, 0.1):inverse()
	local invViewMatrix = self.Matrix:inverse()

	-- clip position to view space to world space
	local viewPosition = invCamProjection * clipPosition
	viewPosition = vector4(viewPosition.x, viewPosition.y, -1, 0)
	local worldDirection = invViewMatrix * viewPosition
	worldDirection = vector3(worldDirection.x, worldDirection.y, worldDirection.z):norm()

	local realCameraPosition = vector3(self.Matrix[13], self.Matrix[14], self.Matrix[15]) -- check if these indices are the correct ones, otherwise it might be 4,8,12

	-- return line3
	return line3(realCameraPosition, realCameraPosition + worldDirection)
end











local function new(p)
	if p == nil then
		p = vector3(0, 0, 0)
	end
	assert(vector3.isVector3(p), "camera3.new(pos) expects 'pos' to be a vector3.")

	local Obj = {
		["Position"] = vector3(p);
		["Rotation"] = vector3(); -- euler angles rotation. Gets converted to a matrix and sent to the shader each time it's updated
		["Offset"] = 0; -- this also gets incorporated into that same matrix and sent to the shader
		["FieldOfView"] = math.rad(70); -- vertical FoV
		["Matrix"] = nil;

		["Scene3"] = nil; -- reference to the scene3 that has this camera attached to it

		["Events"] = {};
	}

	setmetatable(Obj, Camera3)
	Obj:updateCameraMatrices() -- updates self.Matrix. Shaders are ignored as no scene is set yet

	return Obj
end



----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

-- pack up and return module
module.new = new
module.isCamera3 = isCamera3
return setmetatable(module, {__call = function(_, ...) return new(...) end})



