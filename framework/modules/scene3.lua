
----------------------------------------------------[[ == IMPORTS == ]]----------------------------------------------------

local here = ...
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
local SHADER_PATH = "framework/shaders/shader3d.c"



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

	local prevCanvas = love.graphics.getCanvas()
	love.graphics.setCanvas(renderTarget)
	love.graphics.clear()
	love.graphics.setShader()

	-- draw the background
	if self.Background then
		love.graphics.draw(self.Background)
	end

	-- set the canvas to draw to the render canvas, and the shader to draw in 3d
	love.graphics.setCanvas({self.RenderCanvas, ["depthstencil"] = self.DepthCanvas})
	love.graphics.clear()
	love.graphics.setShader(self.Shader)

	-- draw all of the scene's meshes
	local Mesh = nil
	for i = 1, #self.Meshes do
		Mesh = self.Meshes[i]
		self.Shader:send("meshPosition", Mesh.Position:array()) -- Mesh.Position:array()
		self.Shader:send("meshRotation", Mesh.Rotation:array()) -- Mesh.Rotation:array()
		self.Shader:send("meshScale", Mesh.Scale:array()) -- Mesh.Scale:array()
		love.graphics.draw(Mesh.Mesh)
	end

	-- reset the canvas to the render target & render the scene
	love.graphics.setCanvas(renderTarget)
	love.graphics.setShader()
	love.graphics.draw(self.RenderCanvas, 0, self.RenderCanvas:getHeight() / self.MSAA, 0, 1 / self.MSAA, -1 / self.MSAA)


	-- draw the foreground
	if self.Foreground then
		love.graphics.draw(self.Foreground)
	end

	love.graphics.setCanvas(prevCanvas)
end



function Scene3:setCamera(theCamera)
	assert(camera3.isCamera3(theCamera), "Scene3:setCamera(camera3) requires the passed argument to be a camera3")
	if self.Camera3 ~= nil then
		self.Camera3:detach()
	end

	theCamera:attach(self)
end


function Scene3:getCamera()
	return self.Camera3
end



-- updates the aspect ratio, render canvas and depth canvas
function Scene3:rescaleCanvas(width, height, msaa)
	if msaa == nil then
		msaa = self.MSAA
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
	self.MSAA = msaa

	-- update aspect ratio of the scene
	local aspectRatio = width / height
	self.Shader:send("aspectRatio", aspectRatio)
end




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

	-- TODO: re-enable later
	--self.Shader:send("lightPositions[" .. shaderIndex .. "]", {position.x, position.y, position.z})
	--self.Shader:send("lightColors[" .. shaderIndex .. "]", {col.r, col.g, col.b})
	--self.Shader:send("lightRanges[" .. shaderIndex .. "]", range)
	--self.Shader:send("lightStrengths[" .. shaderIndex .. "]", strength)
end



function Scene3:addMesh(mesh, position, rotation, scale)
	if position == nil then
		position = vector3(0, 0, 0)
	end
	if rotation == nil then
		rotation = vector3(0, 0, 0)
	end
	if scale == nil then
		scale = vector3(1, 1, 1)
	end

	table.insert(
		self.Meshes,
		{
			["Mesh"] = mesh;
			["Position"] = position;
			["Rotation"] = rotation;
			["Scale"] = scale;
		}
	)
end



-- eventName is the name of the event to call. All event name strings are accepted, but not all of them may trigger
-- func is the function to link
function Scene3:on(eventName, func)
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

		-- canvas properties, update whenever you change the render target
		["RenderCanvas"] = renderCanvas;
		["DepthCanvas"] = depthCanvas;
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

	setmetatable(Object, Scene3)

	Object.Camera3:attach(Object)

	Object.Shader:send("cameraPosition", Object.Camera3.Position:array())
	Object.Shader:send("cameraTilt", Object.Camera3.Tilt)
	Object.Shader:send("cameraRotation", Object.Camera3.Rotation)
	Object.Shader:send("cameraOffset", Object.Camera3.Offset)
	local aspectRatio = gWidth / gHeight
	Object.Shader:send("aspectRatio", aspectRatio)
	print(Object.Camera3.FieldOfView)
	Object.Shader:send("fieldOfView", Object.Camera3.FieldOfView)
	print("sent position, tilt, rotation, offset, aspectratio, fov")

	



	-- TODO: init lights with 0-strength white lights (re-enable this later when lights are enabled in the shader)
	--[[
	local positions = {}
	local colors = {}
	local ranges = {}
	local strengths = {}
	for i = 1, MAX_LIGHTS_PER_SCENE do
		positions[i] = {0,0,0}
		colors[i] = {0,0,0}
		ranges[i] = 0
		strengths[i] = 0
	end
	self.Shader:send("lightPositions", positions)
	self.Shader:send("lightColors", colors)
	self.Shader:send("lightRanges", ranges)
	self.Shader:send("lightStrengths", strengths)
	]]

	return Object
end




----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

module.newScene3 = newScene3
module.newTiledScene = newTiledScene
module.isScene3 = isScene3
return setmetatable(module, {__call = function(_, ...) return newScene3(...) end})
