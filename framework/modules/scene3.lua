
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
--local SHADER_PATH = "framework/shaders/shader3d.c"
local SHADER_VERTEX_PATH = "framework/shaders/vertex3d.c"
local SHADER_FRAGMENT_PATH = "framework/shaders/fragment3d.c"
local SHADER_RIPPLE_PATH = "framework/shaders/ripplefrag.c"
local SHADER_FOLIAGE_PATH = "framework/shaders/foliagefrag.c"
local SHADER_PARTICLES_VERT = "framework/shaders/particlesvert.c"
local SHADER_PARTICLES_FRAG = "framework/shaders/particlesfrag.c"
local SHADER_SSAO_PATH = "framework/shaders/ssao3d.c"
local SHADER_SSAOBLEND_PATH = "framework/shaders/ssaoblend.c"
local SHADER_AOBLUR_PATH = "framework/shaders/aoblur.c"
local SHADER_BLOOMBLUR_PATH = "framework/shaders/bloomblur.c"
local SHADER_SHADOWMAP_PATH = "framework/shaders/shadowmap.c"
local SHADER_TRIVERT_PATH = "framework/shaders/trivert3d.c"
local SHADER_TRIFRAG_PATH = "framework/shaders/trifrag.c"



----------------------------------------------------[[ == BASE OBJECTS == ]]----------------------------------------------------

local module = {
	["TotalCreated"] = 0;
}


local Scene3 = {}
Scene3.__index = Scene3
Scene3.__tostring = function(tab) return "{Scene3: " .. tostring(tab.Id) .. "}" end



----------------------------------------------------[[ == IMAGES == ]]----------------------------------------------------

local noiseData = love.image.newImageData(8, 8) --16, 16
local seed = love.math.getRandomSeed()
local state = love.math.getRandomState()
love.math.setRandomSeed(1212)
noiseData:mapPixel(function() local r = love.math.random() return r, r, r, 1 end)
love.math.setRandomSeed(seed)
love.math.setRandomState(state)
local noiseImage = love.graphics.newImage(noiseData)
noiseImage:setWrap("repeat")
noiseImage:setFilter("nearest")


local normalData = love.image.newImageData(1, 1)
normalData:mapPixel(function() return 0.5, 0.5, 1 end)
local normalImage = love.graphics.newImage(normalData)
normalImage:setWrap("repeat")
normalImage:setFilter("nearest")

local whitePixel = love.image.newImageData(1, 1)
whitePixel:setPixel(0, 0, 1, 1, 1, 1)
local blankImage = love.graphics.newImage(whitePixel)
blankImage:setWrap("repeat")
blankImage:setFilter("nearest")

local dataMap = love.image.newImageData(1, 1) -- specifically for ripplemeshes. No distortion, no noise/foam
dataMap:mapPixel(function() return 0, 0, 1, 0 end)
local dataImage = love.graphics.newImage(dataMap)
dataImage:setWrap("repeat")
dataImage:setFilter("nearest")



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
	local pingCanvas = self.ReuseCanvas1
	local pongCanvas = self.ReuseCanvas2


	-- set ambient occlusion canvas as render target, and draw ambient occlusion data to the AO canvas
	love.graphics.setCanvas(pingCanvas)
	love.graphics.setShader(self.SSAOShader)
	--self.SSAOShader:send("normalTexture", self.NormalCanvas)
	love.graphics.draw(self.DepthCanvas, 0, 0, 0, 1 / self.MSAA, 1 / self.MSAA) -- set the ambient occlusion shader in motion


	
	-- apply horizontal and vertical gaussian blur in two passes, using the reuse canvas to draw to that, and then back to the ambient occlusion canvas
	love.graphics.setCanvas(pongCanvas)
	love.graphics.setShader(self.AOBlurShader)
	--self.AOBlurShader:send("depthTexture", self.DepthCanvas)
	self.AOBlurShader:send("blurDirection", {1, 0})
	love.graphics.draw(pingCanvas)
	love.graphics.setCanvas(pingCanvas)
	self.AOBlurShader:send("blurDirection", {0, 1})
	love.graphics.draw(pongCanvas)
	


	-- now blend the ambient occlusion result with whatever has been drawn already
	love.graphics.setCanvas(self.PrepareCanvas)
	love.graphics.clear()
	love.graphics.setShader(self.SSAOBlendShader) -- set the blend shader so we can apply ambient occlusion to the render canvas
	-- TODO: no need to send over pingCanvas each frame since it's a reference. You can do this elsewhere
	--self.SSAOBlendShader:send("aoTexture", pingCanvas) -- send over the rendered result from the ambient occlusion shader so we can sample it in the blend shader
	love.graphics.draw(self.RenderCanvas)


	-- copy result to render canvas
	love.graphics.setShader()
	love.graphics.setCanvas(self.RenderCanvas)
	love.graphics.draw(self.PrepareCanvas)

	-- revert canvas state
	love.graphics.setShader(self.Shader)
	love.graphics.setCanvas({self.RenderCanvas, self.NormalCanvas, self.BloomCanvas, ["depthstencil"] = self.DepthCanvas})
	

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




function Scene3:updateShadowMap(firstPass)
	-- prepare for drawing
	love.graphics.setMeshCullMode("none") -- "front" can be used to fix peter-panning, but prevents the backfaces from having any shadows!! that's why we set to "none"
	love.graphics.setDepthMode("lequal", true)
	love.graphics.setShader(self.ShadowMapShader)
	love.graphics.setCanvas({["depthstencil"] = self.ShadowDepthCanvas})

	
	
	if firstPass then -- first pass, which excludes foliage

		love.graphics.clear() -- we should clear since if you remove an object, the shadow in that area won't get overwritten
		-- render all meshes and instanced meshes that have shadows enabled to the shadow canvas
		local Mesh
		-- isInstanced should still be true from the second pass
		--self.ShadowMapShader:send("isInstanced", true)
		self.ShadowMapShader:send("meshTexture", blankImage) -- for instanced meshes, assume texture is opaque (otherwise you'd use foliage3)
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
				self.ShadowMapShader:send("meshTexture", Mesh.Texture or blankImage)
				self.ShadowMapShader:send("meshPosition", Mesh.Position:array())
				self.ShadowMapShader:send("meshRotation", Mesh.Rotation:array())
				self.ShadowMapShader:send("meshScale", Mesh.Scale:array())
				love.graphics.draw(Mesh.Mesh)
			end
		end

	else -- second pass, which includes foliage

		self.ShadowMapShader:send("isInstanced", true)
		for i = 1, #self.Foliage do -- foliage is always instanced
			Mesh = self.Foliage[i]
			if Mesh.CastShadow then
				self.ShadowMapShader:send("meshTexture", Mesh.Texture or blankImage) -- foliage will have alpha clipping, so sending over image is important
				love.graphics.drawInstanced(Mesh.Mesh, Mesh.Count)
			end
		end

	end

	-- revert peter-panning
	love.graphics.setMeshCullMode("back")
end



local particleMixShader = love.graphics.newShader(
	[[
		uniform Image countCanvas;

		vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
			vec4 data = Texel(countCanvas, texture_coords);

			vec4 canvColor = Texel(tex, texture_coords);
			float pixelsOnFrag = data.r;
			float sumAlpha = data.g; // alphas were squared, so we gotta compensate down below

			float avgAlpha = sumAlpha / max(1.0, pixelsOnFrag);
			float newAlpha = 1.0 - pow(1.0 - pow(avgAlpha, 0.5), pixelsOnFrag); // use sqrt to compensate for squaring when adding to the colorCanvas

			return vec4(canvColor.rgb / sumAlpha, newAlpha);
		}
	]]
)



function Scene3:drawParticles()
	local blendMode, alphaMode = love.graphics.getBlendMode()

	--particleMixShader:send("colorCanvas", self.ParticleCanvas1)
	--particleMixShader:send("countCanvas", self.ParticleCanvas2)

	
	local comp, write = love.graphics.getDepthMode()

	-- draw any particles that have no blending whatsoever directly to the render canvas. Typically these are fully opaque particles
	love.graphics.setShader(self.ParticlesShader)
	love.graphics.setCanvas({self.RenderCanvas, ["depthstencil"] = self.DepthCanvas}) -- draw directly to the scene
	love.graphics.setDepthMode("less", true) -- front-most non-blending particles appear on top
	self.ParticlesShader:send("blends", false)
	for i = 1, #self.Particles do
		if not self.Particles[i].Blends then
			self.Particles[i]:draw(self.ParticlesShader)
		end
	end
	


	-- start accumulating color of any particles that 'blend'
	love.graphics.setCanvas({self.ParticleCanvas1, self.ParticleCanvas2})
	love.graphics.clear(0, 0, 0, 1)
	love.graphics.setCanvas({self.ParticleCanvas1, self.ParticleCanvas2, ["depthstencil"] = self.DepthCanvas})
	love.graphics.setDepthMode("less", false)
	love.graphics.setBlendMode("add")
	self.ParticlesShader:send("blends", true)
	for i = 1, #self.Particles do
		if self.Particles[i].Blends then
			self.Particles[i]:draw(self.ParticlesShader)
		end
	end

	-- start blending the particles that have blends=true onto the render canvas
	-- we draw to the render canvas using default blend settings, but the shader itself will 'blend' the particle fragments with each other during the write operation
	love.graphics.setCanvas({self.RenderCanvas})
	love.graphics.setBlendMode(blendMode, alphaMode)
	love.graphics.setDepthMode("always", false) -- don't set depth, but do compare against it so they don't appear in front of stuff
	--love.graphics.setDepthMode("always", false)
	love.graphics.setShader(particleMixShader)
	--love.graphics.setShader()
	love.graphics.setColor(1, 1, 1, 1)
	--love.graphics.rectangle("fill", 0, 0, self.RenderCanvas:getWidth(), self.RenderCanvas:getHeight())
	love.graphics.draw(self.ParticleCanvas1)
	love.graphics.setDepthMode(comp, write)

	-- no need to reset the shader here as it's done literally the next line after returning from this function
end






function Scene3:draw(renderTarget, x, y) -- nil or a canvas
	if x == nil then x = 0 end
	if y == nil then y = 0 end
	-- get some graphics settings so they can be reverted later
	local prevCanvas = love.graphics.getCanvas()
	local prevDepthMode, prevWrite = love.graphics.getDepthMode()

	profiler:pushLabel("scene3")
	
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
		self.AOBlurShader:send("screenSize", {width, height})
		self.BloomBlurShader:send("screenSize", {width, height})
	end


	profiler:pushLabel("upd-light")

	-- update lights
	local lightsInfo = {}
	if self.LightsDirty then
		for _, light in ipairs(self.Lights) do -- {posX, posY, posZ, range}, {colR, colG, colB, strength}
			table.insert(lightsInfo, {light.Position.x, light.Position.y, light.Position.z, light.Range})
			table.insert(lightsInfo, {light.Color.r, light.Color.g, light.Color.b, light.Strength})
		end
		self.LightsDirty = false
	end
	
	if #lightsInfo > 0 then
		self.Shader:send("lightsInfo", unpack(lightsInfo))
		self.TriplanarShader:send("lightsInfo", unpack(lightsInfo))
		self.FoliageShader:send("lightsInfo", unpack(lightsInfo))
		self.ParticlesShader:send("lightsInfo", unpack(lightsInfo))
		self.TriplanarShader:send("lightsInfo", unpack(lightsInfo))
	end

	-- update blob shadows
	local blobsInfo = {}
	if self.BlobsDirty then
		for _, blob in ipairs(self.Blobs) do
			table.insert(blobsInfo, {blob.Position.x, blob.Position.y, blob.Position.z, blob.Range})
		end
		self.BlobsDirty = false
	end
	if #blobsInfo > 0 then
		self.Shader:send("blobShadows", unpack(blobsInfo))
		self.TriplanarShader:send("blobShadows", unpack(blobsInfo))
		self.FoliageShader:send("blobShadows", unpack(blobsInfo))
		self.TriplanarShader:send("blobShadows", unpack(blobsInfo))
	end

	profiler:popLabel()


	-- if a shadow canvas is set, it means shadow mapping is turned on
	if self.ShadowCanvas ~= nil then
		profiler:pushLabel("shadow")
		self:updateShadowMap(true)
		profiler:popLabel()
	end


	-- set render canvas as target and clear it so a normal image can be drawn to it
	--love.graphics.setCanvas({self.RenderCanvas, self.NormalCanvas, ["depthstencil"] = self.DepthCanvas}) -- set the main canvas so it can be cleared
	profiler:pushLabel("clear")
	love.graphics.setCanvas({self.RenderCanvas, ["depthstencil"] = self.DepthCanvas})
	love.graphics.clear()
	love.graphics.setCanvas(self.BloomCanvas)
	love.graphics.clear(0, 0, 0)
	love.graphics.setCanvas(self.RenderCanvas) -- set the canvas to only be the render canvas so the background doesn't accidentally initialize anything in the normal canvas
	profiler:popLabel()

	local renderWidth, renderHeight = self.RenderCanvas:getDimensions()

	-- draw the background
	if self.Background then
		profiler:pushLabel("bg")
		love.graphics.setShader() -- needs to be reset because shadow map might be enabled
		love.graphics.setDepthMode("always", false)
		local imgWidth, imgHeight = self.Background:getDimensions()
		love.graphics.draw(self.Background, 0, 0, 0, renderWidth / imgWidth, renderHeight / imgHeight)
		profiler:popLabel()
	end

	-- prep render settings
	love.graphics.setCanvas({self.RenderCanvas, self.NormalCanvas, self.BloomCanvas, ["depthstencil"] = self.DepthCanvas}) -- set the main canvas with proper maps for geometry being drawn
	love.graphics.setDepthMode("less", true)
	love.graphics.setMeshCullMode("back")

	-- using 'replace' w/ premultiplied so we can set the normals to some rgb even though we also write alpha=0. Otherwise, rgb would get multiplied by alpha!
	-- and coincidentally this just kind of works because foliage has an all-or-nothing either draw opaque pixels, or discard them!!
	local blendMode = love.graphics.getBlendMode()
	love.graphics.setBlendMode("replace", "premultiplied")

	-- foliage is drawn first thing after the first shadowmap pass to prevent foliage from having self-shadows
	profiler:pushLabel("foliage")
	if #self.Foliage > 0 then
		love.graphics.setShader(self.FoliageShader)
		local Mesh = nil
		for i = 1, #self.Foliage do
			Mesh = self.Foliage[i]
			self.FoliageShader:send("meshTexture", Mesh.Texture or blankImage)
			self.FoliageShader:send("normalMap", Mesh.NormalMap or normalImage)
			self.FoliageShader:send("meshBrightness", Mesh.Brightness)
			love.graphics.drawInstanced(Mesh.Mesh, Mesh.Count)
		end
		--love.graphics.setShader(self.Shader)
	end
	profiler:popLabel()

	love.graphics.setBlendMode(blendMode)


	-- second shadowmap pass, this time it draws the foliage to the shadow canvas
	if self.ShadowCanvas ~= nil then
		profiler:pushLabel("shadow")
		self:updateShadowMap(false)
		love.graphics.setCanvas({self.RenderCanvas, self.NormalCanvas, self.BloomCanvas, ["depthstencil"] = self.DepthCanvas})
		profiler:popLabel()
	end


	love.graphics.setShader(self.Shader)

	

	
	local TransMeshes = {} -- create new array to put all basic meshes in that have a Transparency > 0. Their rendering is postponed. They will be sorted later

	self.Shader:send("currentTime", love.timer.getTime())

	-- draw instanced (basic) meshes
	if #self.InstancedMeshes > 0 then
		profiler:pushLabel("inst")
		local Mesh = nil
		self.Shader:send("uvVelocity", {0, 0})
		self.Shader:send("meshTransparency", 0)
		self.Shader:send("isInstanced", true) -- tell the shader to use the attributes to calculate the model matrices
		for i = 1, #self.InstancedMeshes do
			Mesh = self.InstancedMeshes[i]
			self.Shader:send("meshTexture", Mesh.Texture or blankImage)
			self.Shader:send("normalMap", Mesh.NormalMap or normalImage)
			self.Shader:send("meshBrightness", Mesh.Brightness)
			self.Shader:send("meshBloom", Mesh.Bloom)
			self.Shader:send("meshFresnel", {Mesh.FresnelStrength, Mesh.FresnelPower})
			self.Shader:send("meshFresnelColor", {Mesh.FresnelColor.r, Mesh.FresnelColor.g, Mesh.FresnelColor.b})
			--self.Shader:send("triplanarScale", Mesh.IsTriplanar and Mesh.TextureScale or 0)
			love.graphics.drawInstanced(Mesh.Mesh, Mesh.Count)
		end
		profiler:popLabel()
	end

	-- then draw all *opaque* basic meshes
	if #self.BasicMeshes > 0 then
		profiler:pushLabel("mesh")
		local Mesh = nil
		self.Shader:send("meshTransparency", 0) -- >0 transparency meshes are postponed until later
		self.Shader:send("isInstanced", false) -- tell the shader to use the meshPosition, meshRotation, meshScale and meshColor uniforms to calculate the model matrices
		for i = 1, #self.BasicMeshes do
			Mesh = self.BasicMeshes[i]
			if Mesh.Transparency == 0 then
				self.Shader:send("normalMap", Mesh.NormalMap or normalImage)
				self.Shader:send("uvVelocity", Mesh.UVVelocity:array())
				self.Shader:send("meshTexture", Mesh.Texture or blankImage)
				self.Shader:send("meshPosition", Mesh.Position:array())
				self.Shader:send("meshRotation", Mesh.Rotation:array())
				self.Shader:send("meshScale", Mesh.Scale:array())
				self.Shader:send("meshColor", Mesh.Color:array())
				self.Shader:send("meshBrightness", Mesh.Brightness)
				self.Shader:send("meshBloom", Mesh.Bloom)
				self.Shader:send("meshFresnel", {Mesh.FresnelStrength, Mesh.FresnelPower})
				self.Shader:send("meshFresnelColor", {Mesh.FresnelColor.r, Mesh.FresnelColor.g, Mesh.FresnelColor.b})
				--self.Shader:send("triplanarScale", Mesh.IsTriplanar and Mesh.TextureScale or 0)
				love.graphics.draw(Mesh.Mesh)
			elseif Mesh.Transparency < 1 or Mesh.FresnelStrength > 0 then -- ignore meshes with transparency == 1 (unless they have fresnel)
				table.insert(TransMeshes, Mesh)
			end
		end
		profiler:popLabel()
	end


	-- TODO: draw triplanar meshes here (and postpone trip3 meshes that are semi-transparent, or fully transparent with fresnel)
	if #self.InstancedTrip3 > 0 then
		profiler:pushLabel("inst-trip")
		love.graphics.setShader(self.TriplanarShader)
		local Mesh = nil
		--self.TriplanarShader:send("currentTime", love.timer.getTime())
		--self.TriplanarShader:send("uvVelocity", {0, 0})
		self.TriplanarShader:send("meshTransparency", 0)
		self.TriplanarShader:send("isInstanced", true) -- tell the shader to use the attributes to calculate the model matrices
		for i = 1, #self.InstancedTrip3 do
			Mesh = self.InstancedTrip3[i]
			self.TriplanarShader:send("meshTexture", Mesh.Texture or blankImage)
			self.TriplanarShader:send("normalMap", Mesh.NormalMap or normalImage)
			self.TriplanarShader:send("meshBrightness", Mesh.Brightness)
			self.TriplanarShader:send("meshBloom", Mesh.Bloom)
			self.TriplanarShader:send("meshFresnel", {Mesh.FresnelStrength, Mesh.FresnelPower})
			self.TriplanarShader:send("meshFresnelColor", {Mesh.FresnelColor.r, Mesh.FresnelColor.g, Mesh.FresnelColor.b})
			self.TriplanarShader:send("triplanarScale", Mesh.TextureScale)
			love.graphics.drawInstanced(Mesh.Mesh, Mesh.Count)
		end
		profiler:popLabel()
	end


	-- then draw all *opaque* triplanar meshes
	if #self.BasicTrip3 > 0 then
		profiler:pushLabel("mesh-trip")
		local Mesh = nil
		self.Shader:send("meshTransparency", 0) -- >0 transparency meshes are postponed until later
		self.Shader:send("isInstanced", false) -- tell the shader to use the meshPosition, meshRotation, meshScale and meshColor uniforms to calculate the model matrices
		for i = 1, #self.BasicTrip3 do
			Mesh = self.BasicTrip3[i]
			if Mesh.Transparency == 0 then
				self.Shader:send("normalMap", Mesh.NormalMap or normalImage)
				self.Shader:send("uvVelocity", Mesh.UVVelocity:array())
				self.Shader:send("meshTexture", Mesh.Texture or blankImage)
				self.Shader:send("meshPosition", Mesh.Position:array())
				self.Shader:send("meshRotation", Mesh.Rotation:array())
				self.Shader:send("meshScale", Mesh.Scale:array())
				self.Shader:send("meshColor", Mesh.Color:array())
				self.Shader:send("meshBrightness", Mesh.Brightness)
				self.Shader:send("meshBloom", Mesh.Bloom)
				self.Shader:send("meshFresnel", {Mesh.FresnelStrength, Mesh.FresnelPower})
				self.Shader:send("meshFresnelColor", {Mesh.FresnelColor.r, Mesh.FresnelColor.g, Mesh.FresnelColor.b})
				self.Shader:send("triplanarScale", Mesh.TextureScale)
				love.graphics.draw(Mesh.Mesh)
			elseif Mesh.Transparency < 1 or Mesh.FresnelStrength > 0 then -- ignore meshes with transparency == 1 (unless they have fresnel)
				table.insert(TransMeshes, Mesh)
			end
		end
		profiler:popLabel()
	end

	
	
	if #self.RippleMeshes > 0 then
		profiler:pushLabel("ripple")
		love.graphics.setShader(self.RippleShader)
		self.RippleShader:send("currentTime", love.timer.getTime())
		for i = 1, #self.RippleMeshes do
			local RMesh = self.RippleMeshes[i]
			self.RippleShader:send("meshTexture", RMesh.Texture or blankImage)
			self.RippleShader:send("meshPosition", RMesh.Position:array())
			self.RippleShader:send("meshRotation", RMesh.Rotation:array())
			self.RippleShader:send("meshScale", RMesh.Scale:array())
			self.RippleShader:send("meshColor", {RMesh.Color.r, RMesh.Color.g, RMesh.Color.b})
			self.RippleShader:send("meshBrightness", RMesh.Brightness)
			self.RippleShader:send("meshBloom", RMesh.Bloom)
			self.RippleShader:send("meshFresnel", {RMesh.FresnelStrength, RMesh.FresnelPower})
			self.RippleShader:send("meshFresnelColor", {RMesh.FresnelColor.r, RMesh.FresnelColor.g, RMesh.FresnelColor.b})
			self.RippleShader:send("dataMap", RMesh.DataMap or dataImage)
			self.RippleShader:send("foamInShadow", RMesh.FoamInShadow)
			self.RippleShader:send("foamColor", {RMesh.FoamColor.r, RMesh.FoamColor.g, RMesh.FoamColor.b})
			self.RippleShader:send("waterVelocity", RMesh.WaterVelocity:array())
			self.RippleShader:send("foamVelocity", RMesh.FoamVelocity:array())
			love.graphics.draw(RMesh.Mesh)
		end
		profiler:popLabel()
	end



	-- apply ambient occlusion to geometry so far (which excludes semi-transparent meshes, sprite meshes & foliage)
	if self.AOEnabled then
		profiler:pushLabel("ao")
		love.graphics.setDepthMode("always", false)
		self:applyAmbientOcclusion()
		love.graphics.setDepthMode("less", true)
		profiler:popLabel()
	end

	love.graphics.setShader(self.Shader)

	-- repeat the mesh drawing process, but for *opaque* spritemeshes
	if #self.SpriteMeshes > 0 then
		profiler:pushLabel("spr-mesh")
		local Mesh = nil
		self.Shader:send("uvVelocity", {0, 0}) -- sprite meshes have no uv scrolling
		--self.Shader:send("triplanarScale", 0)
		self.Shader:send("meshFresnel", {0, 1}) -- no need to update fresnelColor since fresnel strength == 0 disables it already
		self.Shader:send("isSpriteSheet", true) -- but they do need isSpriteSheet set to true for correct texture mapping
		for i = 1, #self.SpriteMeshes do
			Mesh = self.SpriteMeshes[i]
			if Mesh.Transparency == 0 then
				self.Shader:send("meshTexture", Mesh.Texture or blankImage)
				self.Shader:send("meshPosition", Mesh.Position:array())
				self.Shader:send("meshRotation", Mesh.Rotation:array())
				self.Shader:send("meshScale", Mesh.Scale:array())
				self.Shader:send("meshColor", Mesh.Color:array())
				self.Shader:send("meshBrightness", Mesh.Brightness)
				self.Shader:send("meshBloom", Mesh.Bloom)
				self.Shader:send("spritePosition", {Mesh.SpritePosition.x - 1, Mesh.SpritePosition.y - 1})
				self.Shader:send("spriteSheetSize", Mesh.SheetSize:array())
				love.graphics.draw(Mesh.Mesh)
			elseif Mesh.Transparency < 1 then -- ignore meshes with transparency == 1
				table.insert(TransMeshes, Mesh)
			end
		end
		self.Shader:send("isSpriteSheet", false)
		profiler:popLabel()
	end



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
	if #TransMeshes > 0 then
		profiler:pushLabel("trans")
		local Mesh = nil
		local Shader = nil
		for i = 1, #TransMeshes do

			Mesh = TransMeshes[i]

			-- smartly switch shader based on mesh type, trying to avoid unnecessary switches whenever possible
			if (mesh3.isMesh3(Mesh) or spritemesh3.isSpritemesh3(Mesh)) and Shader ~= self.Shader then
				Shader = self.Shader
				love.graphics.setShader(Shader)

				-- need to add a small check here to distinguish between basic meshes and sprite meshes since they have somewhat different properties
				if mesh3.isMesh3(Mesh) then
					Shader:send("normalMap", Mesh.NormalMap or normalImage)
					Shader:send("isSpriteSheet", false)
					Shader:send("uvVelocity", Mesh.UVVelocity:array())
				else
					Shader:send("isSpriteSheet", true)
					Shader:send("uvVelocity", {0, 0})
					Shader:send("spritePosition", Mesh.SpritePosition)
					Shader:send("spriteSheetSize", Mesh.SheetSize)
				end

			elseif (trip3.isTrip3(Mesh)) and Shader ~= self.TriplanarShader then
				Shader = self.TriplanarShader
				love.graphics.setShader(Shader)

				Shader:send("normalMap", Mesh.NormalMap or normalImage)
				Shader:send("triplanarScale", Mesh.TextureScale)
			end

			Shader:send("meshTexture", Mesh.Texture or blankImage)
			Shader:send("meshPosition", Mesh.Position:array())
			Shader:send("meshRotation", Mesh.Rotation:array())
			Shader:send("meshScale", Mesh.Scale:array())
			Shader:send("meshColor", Mesh.Color:array())
			Shader:send("meshBrightness", Mesh.Brightness)
			Shader:send("meshBloom", Mesh.Bloom)
			Shader:send("meshFresnel", {Mesh.FresnelStrength, Mesh.FresnelPower})
			Shader:send("meshFresnelColor", {Mesh.FresnelColor.r, Mesh.FresnelColor.g, Mesh.FresnelColor.b})
			Shader:send("meshTransparency", Mesh.Transparency) -- now we can finally include transparency since these meshes are drawn in painter's algorithm order

			love.graphics.draw(Mesh.Mesh)
		end
		profiler:popLabel()
	end
	

	

	if self.BloomStrength > 0 then
		profiler:pushLabel("bloom")
		love.graphics.setDepthMode("always", false)
		self:applyBloom()
		love.graphics.setDepthMode("less", true)
		profiler:popLabel()
	end

	-- disable culling for particles so they can be seen from both sides
	love.graphics.setMeshCullMode("none")

	if #self.Particles > 0 then
		-- now draw all the particles in the scene
		profiler:pushLabel("particles")
		self:drawParticles()
		profiler:popLabel()
	end

	-- setShader() can be called here since if self.Foreground ~= nil then setting setShader() in there makes no sense since the shader will be set to nil anyway right after when drawing the canvas to the screen
	love.graphics.setShader()

	-- draw the foreground
	if self.Foreground then
		profiler:pushLabel("fg")
		love.graphics.setDepthMode("always", false)
		local imgWidth, imgHeight = self.Foreground:getDimensions()
		love.graphics.draw(self.Foreground, 0, 0, 0, renderWidth / imgWidth, renderHeight / imgHeight)
		profiler:popLabel()
	end

	-- reset the canvas to the render target & render the scene
	profiler:pushLabel("write")
	love.graphics.setCanvas(renderTarget)
	if renderTarget ~= nil then
		love.graphics.clear()
		-- if a render target is set, adjust the scaling so that it fits inside the render target
		local scaleX = renderTarget:getWidth() / self.RenderCanvas:getWidth()
		local scaleY = renderTarget:getHeight() / self.RenderCanvas:getHeight()
		local scaleX = 1 / self.MSAA
		local scaleY = 1 / self.MSAA
		-- a pretty important caveat here: if you are drawing to a render target it's VERY RECOMMENDED that the render target has the same dimensions as the screen
		-- if your render target is smaller however, e.g. when using split-screen, you should 100% call Scene3:rescaleCanvas() with your target width and height.
		-- because if you are drawing to a smaller render canvas but the scene has a fullscreen render canvas, you're tanking your FPS for no reason (better anti-aliasing though I guess)
		love.graphics.draw(self.RenderCanvas, x, renderTarget:getHeight() * scaleY + y, 0, scaleX, -scaleY)
	else
		-- if no render target is set, the scene is drawn to the screen, so use the screen's dimensions
		--local scaleX = love.graphics.getWidth() / self.RenderCanvas:getWidth()
		--local scaleY = love.graphics.getHeight() / self.RenderCanvas:getHeight()
		local scaleX = 1 / self.MSAA
		local scaleY = 1 / self.MSAA
		love.graphics.draw(self.RenderCanvas, x, self.RenderCanvas:getHeight() * scaleY + y, 0, scaleX, -scaleY)
	end
	profiler:popLabel()
	

	-- revert some graphics settings
	love.graphics.setCanvas(prevCanvas)
	love.graphics.setDepthMode(prevDepthMode, prevWrite)

	profiler:popLabel()
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
	self.MSAA = msaa

	if width == nil or height == nil then
		width, height = love.graphics.getDimensions()
	else
		width = math.floor(width)
		height = math.floor(height)
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
			["format"] = "depth24";
			["readable"] = true;
		}
	)
	depthCanvas:setFilter("nearest")
	local normalCanvas = love.graphics.newCanvas(width * msaa, height * msaa)
	local prepareCanvas = love.graphics.newCanvas(width * msaa, height * msaa)
	prepareCanvas:setFilter("nearest")
	local bloomCanvas = love.graphics.newCanvas(width * msaa, height * msaa)
	bloomCanvas:setFilter("nearest")
	local particleCanvas1 = love.graphics.newCanvas( -- sums up colors and alpha
		width * msaa,
		height * msaa,
		{
			["format"] = "rgba16f";
			["readable"] = true;
		}
	)
	local particleCanvas2 = love.graphics.newCanvas( -- keeps track of particle count per pixel
		width * msaa,
		height * msaa,
		{
			["format"] = "rgba16f"; -- red stores particle count, green stores sum alpha
			["readable"] = true;
		}
	)

	local reuseCanvas1 = love.graphics.newCanvas(width, height)
	local reuseCanvas2 = love.graphics.newCanvas(width, height)
	local reuseCanvas3 = love.graphics.newCanvas(width * 0.5, height * 0.5)
	local reuseCanvas4 = love.graphics.newCanvas(width * 0.5, height * 0.5)
	local reuseCanvas5 = love.graphics.newCanvas(width * 0.25, height * 0.25)
	local reuseCanvas6 = love.graphics.newCanvas(width * 0.25, height * 0.25)

	-- update ambient occlusion canvas references
	self.AOBlurShader:send("depthTexture", depthCanvas)
	self.SSAOShader:send("normalTexture", normalCanvas)
	self.SSAOBlendShader:send("aoTexture", reuseCanvas1) -- pingCanvas

	self.RenderCanvas = renderCanvas
	self.DepthCanvas = depthCanvas
	self.NormalCanvas = normalCanvas
	self.PrepareCanvas = prepareCanvas
	self.BloomCanvas = bloomCanvas
	self.ParticleCanvas1 = particleCanvas1
	self.ParticleCanvas2 = particleCanvas2
	self.ReuseCanvas1 = reuseCanvas1
	self.ReuseCanvas2 = reuseCanvas2
	self.ReuseCanvas3 = reuseCanvas3
	self.ReuseCanvas4 = reuseCanvas4
	self.ReuseCanvas5 = reuseCanvas5
	self.ReuseCanvas6 = reuseCanvas6

	-- update aspect ratio of the scene
	local aspectRatio = width / height
	self.Shader:send("aspectRatio", aspectRatio)
	self.TriplanarShader:send("aspectRatio", aspectRatio)
	self.RippleShader:send("aspectRatio", aspectRatio)
	self.FoliageShader:send("aspectRatio", aspectRatio)
	self.ParticlesShader:send("aspectRatio", aspectRatio)

	-- calculate perspective matrix for the SSAO shader
	if self.Camera3 ~= nil then
		local persp = matrix4.perspective(aspectRatio, self.Camera3.FieldOfView, 1000, 0.1)
		local c1, c2, c3, c4 = persp:columns()
		self.SSAOShader:send("perspectiveMatrix", {c1, c2, c3, c4})
	end

	-- misc
	self.ParticleMixShader:send("countCanvas", particleCanvas2)
	self.SSAOBlendShader:send("normalsTexture", normalCanvas) -- needed to sample alpha channel to check if ambient occlusion should be applied
end







function Scene3:setAmbient(col, occlusionColor)
	local arr = {col.r, col.g, col.b}
	self.Shader:send("ambientColor", arr)
	self.TriplanarShader:send("ambientColor", arr)
	self.ParticlesShader:send("ambientColor", arr)
	self.RippleShader:send("ambientColor", arr)
	self.FoliageShader:send("ambientColor", arr)
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
		-- send over textures for sampling
		--self.AOBlurShader:send("depthTexture", self.DepthCanvas)
		--self.SSAOShader:send("normalTexture", self.NormalCanvas)
		--self.SSAOBlendShader:send("aoTexture", self.ReuseCanvas1) -- pingCanvas
	end
end


function Scene3:setAOQuality(quality)
	assert(quality == 1 or quality == 0.5 or quality == 0.25, "Scene3:setAOQuality(quality) requires argument 'quality' to be 1, 0.5 or 0.25.")
	self.AOQuality = quality
	self.SSAOShader:send("samples", quality == 1 and 24 or (quality == 0.5 and 16 or 8))
end



function Scene3:setDiffuse(strength)
	self.Shader:send("diffuseStrength", strength)
	self.TriplanarShader:send("diffuseStrength", strength)
	self.FoliageShader:send("diffuseStrength", strength)
end


function Scene3:setBlobColor(col)
	self.Shader:send("blobShadowColor", {col.r, col.g, col.b})
	self.TriplanarShader:send("blobShadowColor", {col.r, col.g, col.b})
end

function Scene3:setBlobStrength(strength)
	self.Shader:send("blobShadowStrength", strength)
	self.TriplanarShader:send("blobShadowStrength", strength)
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
		self.TriplanarShader:send("shadowsEnabled", false)
		self.RippleShader:send("shadowsEnabled", false)
		self.FoliageShader:send("shadowsEnabled", false)
		self.ParticlesShader:send("shadowsEnabled", false)
	else
		assert(vector3.isVector3(position), "Scene3:setShadowMap(position, direction, size, canvasSize, sunColor, shadowStrength) requires argument 'position' to be a vector3.")
		assert(vector3.isVector3(direction), "Scene3:setShadowMap(position, direction, size, canvasSize, sunColor, shadowStrength) requires argument 'direction' to be a vector3.")
		assert(vector2.isVector2(size), "Scene3:setShadowMap(position, direction, size, canvasSize, sunColor, shadowStrength) requires argument 'size' to be a vector2.")
		assert(vector2.isVector2(canvasSize), "Scene3:setShadowMap(position, direction, size, canvasSize, sunColor, shadowStrength) requires argument 'canvasSize' to be a vector2.")
		assert(sunColor == nil or color.isColor(sunColor), "Scene3:setShadowMap(position, direction, size, canvasSize, sunColor, shadowStrength) requires argument 'sunColor' to be a color or nil.")
		assert(shadowStrength == nil or type(shadowStrength) == "number",
			"Scene3:setShadowMap(position, direction, size, canvasSize, sunColor, shadowStrength) requires argument 'shadowStrength' to be a number or nil.")

		self.Shader:send("shadowsEnabled", true)
		self.TriplanarShader:send("shadowsEnabled", true)
		self.RippleShader:send("shadowsEnabled", true)
		self.FoliageShader:send("shadowsEnabled", true)
		self.ParticlesShader:send("shadowsEnabled", true)

		local sunCol = (sunColor == nil) and {1, 1, 1} or {sunColor.r, sunColor.g, sunColor.b}
		self.Shader:send("sunColor", sunCol)
		self.TriplanarShader:send("sunColor", sunCol)
		self.RippleShader:send("sunColor", sunCol)
		self.FoliageShader:send("sunColor", sunCol)
		self.ParticlesShader:send("sunColor", sunCol)

		local shStrength = shadowStrength ~= nil and shadowStrength or 0.5
		self.Shader:send("shadowStrength", shStrength)
		self.TriplanarShader:send("shadowStrength", shStrength)
		self.RippleShader:send("shadowStrength", shStrength)
		self.FoliageShader:send("shadowStrength", shStrength)
		self.ParticlesShader:send("shadowStrength", shStrength)

		direction = direction:clone():norm()
		local dirTable = {direction.x, direction.y, direction.z}
		self.Shader:send("sunDirection", dirTable)
		self.TriplanarShader:send("sunDirection", dirTable)
		self.RippleShader:send("sunDirection", dirTable)
		self.FoliageShader:send("sunDirection", dirTable)
		self.ParticlesShader:send("sunDirection", dirTable)

		-- create new canvases (but only if their sizes are different from the current ones)
		-- this will make it possible to potentially move the shadowmap around every frame
		if self.ShadowCanvas == nil or self.ShadowCanvas:getWidth() ~= canvasSize.x or self.ShadowCanvas:getHeight() ~= canvasSize.y then
			local shadowCanvas = love.graphics.newCanvas(canvasSize.x, canvasSize.y)
			self.ShadowCanvas = shadowCanvas
			local shadowDepthCanvas = love.graphics.newCanvas(canvasSize.x, canvasSize.y,
				{
					["type"] = "2d";
					["format"] = "depth24";
					["readable"] = true;
				}
			)
			self.ShadowDepthCanvas = shadowDepthCanvas
			shadowDepthCanvas:setDepthSampleMode("less")

			self.Shader:send("shadowCanvas", self.ShadowDepthCanvas)
			self.TriplanarShader:send("shadowCanvas", self.ShadowDepthCanvas)
			self.RippleShader:send("shadowCanvas", self.ShadowDepthCanvas)
			self.FoliageShader:send("shadowCanvas", self.ShadowDepthCanvas)
			self.ParticlesShader:send("shadowCanvas", self.ShadowDepthCanvas) -- particleshader only needs depth canvas, not size, since we only need 1 sample

			local cSize = {canvasSize.x, canvasSize.y}
			self.Shader:send("shadowCanvasSize", cSize)
			self.TriplanarShader:send("shadowCanvasSize", cSize)
			self.RippleShader:send("shadowCanvasSize", cSize)
			self.FoliageShader:send("shadowCanvasSize", cSize)
		end

		self.ShadowMapShader:send("isInstanced", true)

		-- send over orthographic camera matrix
		local orthoMatrix = matrix4.orthographic(-size.x / 2, size.x / 2, size.y / 2, -size.y / 2, 100, 0.1) -- perspective correction matrix
		local c1, c2, c3, c4 = orthoMatrix:columns()
		local oMat = {c1, c2, c3, c4}
		self.ShadowMapShader:send("orthoMatrix", oMat)
		self.Shader:send("orthoMatrix", oMat) -- also send to main shader so we know how to sample shadow map
		self.TriplanarShader:send("orthoMatrix", oMat)
		self.RippleShader:send("orthoMatrix", oMat)
		self.FoliageShader:send("orthoMatrix", oMat)
		self.ParticlesShader:send("orthoMatrix", oMat)
		
		-- send over sun matrix
		local sunWorldMatrix = matrix4.lookAtWorld(position, direction) -- matrix of where the sun is
		local c1, c2, c3, c4 = sunWorldMatrix:columns()
		local sMat = {c1, c2, c3, c4}
		self.ShadowMapShader:send("sunWorldMatrix", sMat)
		self.Shader:send("sunWorldMatrix", sMat) -- also send to main shader so we know how to sample shadow map
		self.TriplanarShader:send("sunWorldMatrix", sMat)
		self.RippleShader:send("sunWorldMatrix", sMat)
		self.FoliageShader:send("sunWorldMatrix", sMat)
		self.ParticlesShader:send("sunWorldMatrix", sMat)

	end
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
	elseif mesh3group.isMesh3Group(mesh) then
		local index = findOrderedInsertLocation(self.InstancedMeshes, mesh)
		table.insert(self.InstancedMeshes, index, mesh)
	elseif ripplemesh3.isRipplemesh3(mesh) then
		local index = findOrderedInsertLocation(self.RippleMeshes, mesh)
		table.insert(self.RippleMeshes, index, mesh)
	elseif foliage3.isFoliage3(mesh) then
		local index = findOrderedInsertLocation(self.Foliage, mesh)
		table.insert(self.Foliage, index, mesh)
	elseif trip3.isTrip3(mesh) then
		local index = findOrderedInsertLocation(self.BasicTrip3, mesh)
		table.insert(self.BasicTrip3, index, mesh)
	elseif trip3group.isTrip3Group(mesh) then
		local index = findOrderedInsertLocation(self.InstancedTrip3, mesh)
		table.insert(self.InstancedTrip3, index, mesh)
	else
		error("Scene3:attachMesh(mesh) requires argument 'mesh' to be either a mesh3, spritemesh3, ripplemesh3, foliage3 or mesh3group")
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
	elseif mesh3group.isMesh3Group(mesh) then
		slot = findObjectInOrderedArray(mesh, self.InstancedMeshes)
		Item = table.remove(self.InstancedMeshes, slot)
	elseif ripplemesh3.isRipplemesh3(mesh) then
		slot = findObjectInOrderedArray(mesh, self.RippleMeshes)
		Item = table.remove(self.RippleMeshes, slot)
	elseif foliage3.isFoliage3(mesh) then
		slot = findObjectInOrderedArray(mesh, self.Foliage)
		Item = table.remove(self.Foliage, slot)
	elseif trip3.isTrip3(mesh) then
		slot = findObjectInOrderedArray(mesh, self.BasicTrip3)
		Item = table.remove(self.BasicTrip3, slot)
	elseif trip3group.isTrip3Group(mesh) then
		slot = findObjectInOrderedArray(mesh, self.InstancedTrip3)
		Item = table.remove(self.InstancedTrip3, slot)
	else
		error("Scene3:detachMesh(mesh) requires argument 'mesh' to be either a mesh3, mesh3group, spritemesh3, ripplemesh3, trip3 or trip3group.")
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
	self.TriplanarShader:send("lightCount", lightCount)
	self.FoliageShader:send("lightCount", lightCount)
	self.ParticlesShader:send("lightCount", lightCount)

	if #self.Lights > lightCount then
		print("Scene3:attachLight(light) added a light that will not display as there are already 16 or more lights in the scene.")
	end

	if self.Events.LightAttached then
		connection.doEvents(self.Events.LightAttached, light)
	end

	self.LightsDirty = true

	return light
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
		self.TriplanarShader:send("lightCount", lightCount)
		self.FoliageShader:send("lightCount", lightCount)
		self.ParticlesShader:send("lightCount", lightCount)

		if self.Events.LightDetached then
			connection.doEvents(self.Events.LightDetached, Item)
		end

		self.LightsDirty = true

		return true
	end
	return false
end




function Scene3:attachBlob(blob)
	assert(blob3.isBlob3(blob), "Scene3:attachBlob(blob) requires argument 'blob' to be a blob3.")
	if blob.Scene ~= nil then
		blob:detach()
	end

	local index = findOrderedInsertLocation(self.Blobs, blob)
	table.insert(self.Blobs, index, blob)
	blob.Scene = self

	local blobCount = math.min(#self.Blobs, 16)
	self.Shader:send("blobShadowCount", blobCount)
	self.TriplanarShader:send("blobShadowCount", blobCount)

	if #self.Lights > blobCount then
		print("Scene3:attachBlob(blob) added a blob3 that will not display as there are already 16 or more blobs in the scene.")
	end

	if self.Events.BlobAttached then
		connection.doEvents(self.Events.BlobAttached, blob)
	end

	self.BlobsDirty = true

	return blob
end



function Scene3:detachBlob(blobOrSlot)
	if type(blobOrSlot) ~= "number" then -- object was passed
		assert(blob3.isBlob3(blobOrSlot), "Scene3:detachBlob(blobOrSlot) requires argument 'blobOrSlot' to be either a blob3 or an integer")
		blobOrSlot = findObjectInOrderedArray(blobOrSlot, self.Lights)
	end
	local Item = table.remove(self.Blobs, blobOrSlot)
	if Item ~= nil then
		Item.Scene = nil

		local blobCount = math.min(#self.Blobs, 16)
		self.Shader:send("blobShadowCount", blobCount)
		self.TriplanarShader:send("blobShadowCount", blobCount)

		if self.Events.BlobDetached then
			connection.doEvents(self.Events.BlobDetached, Item)
		end

		self.BlobsDirty = true

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
	--[[
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
			["format"] = "depth24";
			["readable"] = true;
		}
	)
	depthCanvas:setFilter("nearest")
	local normalCanvas = love.graphics.newCanvas(gWidth * msaa, gHeight * msaa)
	local prepareCanvas = love.graphics.newCanvas(gWidth * msaa, gHeight * msaa)
	prepareCanvas:setFilter("nearest")
	local bloomCanvas = love.graphics.newCanvas(gWidth * msaa, gHeight * msaa)
	bloomCanvas:setFilter("nearest")
	local particleCanvas1 = love.graphics.newCanvas( -- sums up colors and alphas
		gWidth * msaa,
		gHeight * msaa,
		{
			["format"] = "rgba16f";
			["readable"] = true;
		}
	)
	local particleCanvas2 = love.graphics.newCanvas( -- keeps track of number of particles on a pixel
		gWidth * msaa,
		gHeight * msaa,
		{
			["format"] = "rgba16f"; -- red stores particle count, green stores sum alpha
			["readable"] = true;
		}
	)

	local reuseCanvas1 = love.graphics.newCanvas(gWidth, gHeight)
	local reuseCanvas2 = love.graphics.newCanvas(gWidth, gHeight)
	local reuseCanvas3 = love.graphics.newCanvas(gWidth * 0.5, gHeight * 0.5)
	local reuseCanvas4 = love.graphics.newCanvas(gWidth * 0.5, gHeight * 0.5)
	local reuseCanvas5 = love.graphics.newCanvas(gWidth * 0.25, gHeight * 0.25)
	local reuseCanvas6 = love.graphics.newCanvas(gWidth * 0.25, gHeight * 0.25)
	]]


	local Object = {
		["Id"] = module.TotalCreated;

		["Shader"] = love.graphics.newShader(SHADER_VERTEX_PATH, SHADER_FRAGMENT_PATH); -- SHADER_PATH
		["RippleShader"] = love.graphics.newShader(SHADER_VERTEX_PATH, SHADER_RIPPLE_PATH); -- same vertex shader, but special fragment shader
		["FoliageShader"] = love.graphics.newShader(SHADER_VERTEX_PATH, SHADER_FOLIAGE_PATH); -- same vertex shader, but special fragment shader
		["TriplanarShader"] = love.graphics.newShader(SHADER_TRIVERT_PATH, SHADER_TRIFRAG_PATH);
		["ParticlesShader"] = love.graphics.newShader(SHADER_PARTICLES_VERT, SHADER_PARTICLES_FRAG);
		["ParticleMixShader"] = particleMixShader;
		["SSAOShader"] = love.graphics.newShader(SHADER_SSAO_PATH); -- screen-space ambient occlusion shader
		["SSAOBlendShader"] = love.graphics.newShader(SHADER_SSAOBLEND_PATH); -- blend shader to blend ambient occlusion with the rendered scene
		["AOBlurShader"] = love.graphics.newShader(SHADER_AOBLUR_PATH);
		["BloomBlurShader"] = love.graphics.newShader(SHADER_BLOOMBLUR_PATH);
		["ShadowMapShader"] = love.graphics.newShader(SHADER_SHADOWMAP_PATH);

		["LastDrawSize"] = vector2(gWidth, gHeight); -- when you suddenly start drawing the scene at a different size, some shader variables need to be updated!
		["LightsDirty"] = true; -- if true, update lights data in the shaders and set this to false (until a light gets attached/detached)
		["BlobsDirty"] = true; -- same as above, but for blobs

		-- canvas properties, update whenever you change the render target
		["RenderCanvas"] = nil;--renderCanvas;
		["DepthCanvas"] = nil;--depthCanvas;
		["NormalCanvas"] = nil;--normalCanvas;
		["PrepareCanvas"] = nil;--prepareCanvas; -- higher resolution canvas for ambient occlusion & bloom, used to draw things to which are then combined with the render canvas
		["BloomCanvas"] = nil;--bloomCanvas;
		["ParticleCanvas1"] = nil;--particleCanvas1; -- stores sum of colors and sum of alpha
		["ParticleCanvas2"] = nil;--particleCanvas2; -- stores 
		["ShadowCanvas"] = nil; -- either nil, or a canvas when shadow map is enabled
		["ShadowDepthCanvas"] = nil;  -- either nil, or a canvas when shadow map is enabled
		--["ShadowCanvas"] = nil; -- either nil, or a canvas when shadow map is enabled. Static geometry is rendered to this

		-- when applying SSAO, bloom, etc. you need multiple render passes. For that purpose 'reuse' canvases are created to play ping-pong with each pass
		-- Considering that SSAO, bloom etc. might want to be downscaled for better FPS, there are canvases for full, half and quarter size
		["ReuseCanvas1"] = nil;--reuseCanvas1; -- full quality 1
		["ReuseCanvas2"] = nil;--reuseCanvas2; -- full quality 2
		["ReuseCanvas3"] = nil;--reuseCanvas3; -- half quality 1
		["ReuseCanvas4"] = nil;--reuseCanvas4; -- half quality 2
		["ReuseCanvas5"] = nil;--reuseCanvas5; -- quarter quality 1
		["ReuseCanvas6"] = nil;--reuseCanvas6; -- quarter quality 2

		["MSAA"] = msaa;
		["AOEnabled"] = false;
		["DiffuseStrength"] = 1;
		["BloomStrength"] = 0;
		["AOQuality"] = 1; -- 1 = full quality, 0.5 = half quality, 0.25 = quarter quality
		["BloomQuality"] = 1; -- 1 = full quality, 0.5 = half quality, 0.25 = quarter quality

		-- render variables
		["Background"] = bgImage; -- image, drawn first (so they appear in the back)
		["Foreground"] = fgImage;

		-- scene elements
		["Camera3"] = sceneCamera or camera3.new();
		["InstancedMeshes"] = {}; -- mesh3group array
		["BasicMeshes"] = {}; -- mesh3 array
		["InstancedTrip3"] = {}; -- trip3group array
		["BasicTrip3"] = {}; -- trip3 array
		["SpriteMeshes"] = {}; -- spritemesh3 array
		["RippleMeshes"] = {}; -- ripplemesh3 array
		["Foliage"] = {}; -- foliage3 array
		["Particles"] = {}; -- array of particle emitter instances. Particle emitters are always instanced for performance reasons
		["Lights"] = {}; -- array with lights that have a Position, Color, Range and Strength
		["Blobs"] = {}; -- array with blob instances that have a Position and Range (they are blob shadows you should place below spritemeshes)

		-- table with arrays of event functions stored under keys named after the events
		["Events"] = {};
	}

	setmetatable(Object, Scene3)

	Object.Camera3:attach(Object)
	Object.Camera3:updateCameraMatrices()

	Object:rescaleCanvas(nil, nil, msaa) -- call to initialize canvas variables


	--[[
	Object.AOBlurShader:send("depthTexture", Object.DepthCanvas)
	Object.SSAOShader:send("normalTexture", Object.NormalCanvas)
	Object.SSAOBlendShader:send("aoTexture", Object.ReuseCanvas1) -- pingCanvas

	-- init shader variables
	local aspectRatio = gWidth / gHeight
	Object.Shader:send("aspectRatio", aspectRatio)
	Object.RippleShader:send("aspectRatio", aspectRatio)
	Object.FoliageShader:send("aspectRatio", aspectRatio)
	Object.ParticlesShader:send("aspectRatio", aspectRatio)

	local persp = matrix4.perspective(aspectRatio, Object.Camera3.FieldOfView, 1000, 0.1)
	local c1, c2, c3, c4 = persp:columns()
	Object.SSAOShader:send("perspectiveMatrix", {c1, c2, c3, c4})

	-- misc
	particleMixShader:send("countCanvas", particleCanvas2)
	Object.SSAOBlendShader:send("normalsTexture", normalCanvas) -- needed to sample alpha channel to check if ambient occlusion should be applied
	]]

	-- non-canvas shader vars initialization
	Object.Shader:send("fieldOfView", Object.Camera3.FieldOfView)
	Object.Shader:send("diffuseStrength", 1)
	Object.Shader:send("lightCount", 0)
	Object.Shader:send("blobShadowCount", 0)
	Object.Shader:send("blobShadowColor", {0, 0, 0})
	Object.Shader:send("blobShadowStrength", 0.5)
	Object.Shader:send("ambientColor", {1, 1, 1, 1})

	Object.TriplanarShader:send("fieldOfView", Object.Camera3.FieldOfView)
	Object.TriplanarShader:send("diffuseStrength", 1)
	Object.TriplanarShader:send("lightCount", 0)
	Object.TriplanarShader:send("blobShadowCount", 0)
	Object.TriplanarShader:send("blobShadowColor", {0, 0, 0})
	Object.TriplanarShader:send("blobShadowStrength", 0.5)
	Object.TriplanarShader:send("ambientColor", {1, 1, 1, 1})

	Object.RippleShader:send("fieldOfView", Object.Camera3.FieldOfView)

	Object.FoliageShader:send("fieldOfView", Object.Camera3.FieldOfView)
	Object.FoliageShader:send("diffuseStrength", 1)
	Object.FoliageShader:send("isInstanced", true) -- send true since it uses a shared vertex shader!
	
	Object.ParticlesShader:send("fieldOfView", Object.Camera3.FieldOfView)
	Object.ParticlesShader:send("lightCount", 0)
	Object.ParticlesShader:send("ambientColor", {1, 1, 1, 1})

	Object.SSAOShader:send("aoStrength", 0.5)
	Object.SSAOShader:send("kernelScalar", 0.85) -- how 'large' ambient occlusion is
	Object.SSAOShader:send("samples", 24)
	Object.SSAOShader:send("noiseTexture", noiseImage)
	Object.SSAOBlendShader:send("occlusionColor", {0, 0, 0})

	-- bloom and AO quality shader vars
	local gWidth, gHeight = love.graphics.getDimensions()
	Object.AOBlurShader:send("screenSize", {gWidth, gHeight})
	Object.BloomBlurShader:send("screenSize", {gWidth, gHeight})
	

	return Object
end




----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

module.newScene3 = newScene3
module.isScene3 = isScene3
return setmetatable(module, {__call = function(_, ...) return newScene3(...) end})
