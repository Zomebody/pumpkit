
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
local SHADER_SSAOBLEND_PATH = "framework/shaders/ssaoblend.c"
local SHADER_BLUR_PATH = "framework/shaders/blur.c"
local SHADER_BLOOMBLUR_PATH = "framework/shaders/bloomblur.c"
local SHADER_SHADOWMAP_PATH = "framework/shaders/shadowmap.c"



----------------------------------------------------[[ == BASE OBJECTS == ]]----------------------------------------------------

local module = {
	["TotalCreated"] = 0;
}


local Scene3 = {}
Scene3.__index = Scene3
Scene3.__tostring = function(tab) return "{Scene3: " .. tostring(tab.Id) .. "}" end




----------------------------------------------------[[ == HELPERS == ]]----------------------------------------------------

local function findObjectInOrderedArray(Obj, tbl)
	local l, r = 1, #tbl
	if r < l then return 1 end
	while l ~= r do
		local index = math.floor((l + r) / 2)
		if tbl[index] == Obj then
			return index
		else
			if tbl[index].Id < Obj.Id then
				l = math.min(r, index + 1)
			else
				r = math.max(l, index - 1)
			end
		end
	end
	return l
end



local function findOrderedInsertLocation(tbl, Obj)
	local l, r = 1, #tbl
	if r < l then return 1 end
	while l ~= r do
		local index = math.floor((l + r) / 2)
		if tbl[index].Id < Obj.Id then
			l = math.min(r, index + 1)
		else
			r = math.max(l, index - 1)
		end
	end
	return (Obj.Id > tbl[l].Id) and (l + 1) or (l)
end



----------------------------------------------------[[ == FUNCTIONS == ]]----------------------------------------------------

-- check if an object is a scene
local function isScene3(t)
	return getmetatable(t) == Scene3
end



function Scene3:applyAmbientOcclusion()
	-- choose ping-pong canvases based on the quality you set
	local pingCanvas = self.ReuseCanvas1
	local pongCanvas = self.ReuseCanvas2
	--[[
	local pingCanvas, pongCanvas
	if self.AOQuality == 1 then
		pingCanvas = self.ReuseCanvas1
		pongCanvas = self.ReuseCanvas2
	elseif self.AOQuality == 0.5 then
		pingCanvas = self.ReuseCanvas3
		pongCanvas = self.ReuseCanvas4
	else -- 0.25
		pingCanvas = self.ReuseCanvas5
		pongCanvas = self.ReuseCanvas6
	end
	]]


	-- set ambient occlusion canvas as render target, and draw ambient occlusion data to the AO canvas
	love.graphics.setCanvas(pingCanvas)
	--love.graphics.clear()
	love.graphics.setShader(self.SSAOShader)
	self.SSAOShader:send("normalTexture", self.NormalCanvas)
	love.graphics.draw(self.DepthCanvas, 0, 0, 0, 1 / self.MSAA, 1 / self.MSAA) -- set the ambient occlusion shader in motion


	
	-- apply horizontal and vertical gaussian blur in two passes, using the reuse canvas to draw to that, and then back to the ambient occlusion canvas
	love.graphics.setCanvas(pongCanvas)
	--love.graphics.clear()
	--love.graphics.setShader()
	love.graphics.setShader(self.BlurShader)
	self.BlurShader:send("depthTexture", self.DepthCanvas)
	self.BlurShader:send("blurDirection", {1, 0})
	love.graphics.draw(pingCanvas)
	love.graphics.setCanvas(pingCanvas)
	--love.graphics.clear()
	self.BlurShader:send("blurDirection", {0, 1})
	love.graphics.draw(pongCanvas)
	


	-- now blend the ambient occlusion result with whatever has been drawn already
	love.graphics.setCanvas(self.PrepareCanvas)
	love.graphics.clear()
	love.graphics.setShader(self.SSAOBlendShader) -- set the blend shader so we can apply ambient occlusion to the render canvas
	self.SSAOBlendShader:send("aoTexture", pingCanvas) -- send over the rendered result from the ambient occlusion shader so we can sample it in the blend shader
	love.graphics.draw(self.RenderCanvas)


	-- copy result to render canvas
	love.graphics.setShader()
	love.graphics.setCanvas(self.RenderCanvas)
	--love.graphics.clear()
	--love.graphics.setShader()
	love.graphics.draw(self.PrepareCanvas)

end



function Scene3:applyBloom()
	-- choose ping-pong canvases based on the quality you set
	local pingCanvas, pongCanvas
	if self.BloomQuality == 1 then
		pingCanvas = self.ReuseCanvas1
		pongCanvas = self.ReuseCanvas2
	elseif self.BloomQuality == 0.5 then
		pingCanvas = self.ReuseCanvas3
		pongCanvas = self.ReuseCanvas4
	else -- 0.25
		pingCanvas = self.ReuseCanvas5
		pongCanvas = self.ReuseCanvas6
	end

	-- bloom canvas will have mostly black pixels, but any mesh with bloom > 0 and a non-black color, will be drawn as a non-black color
	-- the idea is to blur the bloom canvas, then draw it over the scene using additive blending, using a special shader for it

	-- TODO: edit the blur shader so that is knows about the quality and adjusts the blur size accordingly!

	-- draw scene to reuse canvas, then blur it
	love.graphics.setCanvas(pingCanvas)
	love.graphics.setShader(self.BloomBlurShader)
	-- re-use the blur-shader that was made for ambient occlusion. We can ignore the depth texture by disabling depth tolerance
	self.BloomBlurShader:send("blurDirection", {1, 0})
	love.graphics.draw(self.BloomCanvas, 0, 0, 0, 1 / self.MSAA * self.BloomQuality, 1 / self.MSAA * self.BloomQuality)
	love.graphics.setCanvas(pongCanvas)
	self.BloomBlurShader:send("blurDirection", {0, 1})
	-- draw to second reuse canvas for second blurring pass
	love.graphics.draw(pingCanvas)
	-- then finally, draw everything on top of the already rendered scene


	--love.graphics.setShader(self.BloomBlendShader)
	--self.BloomBlendShader:send("bloomTexture", self.ReuseCanvas2)
	local blendMode = love.graphics.getBlendMode()
	love.graphics.setBlendMode("add")
	love.graphics.setCanvas(self.RenderCanvas)
	love.graphics.draw(pongCanvas, 0, 0, 0, self.MSAA / self.BloomQuality, self.MSAA / self.BloomQuality)
	love.graphics.setBlendMode(blendMode)
	--love.graphics.setShader() -- not needed since whatever comes after this will set the correct shader
end




function Scene3:updateShadowMap()
	love.graphics.setMeshCullMode("none") -- "front" can be used to fix peter-panning, but prevents the backfaces from having any shadows!! that's why we set to "none"

	-- prepare for drawing
	love.graphics.setShader(self.ShadowMapShader)
	love.graphics.setDepthMode("less", true)
	love.graphics.setCanvas({self.ShadowCanvas, ["depthstencil"] = self.ShadowDepthCanvas})
	love.graphics.clear() -- we should clear since if you remove an object, the shadow in that area won't get overwritten
	

	-- render all meshes and instanced meshes that have shadows enabled to the shadow canvas
	local Mesh
	self.ShadowMapShader:send("isInstanced", true)
	for i = 1, #self.InstancedMeshes do
		Mesh = self.InstancedMeshes[i]
		if Mesh.CastShadow then
			love.graphics.drawInstanced(Mesh.Mesh, Mesh.Count)
		end
	end
	self.ShadowMapShader:send("isInstanced", false)
	for i = 1, #self.BasicMeshes do
		Mesh = self.BasicMeshes[i]
		if Mesh.CastShadow then
			-- TODO meshes need their own matrix instead of sending over and computing them every time in the shaders
			self.ShadowMapShader:send("meshPosition", Mesh.Position:array())
			self.ShadowMapShader:send("meshRotation", Mesh.Rotation:array())
			self.ShadowMapShader:send("meshScale", Mesh.Scale:array())
			love.graphics.draw(Mesh.Mesh)
		end
	end
	-- spritemeshes can't cast shadows so they are not included in here

	-- revert peter-panning
	love.graphics.setMeshCullMode("back")

	-- send over the shadow canvas to the main shader for sampling
	self.Shader:send("shadowCanvas", self.ShadowDepthCanvas)
end



function Scene3:draw(renderTarget) -- nil or a canvas
	-- get some graphics settings so they can be reverted later
	local prevCanvas = love.graphics.getCanvas()
	local prevDepthMode, prevWrite = love.graphics.getDepthMode()


	
	-- no camera? don't draw anything!
	if self.Camera3 == nil then
		return
	end

	-- blur shaders do sampling in 'pixel' coordinates while shaders work with normalized device coordinates
	-- that means that if you resize your screen, blurs will need to be adjusted as well to compensate for the different canvas size
	-- sending over shader variables every frame is unnecessary, so instead check if the canvas size has changed since last drawing operation
	local width, height
	if renderTarget ~= nil then
		width, height = renderTarget:getDimensions()
	else
		width, height = love.graphics.getDimensions()
	end
	if self.LastDrawSize.x ~= width or self.LastDrawSize.y ~= height then
		self.LastDrawSize = vector2(width, height)
		self.BlurShader:send("screenSize", {width, height})
		self.BloomBlurShader:send("screenSize", {width, height})
	end


	-- update positions of lights in the shader if any of the lights moved
	--[[
	if self.QueuedShaderVars.LightPositions then
		self.QueuedShaderVars.LightPositions = false
		local positions = {}
		for i = 1, MAX_LIGHTS_PER_SCENE do
			positions[i] = self.Lights[i].Position:array()
		end
		self.Shader:send("lightPositions", unpack(positions))
		self.ParticlesShader:send("lightPositions", unpack(positions))
	end

	-- update colors of lights in the shader if any of the lights changed color
	if self.QueuedShaderVars.LightColors then
		self.QueuedShaderVars.LightColors = false
		local colors = {}
		for i = 1, MAX_LIGHTS_PER_SCENE do
			colors[i] = {self.Lights[i].Color.r, self.Lights[i].Color.g, self.Lights[i].Color.b}
		end
		self.Shader:send("lightColors", unpack(colors))
		self.ParticlesShader:send("lightColors", unpack(colors))
	end

	-- update ranges of lights in the shader if any of the lights changed their range
	if self.QueuedShaderVars.LightRanges then
		self.QueuedShaderVars.LightRanges = false
		local ranges = {}
		for i = 1, MAX_LIGHTS_PER_SCENE do
			ranges[i] = self.Lights[i].Range
		end
		self.Shader:send("lightRanges", unpack(ranges))
		self.ParticlesShader:send("lightRanges", unpack(ranges))
	end

	-- update strengths of lights in the shader if any of the lights changed strength
	if self.QueuedShaderVars.LightStrengths then
		self.QueuedShaderVars.LightStrengths = false
		local strengths = {}
		for i = 1, MAX_LIGHTS_PER_SCENE do
			strengths[i] = self.Lights[i].Strength
		end
		self.Shader:send("lightStrengths", unpack(strengths))
		self.ParticlesShader:send("lightStrengths", unpack(strengths))
	end
	]]

	-- update lights
	local emptyInfo = {0, 0, 0, 0} -- lights that are not initialized get sent empty info. Define a drop-in here to avoid creating multiple tables
	local lightsInfo = {}
	for i = 1, #self.Lights do -- {posX, posY, posZ, range}, {colR, colG, colB, strength}
		table.insert(lightsInfo, {self.Lights[i].Position.x, self.Lights[i].Position.y, self.Lights[i].Position.z, self.Lights[i].Range})
		table.insert(lightsInfo, {self.Lights[i].Color.r, self.Lights[i].Color.g, self.Lights[i].Color.b, self.Lights[i].Strength})
	end
	--[[
	for o = #self.Lights + 1, 16 do -- fill in the remaining 'empty' light slots with dummy data
		table.insert(lightsInfo, emptyInfo)
		table.insert(lightsInfo, emptyInfo)
	end
	]]
	if #lightsInfo > 0 then
		self.Shader:send("lightsInfo", unpack(lightsInfo))
		self.ParticlesShader:send("lightsInfo", unpack(lightsInfo))
	end


	-- if a shadow canvas is set, it means shadow mapping is turned on
	if self.ShadowCanvas ~= nil then
		self:updateShadowMap()
	end


	-- set render canvas as target and clear it so a normal image can be drawn to it
	love.graphics.setCanvas({self.RenderCanvas, self.NormalCanvas, ["depthstencil"] = self.DepthCanvas}) -- set the main canvas so it can be cleared
	love.graphics.clear()
	love.graphics.setCanvas(self.BloomCanvas)
	love.graphics.clear(0, 0, 0)
	love.graphics.setCanvas(self.RenderCanvas) -- set the canvas to only be the render canvas so the background doesn't accidentally initialize anything in the normal canvas

	local renderWidth, renderHeight = self.RenderCanvas:getDimensions()

	-- draw the background
	if self.Background then
		love.graphics.setShader() -- needs to be reset because shadow map might be enabled
		love.graphics.setDepthMode("always", false)
		local imgWidth, imgHeight = self.Background:getDimensions()
		love.graphics.draw(self.Background, 0, 0, 0, renderWidth / imgWidth, renderHeight / imgHeight)
	end

	love.graphics.setCanvas({self.RenderCanvas, self.NormalCanvas, self.BloomCanvas, ["depthstencil"] = self.DepthCanvas}) -- set the main canvas with proper maps for geometry being drawn

	-- set the canvas to draw to the render canvas, and the shader to draw in 3d
	love.graphics.setShader(self.Shader)
	love.graphics.setDepthMode("less", true)

	-- draw all of the scene's meshes
	love.graphics.setMeshCullMode("back")


	-- first draw instanced meshes
	local Mesh = nil
	self.Shader:send("currentTime", love.timer.getTime())
	self.Shader:send("uvVelocity", {0, 0})
	self.Shader:send("meshTransparency", 0)
	self.Shader:send("isInstanced", true) -- tell the shader to use the attributes to calculate the model matrices
	for i = 1, #self.InstancedMeshes do
		Mesh = self.InstancedMeshes[i]
		self.Shader:send("triplanarScale", Mesh.IsTriplanar and Mesh.TextureScale or 0)
		self.Shader:send("meshBrightness", Mesh.Brightness)
		self.Shader:send("meshBloom", Mesh.Bloom)
		love.graphics.drawInstanced(Mesh.Mesh, Mesh.Count)
	end


	-- then draw all *opaque* basic meshes
	local TransMeshes = {} -- create new array to put all basic meshes in that have a Transparency > 0. Their rendering is postponed. They will be sorted later
	self.Shader:send("isInstanced", false) -- tell the shader to use the meshPosition, meshRotation, meshScale and meshColor uniforms to calculate the model matrices
	self.Shader:send("meshTransparency", 0) -- >0 transparency meshes are postponed until later
	for i = 1, #self.BasicMeshes do
		Mesh = self.BasicMeshes[i]
		if Mesh.Transparency == 0 then
			self.Shader:send("uvVelocity", Mesh.UVVelocity:array())
			self.Shader:send("meshPosition", Mesh.Position:array())
			self.Shader:send("meshRotation", Mesh.Rotation:array())
			self.Shader:send("meshScale", Mesh.Scale:array())
			self.Shader:send("meshColor", Mesh.Color:array())
			self.Shader:send("meshBrightness", Mesh.Brightness)
			self.Shader:send("meshBloom", Mesh.Bloom)
			self.Shader:send("triplanarScale", Mesh.IsTriplanar and Mesh.TextureScale or 0)
			love.graphics.draw(Mesh.Mesh)
		elseif Mesh.Transparency < 1 then -- ignore meshes with transparency == 1
			table.insert(TransMeshes, Mesh)
		end
	end

	-- repeat the process, but for *opaque* spritemeshes
	self.Shader:send("uvVelocity", {0, 0}) -- sprite meshes have no uv scrolling
	self.Shader:send("triplanarScale", 0) -- sprite meshes also have no triplanar texture projection
	self.Shader:send("isSpriteSheet", true) -- but they do need isSpriteSheet set to true for correct texture mapping
	for i = 1, #self.SpriteMeshes do
		Mesh = self.SpriteMeshes[i]
		if Mesh.Transparency == 0 then
			self.Shader:send("meshPosition", Mesh.Position:array())
			self.Shader:send("meshRotation", Mesh.Rotation:array())
			self.Shader:send("meshScale", Mesh.Scale:array())
			self.Shader:send("meshColor", Mesh.Color:array())
			self.Shader:send("meshBrightness", Mesh.Brightness)
			self.Shader:send("meshBloom", Mesh.Bloom)
			self.Shader:send("spritePosition", Mesh.SpritePosition)
			self.Shader:send("spriteSheetSize", Mesh.SheetSize)
			love.graphics.draw(Mesh.Mesh)
		elseif Mesh.Transparency < 1 then -- ignore meshes with transparency == 1
			table.insert(TransMeshes, Mesh)
		end
	end
	self.Shader:send("isSpriteSheet", false)

	-- now sort, then draw all basic/sprite meshes that were postponed
	local cameraPosition = self.Camera3.Position
	table.sort(
		TransMeshes,
		function(meshA, meshB)
			return (meshA.Position.x - cameraPosition.x)^2 + (meshA.Position.y - cameraPosition.y)^2 + (meshA.Position.z - cameraPosition.z)^2
				> (meshB.Position.x - cameraPosition.x)^2 + (meshB.Position.y - cameraPosition.y)^2 + (meshB.Position.z - cameraPosition.z)^2
		end
	)

	-- since both basic meshes and sprite meshes need to be drawn in the right order, this loop gets a bit complicated
	for i = 1, #TransMeshes do
		-- need to add a small check here to distinguish between basic meshes and sprite meshes since they have somewhat different properties
		Mesh = TransMeshes[i]
		if mesh3.isMesh3(Mesh) then -- basic mesh
			self.Shader:send("isSpriteSheet", false)
			self.Shader:send("uvVelocity", Mesh.UVVelocity:array())
			self.Shader:send("triplanarScale", Mesh.IsTriplanar and Mesh.TextureScale or 0)
		else -- sprite mesh
			self.Shader:send("isSpriteSheet", true)
			self.Shader:send("uvVelocity", {0, 0})
			self.Shader:send("triplanarScale", 0)
			self.Shader:send("spritePosition", Mesh.SpritePosition)
			self.Shader:send("spriteSheetSize", Mesh.SheetSize)
		end
		self.Shader:send("meshPosition", Mesh.Position:array())
		self.Shader:send("meshRotation", Mesh.Rotation:array())
		self.Shader:send("meshScale", Mesh.Scale:array())
		self.Shader:send("meshColor", Mesh.Color:array())
		self.Shader:send("meshBrightness", Mesh.Brightness)
		self.Shader:send("meshBloom", Mesh.Bloom)
		self.Shader:send("meshTransparency", Mesh.Transparency) -- now we can finally include transparency since these meshes are drawn in painter's algorithm order
		love.graphics.draw(Mesh.Mesh)
	end
	

	if self.AOEnabled then
		love.graphics.setDepthMode("always", false)
		self:applyAmbientOcclusion()
		love.graphics.setDepthMode("less", true)
	end

	if self.BloomStrength > 0 then
		love.graphics.setDepthMode("always", false)
		self:applyBloom()
		love.graphics.setDepthMode("less", true)
	end

	-- disable culling for particles so they can be seen from both sides
	love.graphics.setMeshCullMode("none")

	if #self.Particles > 0 then
		-- now draw all the particles in the scene
		-- don't need to send any info to the shader because the particles when they update themselves, also update the mesh attributes that encodes any required info
		love.graphics.setCanvas({self.RenderCanvas, ["depthstencil"] = self.DepthCanvas}) -- remove normals canvas and bloom canvas from render target. We won't need it anymore
		love.graphics.setShader(self.ParticlesShader)
		for i = 1, #self.Particles do
			self.Particles[i]:draw(self.ParticlesShader)
		end
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
	if renderTarget ~= nil then
		love.graphics.clear()
		-- if a render target is set, adjust the scaling so that it fits inside the render target
		local scaleX = renderTarget:getWidth() / self.RenderCanvas:getWidth()
		local scaleY = renderTarget:getHeight() / self.RenderCanvas:getHeight()
		-- a pretty important caveat here: if you are drawing to a render target it's VERY RECOMMENDED that the render target has the same dimensions as the screen
		-- if your render target is smaller however, e.g. when using split-screen, you should 100% call Scene3:rescaleCanvas() with your target width and height.
		-- because if you are drawing to a smaller render canvas but the scene has a fullscreen render canvas, you're tanking your FPS for no reason (better anti-aliasing though I guess)
		love.graphics.draw(self.RenderCanvas, 0, renderTarget:getHeight(), 0, scaleX, -scaleY)
	else
		-- if no render target is set, the scene is drawn to the screen, so use the screen's dimensions
		local scaleX = love.graphics.getWidth() / self.RenderCanvas:getWidth()
		local scaleY = love.graphics.getHeight() / self.RenderCanvas:getHeight()
		love.graphics.draw(self.RenderCanvas, 0, love.graphics.getHeight(), 0, scaleX, -scaleY)
	end
	

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

	-- round to a multiple of 4 so that we can downsample bloom/SSAO to half and quarter resolution
	width = math.ceil(width / 4) * 4
	height = math.ceil(height / 4) * 4

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
	depthCanvas:setFilter("nearest")
	local normalCanvas = love.graphics.newCanvas(width * msaa, height * msaa)
	--normalCanvas:setFilter("nearest")
	local prepareCanvas = love.graphics.newCanvas(width * msaa, height * msaa)
	prepareCanvas:setFilter("nearest")
	local bloomCanvas = love.graphics.newCanvas(width * msaa, height * msaa)
	bloomCanvas:setFilter("nearest")

	local reuseCanvas1 = love.graphics.newCanvas(width, height)
	--reuseCanvas1:setFilter("nearest")
	local reuseCanvas2 = love.graphics.newCanvas(width, height)
	--reuseCanvas2:setFilter("nearest")
	local reuseCanvas3 = love.graphics.newCanvas(width * 0.5, height * 0.5)
	--reuseCanvas3:setFilter("nearest")
	local reuseCanvas4 = love.graphics.newCanvas(width * 0.5, height * 0.5)
	--reuseCanvas4:setFilter("nearest")
	local reuseCanvas5 = love.graphics.newCanvas(width * 0.25, height * 0.25)
	--reuseCanvas5:setFilter("nearest")
	local reuseCanvas6 = love.graphics.newCanvas(width * 0.25, height * 0.25)
	--reuseCanvas6:setFilter("nearest")

	self.RenderCanvas = renderCanvas
	self.DepthCanvas = depthCanvas
	self.NormalCanvas = normalCanvas
	self.PrepareCanvas = prepareCanvas
	self.BloomCanvas = bloomCanvas
	self.ReuseCanvas1 = reuseCanvas1
	self.ReuseCanvas2 = reuseCanvas2
	self.ReuseCanvas3 = reuseCanvas3
	self.ReuseCanvas4 = reuseCanvas4
	self.ReuseCanvas5 = reuseCanvas5
	self.ReuseCanvas6 = reuseCanvas6
	self.MSAA = msaa

	-- update aspect ratio of the scene
	local aspectRatio = width / height
	self.Shader:send("aspectRatio", aspectRatio)
	self.ParticlesShader:send("aspectRatio", aspectRatio)

	-- calculate perspective matrix for the SSAO shader
	if self.Camera3 ~= nil then
		local persp = matrix4.perspective(aspectRatio, self.Camera3.FieldOfView, 1000, 0.1)
		local c1, c2, c3, c4 = persp:columns()
		self.SSAOShader:send("perspectiveMatrix", {c1, c2, c3, c4})
		--local invPersp = persp:invert()
		--local i1, i2, i3, i4 = invPersp:columns()
		--self.SSAOShader:send("invPerspectiveMatrix", {i1, i2, i3, i4})
	end
end



--[[
function Scene3:setLight(index, position, col, range, strength)
	assert(type(index) == "number", "Scene3:setLight(index, position, col, range, strength) requires argument 'index' to be a number")
	assert(vector3.isVector3(position), "Scene3:setLight(index, position, col, range, strength) requires argument 'position' to be a vector3")
	assert(color.isColor(col), "Scene3:setLight(index, position, col, range, strength) requires argument 'col' to be a color")
	assert(type(range) == "number", "Scene3:setLight(index, position, col, range, strength) requires argument 'range' to be a number")
	assert(type(strength) == "number", "Scene3:setLight(index, position, col, range, strength) requires argument 'strength' to be a number")
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
	
end
]]




function Scene3:setAmbient(col, occlusionColor)
	self.Shader:send("ambientColor", {col.r, col.g, col.b})
	self.ParticlesShader:send("ambientColor", {col.r, col.g, col.b})
	if occlusionColor ~= nil then
		self.SSAOBlendShader:send("occlusionColor", {occlusionColor.r, occlusionColor.g, occlusionColor.b})
	end
end



function Scene3:setAO(strength, kernelScalar)
	if strength == nil then strength = 0 end
	local enabled = strength > 0
	self.AOEnabled = enabled
	self.SSAOShader:send("aoStrength", strength)
	if enabled then
		self.SSAOShader:send("kernelScalar", kernelScalar)
	end
end


function Scene3:setAOQuality(quality)
	assert(quality == 1 or quality == 0.5 or quality == 0.25, "Scene3:setAOQuality(quality) requires argument 'quality' to be 1, 0.5 or 0.25.")
	self.AOQuality = quality
	-- TODO: set blur size
	--self.SSAOShader:send("aoQuality", quality)
	--self.SSAOBlendShader:send("aoQuality", quality)
	--self.BlurShader:send("aoQuality", quality)
	self.SSAOShader:send("samples", quality == 1 and 24 or (quality == 0.5 and 16 or 8))
end



function Scene3:setDiffuse(strength)
	self.Shader:send("diffuseStrength", strength)
end


-- the size parameter is how big the bloom blur will be in pixels. A size of 0 disables blur
function Scene3:setBloom(size)
	assert(type(size) == "number", "Scene3:setBloom(size) only accepts a number as the argument.")
	self.BloomStrength = size
	self.BloomBlurShader:send("blurSize", size)
end

function Scene3:setBloomQuality(quality)
	assert(quality == 1 or quality == 0.5 or quality == 0.25, "Scene3:setBloomQuality(quality) requires argument 'quality' to be 1, 0.5 or 0.25.")
	self.BloomQuality = quality
	--self.BloomBlurShader:send("bloomQuality", quality)
end


function Scene3:setShadowMap(position, direction, size, canvasSize, sunColor, shadowStrength)
	if position == nil then
		self.ShadowCanvas = nil
		self.ShadowDepthCanvas = nil
		self.Shader:send("shadowsEnabled", false)
	else
		assert(vector3.isVector3(position), "Scene3:setShadowMap(position, direction, size, canvasSize, sunColor, shadowStrength) requires argument 'position' to be a vector3.")
		assert(vector3.isVector3(direction), "Scene3:setShadowMap(position, direction, size, canvasSize, sunColor, shadowStrength) requires argument 'direction' to be a vector3.")
		assert(vector2.isVector2(size), "Scene3:setShadowMap(position, direction, size, canvasSize, sunColor, shadowStrength) requires argument 'size' to be a vector2.")
		assert(vector2.isVector2(canvasSize), "Scene3:setShadowMap(position, direction, size, canvasSize, sunColor, shadowStrength) requires argument 'canvasSize' to be a vector2.")
		assert(sunColor == nil or color.isColor(sunColor), "Scene3:setShadowMap(position, direction, size, canvasSize, sunColor, shadowStrength) requires argument 'sunColor' to be a color or nil.")
		assert(shadowStrength == nil or type(shadowStrength) == "number",
			"Scene3:setShadowMap(position, direction, size, canvasSize, sunColor, shadowStrength) requires argument 'shadowStrength' to be a number or nil.")

		self.Shader:send("shadowsEnabled", true)
		if sunColor == nil then
			self.Shader:send("sunColor", {1, 1, 1})
		else
			self.Shader:send("sunColor", {sunColor.r, sunColor.g, sunColor.b})
		end
		self.Shader:send("shadowStrength", shadowStrength ~= nil and shadowStrength or 0.5)
		direction = direction:clone():norm()
		self.Shader:send("sunDirection", {direction.x, direction.y, direction.z})

		-- create new canvases (but only if their sizes are different from the current ones)
		-- this will make it possible to potentially move the shadowmap around every frame
		if self.ShadowCanvas == nil or self.ShadowCanvas:getWidth() ~= canvasSize.x or self.ShadowCanvas:getHeight() ~= canvasSize.y then
			local shadowCanvas = love.graphics.newCanvas(canvasSize.x, canvasSize.y)
			self.ShadowCanvas = shadowCanvas
			local shadowDepthCanvas = love.graphics.newCanvas(canvasSize.x, canvasSize.y,
				{
					["type"] = "2d";
					["format"] = "depth16";
					["readable"] = true;
				}
			)
			self.ShadowDepthCanvas = shadowDepthCanvas
			shadowDepthCanvas:setDepthSampleMode("less")

			self.Shader:send("shadowCanvasSize", {canvasSize.x, canvasSize.y})
		end

		-- send over orthographic camera matrix
		local orthoMatrix = matrix4.orthographic(-size.x / 2, size.x / 2, size.y / 2, -size.y / 2, 100, 0.1) -- perspective correction matrix
		--local orthoMatrix = matrix4.perspective(size.x/size.y, self.Camera3.FieldOfView, 1000, 0.1)
		local c1, c2, c3, c4 = orthoMatrix:columns()
		self.ShadowMapShader:send("orthoMatrix", {c1, c2, c3, c4})
		self.Shader:send("orthoMatrix", {c1, c2, c3, c4}) -- also send to main shader so we know how to sample shadow map
		
		-- send over sun matrix
		local sunWorldMatrix = matrix4.lookAtWorld(position, direction) -- matrix of where the sun is
		local c1, c2, c3, c4 = sunWorldMatrix:columns()
		self.ShadowMapShader:send("sunWorldMatrix", {c1, c2, c3, c4})
		self.Shader:send("sunWorldMatrix", {c1, c2, c3, c4}) -- also send to main shader so we know how to sample shadow map
		

	end
end



function Scene3:attachLight(light)
	assert(light3.isLight3(light), "Scene3:attachLight(light) requires argument 'light' to be a light3.")
	if light.Scene ~= nil then
		light:detach()
	end

	local index = findOrderedInsertLocation(self.Lights, light)
	table.insert(self.Lights, index, light)
	light.Scene = self

	local lightCount = math.min(#self.Lights, 16)
	self.Shader:send("lightCount", lightCount)
	self.ParticlesShader:send("lightCount", lightCount)

	if #self.Lights > lightCount then
		print("Scene3:attachLight(light) added a light that will not display as there are already 16 or more lights in the scene.")
	end

	if self.Events.LightAttached then
		connection.doEvents(self.Events.LightAttached, light)
	end

	return light
end




-- if texScale is nil, IsPlanar is false, else, IsPlanar is true and TextureScale becomes texScale
function Scene3:addInstancedMesh(mesh, positions, rotations, scales, cols, bloom, brightness, castShadow, texScale)
	assert(type(bloom) == "number" or bloom == nil, "Scene3:addInstancedMesh(mesh, positions, rotations, scales, cols, bloom, brightness, texScale) requires 'bloom' to be a number or nil")
	assert(type(brightness) == "number" or brightness == nil, "Scene3:addInstancedMesh(mesh, positions, rotations, scales, cols, bloom, brightness, texScale) requires 'brightness' to be a number or nil")
	assert(type(texScale) == "number" or texScale == nil, "Scene3:addInstancedMesh(mesh, positions, rotations, scales, cols, bloom, brightness, texScale) requires 'texScale' to be a number or nil")
	assert(type(positions) == "table",
		"Scene3:addInstancedMesh(mesh, positions, rotations, scales, cols, bloom, brightness, texScale) requires argument 'positions' to be a table of vector3s, given is nil")
	if rotations == nil then
		rotations = {}
		for i = 1, #positions do rotations[i] = vector3(0, 0, 0) end
	else
		assert(type(rotations) == "table" and #rotations == #positions,
			"Scene3:addInstancedMesh(mesh, positions, rotations, scales, cols, bloom, brightness, texScale) requires argument 'rotations' to be nil or a table with vector3s of the same length as 'positions'")
	end
	if scales == nil then
		scales = {}
		for i = 1, #positions do scales[i] = vector3(1, 1, 1) end
	else
		assert(type(scales) == "table" and #scales == #positions,
			"Scene3:addInstancedMesh(mesh, positions, rotations, scales, cols, bloom, brightness, texScale) requires argument 'scales' to be nil or a table with vector3s of the same length as 'positions'")
	end
	if cols == nil then
		cols = {}
		for i = 1, #positions do cols[i] = color(1, 1, 1) end
	else
		assert(type(cols) == "table" and #cols == #positions,
			"Scene3:addInstancedMesh(mesh, positions, rotations, scales, cols, bloom, brightness, texScale) requires argument 'cols' to be nil or a table with colors of the same length as 'positions'")
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
		["Bloom"] = bloom ~= nil and bloom or 0;
		["Brightness"] = brightness ~= nil and brightness or 0;
		["CastShadow"] = castShadow;
		["IsTriplanar"] = texScale ~= nil; -- determines if the mesh's texture is applied using triplanar projection
		["TextureScale"] = texScale ~= nil and texScale or 1; -- only used if IsTriplanar is true.
		["Count"] = #positions;
	}

	table.insert(self.InstancedMeshes, Data)
	
	return Data
end



function Scene3:attachMesh(mesh)
	--assert(mesh3.isMesh3(mesh), "Scene3:attachBasicMesh(mesh) requires argument 'mesh' to be a mesh3.")
	if mesh.Scene ~= nil then
		mesh:detach()
	end

	if mesh3.isMesh3(mesh) then
		local index = findOrderedInsertLocation(self.BasicMeshes, mesh)
		table.insert(self.BasicMeshes, index, mesh)
	elseif spritemesh3.isSpritemesh3(mesh) then
		local index = findOrderedInsertLocation(self.SpriteMeshes, mesh)
		table.insert(self.SpriteMeshes, index, mesh)
	else
		error("Scene3:attachMesh(mesh) requires argument 'mesh' to be either a mesh3 or spritemesh3")
	end
	mesh.Scene = self

	if self.Events.MeshAttached then
		connection.doEvents(self.Events.MeshAttached, mesh)
	end

	return mesh
end



function Scene3:detachMesh(mesh) -- basic mesh or sprite mesh
	local slot
	local Item = nil
	if mesh3.isMesh3(mesh) then
		slot = findObjectInOrderedArray(mesh, self.BasicMeshes)
		Item = table.remove(self.BasicMeshes, slot)
	elseif spritemesh3.isSpritemesh3(mesh) then
		slot = findObjectInOrderedArray(mesh, self.SpriteMeshes)
		Item = table.remove(self.SpriteMeshes, slot)
	else
		error("Scene3:detachMesh(mesh) requires argument 'mesh' to be either a mesh3 or spritemesh3")
	end
	
	if Item ~= nil then
		Item.Scene = nil

		if self.Events.MeshDetached then
			connection.doEvents(self.Events.MeshDetached, Item)
		end

		return true
	end
	return false
end



function Scene3:detachLight(lightOrSlot)
	if type(lightOrSlot) ~= "number" then -- object was passed
		assert(light3.isLight3(lightOrSlot), "Scene3:detachLight(lightOrSlot) requires argument 'lightOrSlot' to be either a light3 or an integer")
		lightOrSlot = findObjectInOrderedArray(lightOrSlot, self.Lights)
	end
	local Item = table.remove(self.Lights, lightOrSlot)
	if Item ~= nil then
		Item.Scene = nil

		local lightCount = math.min(#self.Lights, 16)
		self.Shader:send("lightCount", lightCount)
		self.ParticlesShader:send("lightCount", lightCount)

		if self.Events.LightDetached then
			connection.doEvents(self.Events.LightDetached, Item)
		end

		return true
	end
	return false
end



function Scene3:attachParticles(particles)
	assert(particles3.isParticles3(particles), "Scene3:addParticles(particles) expects argument 'particles' to be of type particles3")

	if particles.Scene ~= nil then
		particles:detach()
	end

	local index = findOrderedInsertLocation(self.Particles, particles)
	table.insert(self.Particles, index, particles)
	particles.Scene = self

	if self.Events.ParticlesAttached then
		connection.doEvents(self.Events.ParticlesAttached, particles)
	end
	return particles
end



function Scene3:detachParticles(meshOrSlot)
	if type(meshOrSlot) ~= "number" then -- object was passed
		assert(particles3.isParticles3(meshOrSlot), "Scene3:detachParticles(meshOrSlot) requires argument 'meshOrSlot' to be either a particles3 or an integer")
		meshOrSlot = findObjectInOrderedArray(meshOrSlot, self.Particles)
	end
	local Item = table.remove(self.Particles, meshOrSlot)
	if Item ~= nil then
		Item.Scene = nil

		if self.Events.ParticlesDetached then
			connection.doEvents(self.Events.ParticlesDetached, Item)
		end

		return true
	end
	return false
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

	-- round screen size to multiple of 4 so that downscaling SSAO and bloom can be supported
	local gWidth, gHeight = love.graphics.getWidth(), love.graphics.getHeight()
	gWidth = math.ceil(gWidth / 4) * 4
	gHeight = math.ceil(gHeight / 4) * 4
	
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
	depthCanvas:setFilter("nearest")
	local normalCanvas = love.graphics.newCanvas(gWidth * msaa, gHeight * msaa)
	local prepareCanvas = love.graphics.newCanvas(gWidth * msaa, gHeight * msaa)
	prepareCanvas:setFilter("nearest")
	local bloomCanvas = love.graphics.newCanvas(gWidth * msaa, gHeight * msaa)
	bloomCanvas:setFilter("nearest")

	local reuseCanvas1 = love.graphics.newCanvas(gWidth, gHeight)
	local reuseCanvas2 = love.graphics.newCanvas(gWidth, gHeight)
	local reuseCanvas3 = love.graphics.newCanvas(gWidth * 0.5, gHeight * 0.5)
	local reuseCanvas4 = love.graphics.newCanvas(gWidth * 0.5, gHeight * 0.5)
	local reuseCanvas5 = love.graphics.newCanvas(gWidth * 0.25, gHeight * 0.25)
	local reuseCanvas6 = love.graphics.newCanvas(gWidth * 0.25, gHeight * 0.25)


	local Object = {
		["Id"] = module.TotalCreated;

		["Shader"] = love.graphics.newShader(SHADER_PATH); -- create one shader per scene so you can potentially 
		["ParticlesShader"] = love.graphics.newShader(SHADER_PARTICLES_PATH);
		["SSAOShader"] = love.graphics.newShader(SHADER_SSAO_PATH); -- screen-space ambient occlusion shader
		["SSAOBlendShader"] = love.graphics.newShader(SHADER_SSAOBLEND_PATH); -- blend shader to blend ambient occlusion with the rendered scene
		["BlurShader"] = love.graphics.newShader(SHADER_BLUR_PATH);
		["BloomBlurShader"] = love.graphics.newShader(SHADER_BLOOMBLUR_PATH);
		["ShadowMapShader"] = love.graphics.newShader(SHADER_SHADOWMAP_PATH);

		["LastDrawSize"] = vector2(gWidth, gHeight); -- when you suddenly start drawing the scene at a different size, some shader variables need to be updated!

		-- canvas properties, update whenever you change the render target
		["RenderCanvas"] = renderCanvas;
		["DepthCanvas"] = depthCanvas;
		["NormalCanvas"] = normalCanvas;
		["PrepareCanvas"] = prepareCanvas; -- higher resolution canvas for ambient occlusion & bloom, used to draw things to which are then combined with the render canvas
		["BloomCanvas"] = bloomCanvas;
		["ShadowCanvas"] = nil; -- either nil, or a canvas when shadow map is enabled
		["ShadowDepthCanvas"] = nil;  -- either nil, or a canvas when shadow map is enabled

		-- when applying SSAO, bloom, etc. you need multiple render passes. For that purpose 'reuse' canvases are created to play ping-pong with each pass
		-- Considering that SSAO, bloom etc. might want to be downscaled for better FPS, there are canvases for full, half and quarter size
		["ReuseCanvas1"] = reuseCanvas1; -- full quality 1
		["ReuseCanvas2"] = reuseCanvas2; -- full quality 2
		["ReuseCanvas3"] = reuseCanvas3; -- half quality 1
		["ReuseCanvas4"] = reuseCanvas4; -- half quality 2
		["ReuseCanvas5"] = reuseCanvas5; -- quarter quality 1
		["ReuseCanvas6"] = reuseCanvas6; -- quarter quality 2

		["MSAA"] = msaa;
		["AOEnabled"] = true;
		["DiffuseStrength"] = 1;
		["BloomStrength"] = 0;
		["AOQuality"] = 1; -- 1 = full quality, 0.5 = half quality, 0.25 = quarter quality
		["BloomQuality"] = 1; -- 1 = full quality, 0.5 = half quality, 0.25 = quarter quality

		-- render variables
		["Background"] = bgImage; -- image, drawn first (so they appear in the back)
		["Foreground"] = fgImage;

		-- scene elements
		["Camera3"] = sceneCamera or camera3.new();
		["InstancedMeshes"] = {}; -- simply an array of Love2D mesh objects
		["BasicMeshes"] = {}; -- dictionary with Mesh instances
		["SpriteMeshes"] = {}; -- spritemeshes dictionary
		["Particles"] = {}; -- array of particle emitter instances. Particle emitters are always instanced for performance reasons
		["Lights"] = {}; -- array with lights that have a Position, Color, Range and Strength

		-- table with arrays of event functions stored under keys named after the events
		["Events"] = {};
	}

	setmetatable(Object, Scene3)

	Object.Camera3:attach(Object)

	-- init shader variables
	Object.Camera3:updateCameraMatrices()
	local aspectRatio = gWidth / gHeight
	Object.Shader:send("aspectRatio", aspectRatio)
	Object.Shader:send("fieldOfView", Object.Camera3.FieldOfView)
	Object.Shader:send("diffuseStrength", 1)
	Object.Shader:send("lightCount", 0)
	Object.ParticlesShader:send("aspectRatio", aspectRatio)
	Object.ParticlesShader:send("fieldOfView", Object.Camera3.FieldOfView)
	Object.ParticlesShader:send("lightCount", 0)
	Object.SSAOShader:send("aoStrength", 0.5)
	Object.SSAOShader:send("kernelScalar", 0.85) -- how 'large' ambient occlusion is
	Object.SSAOShader:send("samples", 24)
	--Object.SSAOShader:send("viewDistanceFactor", 0.2) -- when you zoom out ambient occlusion fades away, bigger number = need to zoom out more
	local persp = matrix4.perspective(aspectRatio, Object.Camera3.FieldOfView, 1000, 0.1)
	local c1, c2, c3, c4 = persp:columns()
	Object.SSAOShader:send("perspectiveMatrix", {c1, c2, c3, c4})

	-- bloom and AO quality shader vars
	Object.BlurShader:send("screenSize", {gWidth, gHeight})
	--Object.BlurShader:send("aoQuality", 1)
	--Object.SSAOShader:send("aoQuality", 1)
	Object.BloomBlurShader:send("screenSize", {gWidth, gHeight})

	-- create and send noise image to SSAO shader
	local imgData = love.image.newImageData(8, 8) --16, 16
	local seed = love.math.getRandomSeed()
	local state = love.math.getRandomState()
	love.math.setRandomSeed(1212)
	imgData:mapPixel(function() local r = love.math.random() return r, r, r, 1 end)
	love.math.setRandomSeed(seed)
	love.math.setRandomState(state)
	local noiseImage = love.graphics.newImage(imgData)
	--noiseImage:setFilter("nearest") -- using nearest instead of linear interpolation somehow increases FPS by 10%, probs Texel() is slow?
	noiseImage:setWrap("repeat")
	noiseImage:setFilter("nearest")
	Object.SSAOShader:send("noiseTexture", noiseImage)


	-- set a default ambience
	Object.Shader:send("ambientColor", {1, 1, 1, 1})
	Object.ParticlesShader:send("ambientColor", {1, 1, 1, 1})
	Object.SSAOBlendShader:send("occlusionColor", {0, 0, 0})

	return Object
end




----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

module.newScene3 = newScene3
module.isScene3 = isScene3
return setmetatable(module, {__call = function(_, ...) return newScene3(...) end})
