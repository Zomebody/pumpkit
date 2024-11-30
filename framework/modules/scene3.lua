
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

local MAX_LIGHTS_PER_SCENE = 16
local SHADER_PATH = "framework/shaders/shader3d.c"
local SHADER_PARTICLES_PATH = "framework/shaders/particles3d.c"
local SHADER_SSAO_PATH = "framework/shaders/ssao3d.c"
local SHADER_SSAOBLEND_PATH = "framework/shaders/ssaoBlend.c"



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



function Scene3:applyAmbientOcclusion()
	local prevCanvas = love.graphics.getCanvas()
	local prevShader = love.graphics.getShader()

	-- set ambient occlusion canvas as render target, and draw ambient occlusion data to the AO canvas
	love.graphics.setCanvas(self.AOCanvas)
	love.graphics.clear()
	love.graphics.setShader(self.SSAOShader)
	self.SSAOShader:send("normalTexture", self.NormalCanvas)
	love.graphics.draw(self.DepthCanvas) -- set the ambient occlusion shader in motion

	-- now blend the ambient occlusion result with whatever has been drawn already
	love.graphics.setCanvas(self.AOBlendCanvas)
	love.graphics.clear()
	love.graphics.setShader(self.SSAOBlendShader) -- set the blend shader so we can apply ambient occlusion to the render canvas
	self.SSAOBlendShader:send("aoTexture", self.AOCanvas) -- send over the rendered result from the ambient occlusion shader so we can sample it in the blend shader
	love.graphics.draw(self.RenderCanvas)

	-- copy result to render canvas
	love.graphics.setShader()
	love.graphics.setCanvas(self.RenderCanvas)
	love.graphics.clear()
	love.graphics.setShader()
	love.graphics.draw(self.AOBlendCanvas)

	love.graphics.setCanvas()
	love.graphics.draw(self.RenderCanvas)

	love.graphics.setShader(prevShader)
	love.graphics.setCanvas(prevCanvas)

end



function Scene3:draw(renderTarget) -- nil or a canvas
	-- get some graphics settings so they can be reverted later
	local prevCanvas = love.graphics.getCanvas()
	local prevDepthMode, prevWrite = love.graphics.getDepthMode()


	
	-- no camera? don't draw anything!
	if self.Camera3 == nil then
		return
	end

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


	-- set render canvas as target and clear it so a normal image can be drawn to it
	love.graphics.setCanvas({self.RenderCanvas, self.NormalCanvas, ["depthstencil"] = self.DepthCanvas}) -- render to render canvas
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

	--love.graphics.setCanvas({self.RenderCanvas, ["depthstencil"] = self.DepthCanvas}) -- reset the canvas to just the render canvas

	-- TODO: somewhere in here we need to apply (screen-space) ambient occlusion
	-- what we do is we take the depth canvas and use that to determine where 'corners' are that should be dark
	-- we render the dark spots to a separate canvas, if I understand ambient occlusion correctly
	-- then we draw that canvas to the current render target (don't forget to temporarily change depth testing so it just works)
	-- implement this as a separate function
	love.graphics.setDepthMode("always", false)
	self:applyAmbientOcclusion()
	love.graphics.setDepthMode("less", true)

	-- now draw all the particles in the scene
	-- don't need to send any info to the shader because the particles when they update themselves, also update the mesh attributes that encodes any required info
	love.graphics.setShader(self.ParticlesShader)
	for i = 1, #self.Particles do
		love.graphics.drawInstanced(self.Particles[i].Mesh, #self.Particles[i].Spawned)
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

	--love.graphics.draw(self.NormalCanvas, 0, self.RenderCanvas:getHeight() / self.MSAA, 0, 1 / self.MSAA, -1 / self.MSAA)
	--love.graphics.draw(self.DepthCanvas, 0, self.RenderCanvas:getHeight() / self.MSAA, 0, 1 / self.MSAA, -1 / self.MSAA)

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
	local normalCanvas = love.graphics.newCanvas(width * msaa, height * msaa)
	local aoCanvas = love.graphics.newCanvas(width * msaa, height * msaa)
	local aoBlendCanvas = love.graphics.newCanvas(width * msaa, height * msaa)

	self.RenderCanvas = renderCanvas
	self.DepthCanvas = depthCanvas
	self.NormalCanvas = normalCanvas
	self.AOCanvas = aoCanvas
	self.AOBlendCanvas = aoBlendCanvas
	self.MSAA = msaa

	-- update aspect ratio of the scene
	local aspectRatio = width / height
	self.Shader:send("aspectRatio", aspectRatio)
	self.ParticlesShader:send("aspectRatio", aspectRatio)
	--self.SSAOShader:send("aspectRatio", aspectRatio)

	-- calculate perspective matrix for the SSAO shader
	if self.Camera3 ~= nil then
		local persp = matrix4.perspective(aspectRatio, self.Camera3.FieldOfView, 1000, 0.1)
		local c1, c2, c3, c4 = persp:columns()
		self.SSAOShader:send("perspectiveMatrix", {c1, c2, c3, c4})
	end
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


function Scene3:setAOStrength(strength)
	self.SSAOShader:send("aoStrength", strength)
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

	mesh:attachAttribute("instancePosition", instanceMesh, "perinstance") -- first vertex attribute
	mesh:attachAttribute("instanceRotation", instanceMesh, "perinstance") -- second vertex attribute
	mesh:attachAttribute("instanceScale", instanceMesh, "perinstance") -- third vertex attribute
	mesh:attachAttribute("instanceColor", instanceMesh, "perinstance") -- fourth vertex attribute

	local Data = {
		["Mesh"] = mesh;
		["Instances"] = instanceMesh; -- the reason for exposing the instances is so that setVertexAttribute() can be used on individual instances to update them after batching
		["Count"] = #positions;
	}

	table.insert(self.InstancedMeshes, Data)
	
	return Data
end



function Scene3:addParticles(particles)
	assert(particles3.isParticles3(particles), "Scene3:addParticles(particles) expects argument 'particles' to be of type particles3")

	table.insert(self.Particles, particles)
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
		msaa = 2
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
	local normalCanvas = love.graphics.newCanvas(gWidth * msaa, gHeight * msaa)
	local aoCanvas = love.graphics.newCanvas(gWidth * msaa, gHeight * msaa)
	local aoBlendCanvas = love.graphics.newCanvas(gWidth * msaa, gHeight * msaa)


	local Object = {
		["Id"] = module.TotalCreated;

		["Shader"] = love.graphics.newShader(SHADER_PATH); -- create one shader per scene so you can potentially 
		["ParticlesShader"] = love.graphics.newShader(SHADER_PARTICLES_PATH);
		["SSAOShader"] = love.graphics.newShader(SHADER_SSAO_PATH); -- screen-space ambient occlusion shader
		["SSAOBlendShader"] = love.graphics.newShader(SHADER_SSAOBLEND_PATH); -- blend shader to blend ambient occlusion with the rendered scene

		["QueuedShaderVars"] = { -- whether during the next :draw() call the scene should update the shader variables below. These variables are introduced to minimize traffic to the shader!
			["LightPositions"] = true; -- initialize to true to force the variables to be sent on the very first frame
			["LightColors"] = true; -- same as above
			["LightRanges"] = true; -- same as above
			["LightStrengths"] = true; -- same as above
		};

		-- canvas properties, update whenever you change the render target
		["RenderCanvas"] = renderCanvas;
		["DepthCanvas"] = depthCanvas;
		["NormalCanvas"] = normalCanvas;
		["AOCanvas"] = aoCanvas; -- ambient occlusion canvas that is transparent, except for the places that should be darker
		["AOBlendCanvas"] = aoBlendCanvas; -- intermediate canvas to render ambient occlusion blending result to before rendering it to the render canvas. Idk if we can maybe eliminate this
		["MSAA"] = msaa;

		-- render variables
		["Background"] = bgImage; -- image, drawn first (so they appear in the back)
		["Foreground"] = fgImage;

		-- scene elements
		["Camera3"] = sceneCamera or camera3.new();
		["InstancedMeshes"] = {}; -- simply an array of Love2D mesh objects
		["BasicMeshes"] = {}; -- dictionary with properties: Mesh, Position, Rotation, Scale, Color
		["Particles"] = {}; -- array of particle emitter instances. Particle emitters are always instanced for performance reasons
		["Lights"] = {}; -- array with lights that have a Position, Color, Range and Strength

		-- table with arrays of event functions stored under keys named after the events
		["Events"] = {};
	}

	setmetatable(Object, Scene3)

	Object.Camera3:attach(Object)

	-- init camera shader variables
	Object.Camera3:updateCameraMatrices()
	local aspectRatio = gWidth / gHeight
	Object.Shader:send("aspectRatio", aspectRatio)
	Object.Shader:send("fieldOfView", Object.Camera3.FieldOfView)
	Object.ParticlesShader:send("aspectRatio", aspectRatio)
	Object.ParticlesShader:send("fieldOfView", Object.Camera3.FieldOfView)
	Object.SSAOShader:send("aoStrength", 0.5)
	local persp = matrix4.perspective(aspectRatio, Object.Camera3.FieldOfView, 1000, 0.1)
	local c1, c2, c3, c4 = persp:columns()
	Object.SSAOShader:send("perspectiveMatrix", {c1, c2, c3, c4})


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
