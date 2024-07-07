
----------------------------------------------------[[ == IMPORTS == ]]----------------------------------------------------

local connection = require("framework.connection")



----------------------------------------------------[[ == BASE OBJECTS == ]]----------------------------------------------------

local module = {
	["TotalCreated"] = 0;
	["AllCameras"] = {}; -- list of all cameras that have been created
}

local Camera = {}
Camera.__index = Camera
Camera.__tostring = function(tab) return "{Camera: " .. tostring(tab.Id) .. "}" end



----------------------------------------------------[[ == METHODS == ]]----------------------------------------------------

function module:initialize()
	if not self.Initialized then
		self.Initialized = true
	else
		return
	end

	local oldResize = love.resize or function() end
	love.resize = function(...)
		oldResize(...)
		
		for i = 1, #self.AllCameras do
			self.AllCameras[i]:updateTransform()
		end
	end
end


-- check if an object is a camera
local function isCamera(t)
	return getmetatable(t) == Camera
end


-- return the current transform used to translate from 'scene space' to 'camera space'
function Camera:getTransform()
	return self.Transform
end


-- only for internal use!
-- correctly re-applies the current Camera properties to its Transform
function Camera:updateTransform()
	self.Transform:reset()
	-- TODO: consider the zoom inside the math.floor()
	self.Transform:translate(
		math.floor(love.graphics.getWidth() / 2),
		math.floor(love.graphics.getHeight() / 2)
	) -- center origin to middle of screen (rounded to prevent half-pixel alignments)
	self.Transform:scale(self.Zoom) -- apply zoom
	self.Transform:translate(
		math.floor(-self.Position.x * self.Zoom) / self.Zoom,
		math.floor(-self.Position.y * self.Zoom) / self.Zoom
	) -- translations are now affected by the zoom level (so zoomed in will make camera movement appear 'faster', zoomed out 'slower')
end


function Camera:move(x, y)
	if vector.isVector(x) then
		y = x.y
		x = x.x
	end
	self.Position = self.Position + vector(x, y)
	self:updateTransform()

	if self.Events.Moved then
		connection.doEvents(self.Events.Moved, x, y)
	end
end


function Camera:moveTo(x, y)
	if vector.isVector(x) then
		y = x.y
		x = x.x
	end
	self.Position = vector(x, y)
	self:updateTransform()

	if self.Events.Moved then
		connection.doEvents(self.Events.Moved, x, y)
	end
end


function Camera:setZoom(zoom)
	assert(type(zoom) == "number", "Camera:setZoom(zoom) only takes a number as its argument")
	if self.Zoom ~= zoom then
		self.Zoom = zoom
		self:updateTransform()
	end
end


function Camera:remove()
	-- TODO: instead of looping through the array one by one, you can use a log2(O) search by checking the Camera.Id property for faster look-up
	for i = 1, #module.AllCameras do
		if module.AllCameras[i] == self then
			table.remove(module.AllCameras, i)
		end
	end
end


-- given an x and y coordinate in screen space (a pixel on the screen), return a vector describing that location in world space (so with transforms etc. applied)
function Camera:screenPointToWorldSpace(x, y)
	if vector.isVector(x) then
		y = x.y
		x = x.x
	end
	local globalX, globalY = self:getTransform():inverseTransformPoint(x, y)
	return globalX, globalY
end


function Camera:worldPointToScreenSpace(x, y)
	if vector.isVector(x) then
		y = x.y
		x = x.x
	end
	local screenX, screenY = self:getTransform():transformPoint(x, y)
	return screenX, screenY
end


-- eventName is the name of the event to call. All event name strings are accepted, but not all of them may trigger
-- func is the function to link
function Camera:on(eventName, func)
	if self.Events[eventName] == nil then
		self.Events[eventName] = {}
	end
	local index = #self.Events[eventName] + 1
	local Conn = connection.new(self, eventName)
	self.Events[eventName][index] = {func, Conn}
	return Conn
end



----------------------------------------------------[[ == OBJECT CREATION == ]]----------------------------------------------------

-- creates a new Camera object with the base properties of a Camera
local function new()
	module.TotalCreated = module.TotalCreated + 1

	local Object = {
		["Id"] = module.TotalCreated;
		["Position"] = vector(0, 0);
		["Zoom"] = 1; -- zoom of 1 equals 1:1 pixels. Zoom of 2 means every game pixel takes up 2x2 screen pixels. Zoom of 0.5 means you see twice as much on the x-axis and y-axis
		["Transform"] = love.math.newTransform();

		-- event table, manipulated by the :on() method
		["Events"] = {};
	}
	setmetatable(Object, Camera)
	module.AllCameras[#module.AllCameras + 1] = Object -- insert camera into list of cameras
	Object:moveTo(0, 0) -- move to origin (which is required because you still need to set the camera's transform! (and this cannot trigger any events because :on() cannot be called yet))
	return Object
end



----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

-- pack up and return module
module.new = new
module.isCamera = isCamera
return setmetatable(module, {__call = function(_, ...) return new(...) end})



