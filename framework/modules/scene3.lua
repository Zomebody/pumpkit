
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

local MAX_LIGHTS_PER_SCENE = 16
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
	-- get some graphics settings so they can be reverted later
	local prevCanvas = love.graphics.getCanvas()
	local prevDepthMode, prevWrite = love.graphics.getDepthMode()


	
	-- no camera? don't draw anything!
	if self.Camera3 == nil then
		return
	end
	--[[
	local width, height
	if renderTarget == nil then
		width, height = love.graphics:getDimensions()
	else
		width, height = renderTarget:getDimensions()
	end
	]]

	-- update positions of lights in the shader if any of the lights moved
	if self.QueuedShaderVars.LightPositions then
		self.QueuedShaderVars.LightPositions = false
		local positions = {}
		for i = 1, MAX_LIGHTS_PER_SCENE do
			positions[i] = self.Lights[i].Position:array()
		end
		self.Shader:send("lightPositions", unpack(positions))
	end
	-- update colors of lights in the shader if any of the lights changed color
	if self.QueuedShaderVars.LightColors then
		self.QueuedShaderVars.LightColors = false
		local colors = {}
		for i = 1, MAX_LIGHTS_PER_SCENE do
			colors[i] = {self.Lights[i].Color.r, self.Lights[i].Color.g, self.Lights[i].Color.b}
		end
		self.Shader:send("lightColors", unpack(colors))
	end
	-- update ranges of lights in the shader if any of the lights changed their range
	if self.QueuedShaderVars.LightRanges then
		self.QueuedShaderVars.LightRanges = false
		local ranges = {}
		for i = 1, MAX_LIGHTS_PER_SCENE do
			ranges[i] = self.Lights[i].Range
		end
		self.Shader:send("lightRanges", unpack(ranges))
	end
	-- update strengths of lights in the shader if any of the lights changed strength
	if self.QueuedShaderVars.LightStrengths then
		self.QueuedShaderVars.LightStrengths = false
		local strengths = {}
		for i = 1, MAX_LIGHTS_PER_SCENE do
			strengths[i] = self.Lights[i].Strength
		end
		self.Shader:send("lightStrengths", unpack(strengths))
	end




	
	--love.graphics.setCanvas(renderTarget)
	--love.graphics.clear()
	--love.graphics.setShader()

	-- set render canvas as target and clear it so a normal image can be drawn to it
	love.graphics.setCanvas({self.RenderCanvas, ["depthstencil"] = self.DepthCanvas})
	love.graphics.clear()

	local renderWidth, renderHeight = self.RenderCanvas:getDimensions()

	-- draw the background
	if self.Background then
		love.graphics.setShader()
		love.graphics.setDepthMode("always", false)
		local imgWidth, imgHeight = self.Background:getDimensions()
		love.graphics.draw(self.Background, 0, 0, 0, renderWidth / imgWidth, renderHeight / imgHeight)
	end

	-- set the canvas to draw to the render canvas, and the shader to draw in 3d
	--love.graphics.setCanvas({self.RenderCanvas, ["depthstencil"] = self.DepthCanvas})
	love.graphics.setShader(self.Shader)
	love.graphics.setDepthMode("less", true)

	-- draw all of the scene's meshes
	local Mesh = nil
	self.Shader:send("isInstanced", false) -- tell the shader to use the meshPosition, meshRotation, meshScale and meshColor uniforms to calculate the model matrices
	for i = 1, #self.BasicMeshes do
		Mesh = self.BasicMeshes[i]
		self.Shader:send("meshPosition", Mesh.Position:array())
		self.Shader:send("meshRotation", Mesh.Rotation:array())
		self.Shader:send("meshScale", Mesh.Scale:array())
		self.Shader:send("meshColor", Mesh.Color:array())
		love.graphics.draw(Mesh.Mesh)
	end
	self.Shader:send("isInstanced", true) -- tell the shader to use the attributes to calculate the model matrices
	for i = 1, #self.InstancedMeshes do
		Mesh = self.InstancedMeshes[i]
		love.graphics.drawInstanced(Mesh.Mesh, Mesh.Count)
	end

	-- setShader() can be called here since if self.Foreground ~= nil then setting setShader() in there makes no sense since the shader will be set to nil anyway right after when drawing the canvas to the screen
	love.graphics.setShader()

	-- draw the foreground
	if self.Foreground then
		love.graphics.setDepthMode("always", false)
		local imgWidth, imgHeight = self.Foreground:getDimensions()
		love.graphics.draw(self.Foreground, 0, 0, 0, renderWidth / imgWidth, renderHeight / imgHeight)
	end

	-- reset the canvas to the render target & render the scene
	love.graphics.setCanvas(renderTarget)
	love.graphics.draw(self.RenderCanvas, 0, self.RenderCanvas:getHeight() / self.MSAA, 0, 1 / self.MSAA, -1 / self.MSAA)

	-- revert some graphics settings
	love.graphics.setCanvas(prevCanvas)
	love.graphics.setDepthMode(prevDepthMode, prevWrite)
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




function Scene3:setLight(index, position, col, range, strength)
	local currentPosition = self.Lights[index].Position
	local currentColor = self.Lights[index].Color
	local currentRange = self.Lights[index].Range
	local currentStrength = self.Lights[index].Strength

	local Light = {
		["Position"] = vector3(position);
		["Color"] = color(col);
		["Range"] = range;
		["Strength"] = strength;
	}

	self.Lights[index] = Light

	if self.QueuedShaderVars.LightPositions == false and currentPosition ~= position then
		self.QueuedShaderVars.LightPositions = true
	end
	if self.QueuedShaderVars.LightColors == false and currentColor ~= col then
		self.QueuedShaderVars.LightColors = true
	end
	if self.QueuedShaderVars.LightRanges == false and currentRange ~= range then
		self.QueuedShaderVars.LightRanges = true
	end
	if self.QueuedShaderVars.LightStrengths == false and currentStrength ~= strength then
		self.QueuedShaderVars.LightStrengths = true
	end
	--self:sendLights()
end



function Scene3:setAmbient(col)
	self.Shader:send("ambientColor", {col.r, col.g, col.b})
end



function Scene3:addBasicMesh(mesh, position, rotation, scale, col)
	assert(vector3.isVector3(position), "Scene3:addBasicMesh(mesh, position, rotation, scale, col) requires argument 'position' to be a vector3")
	local Mesh = {
		["Mesh"] = mesh;
		["Position"] = vector3(position);
		["Rotation"] = vector3(rotation) or vector3(0, 0, 0);
		["Scale"] = vector3(scale) or vector3(1, 1, 1);
		["Color"] = color(col) or color(1, 1, 1);
	}
	table.insert(self.BasicMeshes, Mesh)
end



function Scene3:addInstancedMesh(mesh, positions, rotations, scales, cols)
	assert(type(positions) == "table", "Scene3:addInstancedMesh(mesh, positions, rotations, scales, cols) requires argument 'positions' to be a table of vector3s, given is nil")
	if rotations == nil then
		rotations = {}
		for i = 1, #positions do
			rotations[i] = vector3(0, 0, 0)
		end
	else
		assert(type(rotations) == "table" and #rotations == #positions,
			"Scene3:addInstancedMesh(mesh, positions, rotations, scales, cols) requires argument 'rotations' to be nil or a table with vector3s of the same length as 'positions'")
	end
	if scales == nil then
		scales = {}
		for i = 1, #positions do
			scales[i] = vector3(1, 1, 1)
		end
	else
		assert(type(scales) == "table" and #scales == #positions,
			"Scene3:addInstancedMesh(mesh, positions, rotations, scales, cols) requires argument 'scales' to be nil or a table with vector3s of the same length as 'positions'")
	end
	if cols == nil then
		cols = {}
		for i = 1, #positions do
			cols[i] = color(1, 1, 1)
		end
	else
		assert(type(scales) == "table" and #cols == #positions,
			"Scene3:addInstancedMesh(mesh, positions, rotations, scales, cols) requires argument 'cols' to be nil or a table with colors of the same length as 'positions'")
	end

	local instancesData = {}
	for i = 1, #positions do
		table.insert(
			instancesData,
			{positions[i].x, positions[i].y, positions[i].z, rotations[i].x, rotations[i].y, rotations[i].z, scales[i].x, scales[i].y, scales[i].z, cols[i].r, cols[i].g, cols[i].b}
		)
	end


	local instanceMesh = love.graphics.newMesh(
		{
			{"instancePosition", "float", 3},
			{"instanceRotation", "float", 3},
			{"instanceScale", "float", 3},
			{"instanceColor", "float", 3}
		},
		instancesData,
		"triangles",
		"static"
	)

	mesh:attachAttribute("instancePosition", instanceMesh, "perinstance")
	mesh:attachAttribute("instanceRotation", instanceMesh, "perinstance")
	mesh:attachAttribute("instanceScale", instanceMesh, "perinstance")
	mesh:attachAttribute("instanceColor", instanceMesh, "perinstance")

	local Data = {
		["Mesh"] = mesh;
		["Instances"] = instanceMesh;
		["Count"] = #positions;
	}

	table.insert(self.InstancedMeshes, Data)
	
	return Data
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
		["QueuedShaderVars"] = { -- whether during the next :draw() call the scene should update the shader variables below. These variables are introduced to minimize traffic to the shader!
			["LightPositions"] = true; -- initialize to true to force the variables to be sent on the very first frame
			["LightColors"] = true; -- same as above
			["LightRanges"] = true; -- same as above
			["LightStrengths"] = true; -- same as above
		};

		-- canvas properties, update whenever you change the render target
		["RenderCanvas"] = renderCanvas;
		["DepthCanvas"] = depthCanvas;
		["MSAA"] = msaa;

		-- render variables
		["Background"] = bgImage; -- image, drawn first (so they appear in the back)
		["Foreground"] = fgImage;

		-- scene elements
		["Camera3"] = sceneCamera or camera3.new();
		["InstancedMeshes"] = {}; -- simply an array of Love2D mesh objects
		["BasicMeshes"] = {}; -- dictionary with properties: Mesh, Position, Rotation, Scale, Color
		["Lights"] = {}; -- array with lights that have a Position, Color, Range and Strength

		-- table with arrays of event functions stored under keys named after the events
		["Events"] = {};
	}

	setmetatable(Object, Scene3)

	Object.Camera3:attach(Object)

	-- init camera shadeer variables
	Object.Shader:send("cameraPosition", Object.Camera3.Position:array())
	Object.Shader:send("cameraTilt", Object.Camera3.Tilt)
	Object.Shader:send("cameraRotation", Object.Camera3.Rotation)
	Object.Shader:send("cameraOffset", Object.Camera3.Offset)
	local aspectRatio = gWidth / gHeight
	Object.Shader:send("aspectRatio", aspectRatio)
	Object.Shader:send("fieldOfView", Object.Camera3.FieldOfView)


	-- init lights with 0-strength white lights (re-enable this later when lights are enabled in the shader)
	for i = 1, MAX_LIGHTS_PER_SCENE do
		Object.Lights[i] = {
			["Position"] = vector3(0, 0, 0);
			["Color"] = color(0, 0, 0);
			["Range"] = 0;
			["Strength"] = 0;
		}
	end

	-- set a default ambience
	Object.Shader:send("ambientColor", {1, 1, 1, 1})

	return Object
end




----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

module.newScene3 = newScene3
module.newTiledScene = newTiledScene
module.isScene3 = isScene3
return setmetatable(module, {__call = function(_, ...) return newScene3(...) end})
