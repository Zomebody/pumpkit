
----------------------------------------------------[[ == IMPORTS == ]]----------------------------------------------------

local connection = require("framework.connection")

--[[

3d graphics features wishlist:
- 3d models with:
	- textures
	- vertex coloring
	- blended by multiplying texture color w/ vertex color
- up to 8 lights in a scene, with:
	- color
	- strength
	- range
- unlimited number of meshes with:
	- position
	- rotation (ZXY?)
	- scale
- colored fog: starting distance, color and thickness & ending distance, color and thickness
- 3d camera with field-of-view, position, rotation (along Z), tilt (along X) & offset backwards from its position



]]



----------------------------------------------------[[ == VARIABLES == ]]----------------------------------------------------

local MAX_LIGHTS_PER_SCENE = 8
local SHADER_PATH = "shaders.shader3d.c"



----------------------------------------------------[[ == BASE OBJECTS == ]]----------------------------------------------------

local module = {
	["TotalCreated"] = 0;
}


local Scene3 = {}
Scene3.__index = Scene3
Scene3.__tostring = function(tab) return "{Scene3: " .. tostring(tab.Id) .. "}" end



----------------------------------------------------[[ == FUNCTIONS == ]]----------------------------------------------------

-- check if an object is a scene
local function isScene3(t)
	return getmetatable(t) == Scene3
end



function Scene3:draw(renderTarget) -- nil or a canvas
	
	-- no camera? don't draw anything!
	if self.Camera3 == nil then
		return
	end
	

	-- update aspect ratio if it isn't up-to-date
	local aspectRatio
	if renderTarget ~= nil then
		local width, height = renderTarget.getDimensions()
		aspectRatio = width / height
		if self.Width ~= width or self.Height ~= height then
			self:rescaleCanvas(nil, width, height)
		end
	else
		local width, height = love.graphics.getDimensions()
		aspectRatio = width / height
		if self.Width ~= width or self.Height ~= height then
			self:rescaleCanvas(nil, width, height)
		end
	end
	if aspectRatio ~= self.AspectRatio then
		self.AspectRatio = aspectRatio
		self.Shader:send("aspectRatio", aspectRatio)
	end



	love.graphics.setCanvas(renderTarget)

	-- draw the background
	if self.Background then
		love.graphics.draw(self.Background)
	end

	-- set the canvas to draw to the render canvas, and the shader to draw in 3d
	love.graphics.setCanvas({self.RenderCanvas, ["depthstencil"] = self.DepthCanvas})
	love.graphics.setShader(shader3d)

	-- draw all of the scene's meshes
	local Mesh = nil
	for i = 1, #self.Meshes do
		Mesh = self.Meshes[i]
		shader3d:send("meshPosition", Mesh.Position:array())
		shader3d:send("meshRotation", Mesh.Rotation:array())
		shader3d:send("meshScale", Mesh.Scale:array())
	end

	-- reset the canvas to the render target & render the scene
	love.graphics.setCanvas(renderTarget)
	love.graphics.draw(self.RenderCanvas, 0, 0, 0, 1 / self.MSAA, 1 / self.MSAA)


	-- draw the foreground
	love.graphics.setShader()
	if self.Foreground then
		love.graphics.draw(self.Foreground)
	end

	love.graphics.setCanvas()
end



function Scene3:setCamera(theCamera)
	assert(camera3.isCamera3(theCamera), "Scene3:setCamera(camera3) requires the passed argument to be a camera3")
	if self.Camera3 ~= nil then
		self.Camera3:detach()
	end

	theCamera:attach(self)


end



-- updates the aspect ratio, render canvas and depth canvas
function Scene3:rescaleCanvas(msaa, width, height)
	if msaa == nil then
		msaa = 4
	end

	if width == nil or height == nil then
		width, height = love.graphics.getDimensions()
	end
	local renderCanvas = love.graphics.newCanvas(width * msaa, height * msaa)
	local depthCanvas = love.graphics.newCanvas(
		width * msaa,
		height * msaa,
		{
			["type"] = "2d";
			["format"] = "depth16";
			["readable"] = true;
		}
	)

	self.RenderCanvas = renderCanvas
	self.DepthCanvas = depthCanvas
	self.Width = width
	self.Height = height
	self.MSAA = msaa
end


-- should only be called when the Scene3 instance is being created
--[[
function Scene3:initLights()
	local positions = {}
	local colors = {}
	local ranges = {}
	local strengths = {}

	-- init lights
	local Light = nil
	for i = 1, #self.Lights do
		Light = self.Lights[i]
		table.insert(positions, Light.Position:array())
		table.insert(colors, Light.Color:array())
		table.insert(ranges, Light.Range)
		table.insert(strengths, Light.Strength)
	end

	-- fill the rest of the lights with dummy lights that don't do anything
	for k = #self.Lights + 1, MAX_LIGHTS_PER_SCENE do
		table.insert(positions, {0, 0, 0})
		table.insert(colors, {1, 1, 1})
		table.insert(ranges, 0)
		table.insert(strengths, 0)
	end

	self.Shader:send(lightPositions, unpack(positions))
	self.Shader:send(lightColors, unpack(colors))
	self.Shader:send(lightRanges, unpack(ranges))
	self.Shader:send(lightStrengths, unpack(strengths))
end
]]

function Scene3:addLight(position, col, range, strength)
	local index = nil
	for i = 1, MAX_LIGHTS_PER_SCENE do
		if self.Lights[i] == nil then
			index = i
			break
		end
	end

	if index == nil then
		return nil -- operation failed
	end

	local Light = {
		["Position"] = vector3(position);
		["Color"] = color(col);
		["Range"] = range;
		["Strength"] = strength;
	}

	self.Lights[index] = Light
	local shaderIndex = tostring(index - 1)

	self.Shader:send("lightPositions[" .. shaderIndex .. "]", {position.x, position.y, position.z})
	self.Shader:send("lightColors[" .. shaderIndex .. "]", {col.r, col.g, col.b})
	self.Shader:send("lightRanges[" .. shaderIndex .. "]", range)
	self.Shader:send("lightStrengths[" .. shaderIndex .. "]", strength)
end



-- eventName is the name of the event to call. All event name strings are accepted, but not all of them may trigger
-- func is the function to link
function Scene:on(eventName, func)
	if self.Events[eventName] == nil then
		self.Events[eventName] = {}
	end
	local index = #self.Events[eventName] + 1
	local Conn = connection.new(self, eventName)
	self.Events[eventName][index] = {func, Conn}
	return Conn
end



----------------------------------------------------[[ == OBJECT CREATION == ]]----------------------------------------------------

-- creates a new Scene3 object with the base properties of a Scene3
local function newScene3(sceneCamera, bgImage, fgImage, msaa)
	if msaa == nil then
		msaa = 4
	end

	--assert(camera.isCamera(sceneCamera) or sceneCamera == nil, "scene3.newScene3(image, sceneCamera) only accepts a camera instance or nil for 'sceneCamera'")
	module.TotalCreated = module.TotalCreated + 1

	local gWidth, gHeight = love.graphics.getWidth(), love.graphics.getHeight()
	local aspectRatio = gWidth / gHeight
	
	local renderCanvas = love.graphics.newCanvas(gWidth * msaa, gHeight * msaa)
	local depthCanvas = love.graphics.newCanvas(
		gWidth * msaa,
		gHeight * msaa,
		{
			["type"] = "2d";
			["format"] = "depth16";
			["readable"] = true;
		}
	)

	local Object = {
		["Id"] = module.TotalCreated;

		["Shader"] = love.graphics.newShader(SHADER_PATH); -- create one shader per scene so you can potentially 

		["Width"] = gWidth; -- (screen width) UPDATES AUTOMATICALLY, DO NOT TOUCH
		["Height"] = gHeight; -- (screen height) UPDATES AUTOMATICALLY, DO NOT TOUCH
		["MSAA"] = msaa;

		-- render variables
		["Background"] = bgImage; -- image, drawn first (so they appear in the back)
		["Foreground"] = fgImage;

		-- scene elements
		["Camera3"] = sceneCamera or camera3.new();
		["Meshes"] = {}; -- any number of meshes, dictionaries with properties: Position, Rotation (applied in order ZXY), Scale
		["Lights"] = {}; -- up to 8 dictionaries with properties: Position, Color, Range, Strength

		-- table with arrays of event functions stored under keys named after the events
		["Events"] = {};
	}

	return setmetatable(Object, Scene3)
end




----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

module.newScene3 = newScene3
module.newTiledScene = newTiledScene
module.isScene3 = isScene3
return setmetatable(module, {__call = function(_, ...) return newScene3(...) end})
