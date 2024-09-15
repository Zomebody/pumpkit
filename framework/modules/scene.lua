
----------------------------------------------------[[ == IMPORTS == ]]----------------------------------------------------

local connection = require("framework.connection")



----------------------------------------------------[[ == BASE OBJECTS == ]]----------------------------------------------------

local module = {
	["TotalCreated"] = 0;
}


local Scene = {}
Scene.__index = Scene
Scene.__tostring = function(tab) return "{Scene: " .. tostring(tab.Id) .. "}" end


-- a scene which has its image drawn using a SpriteBatch rather than a single image. Other than that, it works the same as a regular scene
local TiledScene = {}
TiledScene.__index = TiledScene
TiledScene.__tostring = function(tab) return "{TiledScene: " .. tostring(tab.Id) .. "}" end
setmetatable(TiledScene, Scene)



----------------------------------------------------[[ == FUNCTIONS == ]]----------------------------------------------------

-- returns the location in the array to insert a certain object into the array at
-- sorting is based on ZIndex, but in the case of a tied ZIndex the Position.y is used, where y is in ascending order
local function getObjectInsertionIndex(tab, item)
	if #tab == 0 then
		return 1
	end
	local l, r = 1, #tab
	local mid
	while l ~= r do
		mid = math.floor((l + r) / 2)
		if tab[mid].ZIndex == item.ZIndex then
			-- in case of a ZIndex tie, compare the Position.y component instead
			if tab[mid].Position.y > item.Position.y then
				r = math.max(l, mid - 1)
			else
				l = math.min(mid + 1, r)
			end
		else
			-- otherwise, compare ZIndex property
			if tab[mid].ZIndex > item.ZIndex then
				r = math.max(l, mid - 1)
			else
				l = math.min(mid + 1, r)
			end
		end
	end
	-- TODO: improve this algorithm by removing this last piece down under. See :getEntityIndex() for details (which does a slightly different assignment for variable 'mid' that removes the need for the final checks)
	if item.ZIndex == tab[l].ZIndex then
		if item.Position.y < tab[l].Position.y then
			return l
		else
			return l + 1
		end
	else
		if item.ZIndex < tab[l].ZIndex then
			return l
		else
			return l + 1
		end
	end
end



----------------------------------------------------[[ == METHODS == ]]----------------------------------------------------

-- check if an object is a scene
local function isScene(t)
	return getmetatable(t) == Scene or getmetatable(t) == TiledScene
end



function Scene:setCamera(theCamera)
	assert(camera.isCamera(theCamera), "Scene:setCamera(obj) only accepts cameras as its argument")
	self.Camera = theCamera
end


function Scene:getCamera()
	return self.Camera
end


function Scene:addEntity(Object)
	assert(entity.isEntity(Object), "Scene:addEntity(Entity) requires it argument to be of type 'entity'")
	assert(entity.Scene == nil, "Scene:addEntity(Entity) cannot add an entity that is already part of a different scene")
	
	-- log2(n) search
	local index = getObjectInsertionIndex(self.Entities, Object)
	table.insert(self.Entities, index, Object)
	Object.Scene = self
	if Object.Events.Added then
		connection.doEvents(Object.Events.Added)
	end
end


-- return the index of the entity in the Entities array
function Scene:getEntityIndex(Obj)
	-- log2(n) search!
	if #self.Entities == 0 or Obj.Scene ~= self then
		return nil
	end

	local l, r = 1, #self.Entities
	local mid = math.floor((l + r) / 2) -- if #self.Entities == 2 then this causes one extra comparison (because it should be math.ceil then) but whatever
	while l ~= r do
		if self.Entities[mid] == Obj then
			return mid
		end
		if self.Entities[mid].ZIndex == Obj.ZIndex then
			-- in case of a ZIndex tie, compare the Position.y component instead
			if self.Entities[mid].Position.y > Obj.Position.y then
				r = math.max(l, mid - 1)
				mid = math.floor((l + r) / 2)
			elseif self.Entities[mid].Position.y < Obj.Position.y then
				l = math.min(mid, r)
				mid = math.ceil((l + r) / 2)
			else -- in case of a tie on the y-axis, do a linear search towards the left and right as a last resort effort

				-- do a linear search towards the right
				local curIndex = mid + 1
				while self.Entities[curIndex] ~= Obj and curIndex <= #self.Entities do
					curIndex = curIndex + 1
				end
				if self.Entities[curIndex] == Obj then
					return curIndex
				end
				-- do a linear search towards the left
				curIndex = mid - 1
				while self.Entities[curIndex] ~= Obj and curIndex > 0 do
					curIndex = curIndex - 1
				end
				if self.Entities[curIndex] == Obj then
					return curIndex
				end
				return nil
			end
		else
			-- otherwise, compare ZIndex property
			if self.Entities[mid].ZIndex > Obj.ZIndex then
				r = math.max(l, mid - 1)
				mid = math.floor((l + r) / 2)
			else
				l = math.min(mid, r)
				mid = math.ceil((l + r) / 2)
			end
		end
	end
	if self.Entities[mid] == Obj then
		return mid
	end
	return nil
end

--[[
function Scene:removeEntity()
	-- find entity index in array
	-- remove entity from array
	-- set Entity.Scene to nil
	-- call Entity.Removed event
end
]]

-- return the entity located the given screen coordinate
function Scene:at(x, y, filter) -- filter is either 'nil' (no filter), "creature" (only check creature entities) or "prop" (only check prop entities)
	if vector2.isVector2(x) then
		filter = y
		y = x.y
		x = x.x
	end
	if self.Camera == nil then return nil end
	local worldX, worldY = self.Camera:screenPointToWorldSpace(x, y)

	-- loop through all entities (backwards) and return the first entity overlapping the current location
	-- looping backwards is used here because the last entity is drawn in front!
	local Entity
	local dx
	local dy
	for i = #self.Entities, 1, -1 do
		-- TODO: there must be a more optimal way than executing this multi-step if-statement for potentially hundreds of creatures/props in a scene
		if filter == nil or (entity.isCreature(self.Entities[i]) and filter == "creature") or (entity.isProp(self.Entities[i]) and filter == "prop") then
			Entity = self.Entities[i]
			local pivotAdjustedPosX = Entity.Position.x - Entity.Pivot.x * Entity.ShapeSize.x
			local pivotAdjustedPosY = Entity.Position.y - Entity.Pivot.y * Entity.ShapeSize.y
			dx = worldX - pivotAdjustedPosX
			dy = worldY - pivotAdjustedPosY
			if Entity.Shape == "rectangle" then
				if dx >= 0 and dx <= Entity.ShapeSize.x and dy >= 0 and dy <= Entity.ShapeSize.y then -- 'point within rectangle' check
					return Entity
				end
			elseif Entity.Shape == "ellipse" then
				local rx = Entity.ShapeSize.x / 2
				local ry = Entity.ShapeSize.y / 2
				local cx = pivotAdjustedPosX + rx
				local cy = pivotAdjustedPosY + ry
				local ellipseDx = worldX - cx
				local ellipseDy = worldY - cy
				if (ellipseDx * ellipseDx) / (rx * rx) + (ellipseDy * ellipseDy) / (ry * ry) <= 1 then -- 'point within ellipse' check
					return Entity
				end
			end
		end
	end
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


-- draw the scene based on the camera location
-- first draws the map, then the entities
function Scene:draw()
	-- the scene image starts at coordinate (0,0) and extends towards positive X (to the left) and positive Y (downwards)
	-- the camera will have its focus point centered on the middle of the screen

	-- get and apply camera transform
	local trans = self.Camera:getTransform()
	love.graphics.push()
	love.graphics.origin()
	love.graphics.applyTransform(trans)

	-- draw the scene
	if self.Background ~= nil then
		love.graphics.draw(self.Background)
	end
	self:drawEntities()
	if self.Foreground ~= nil then
		love.graphics.draw(self.Foreground)
	end

	-- reset graphics transform to previous state
	love.graphics.pop()
end


function TiledScene:draw()
	-- the scene image starts at coordinate (0,0) and extends towards positive X (to the left) and positive Y (downwards)
	-- the camera will have its focus point centered on the middle of the screen

	-- get and apply camera transform
	local trans = self.Camera:getTransform()
	love.graphics.push()
	love.graphics.origin()
	love.graphics.applyTransform(trans)

	-- draw the scene image
	love.graphics.draw(self.SpriteBatch)

	self:drawEntities()

	-- reset graphics transform to previous state
	love.graphics.pop()
end


-- outline shader shamelessly copied from https://blogs.love2d.org/content/let-it-glow-dynamically-adding-outlines-characters
local outlineShader = love.graphics.newShader([[
vec4 resultCol;
uniform vec2 thickness;
uniform vec4 outlineColor;
number alpha = 0;
vec4 selfColor;

vec4 effect(vec4 col, Image texture, vec2 texturePos, vec2 screenPos) {
	// get color of pixels:
	selfColor = texture2D(texture, texturePos) * col;
	if (selfColor.a == 0.0f) { // pixel may only be part of outline if the pixel itself is transparent
		alpha = 0;
		alpha += texture2D(texture, texturePos + vec2(thickness.x, 0.0f)).a;
		alpha += texture2D(texture, texturePos + vec2(-thickness.x, 0.0f)).a;
		alpha += texture2D(texture, texturePos + vec2(0.0f, thickness.y)).a;
		alpha += texture2D(texture, texturePos + vec2(0.0f, -thickness.y)).a;
		if (alpha > 0.0f) {
			return outlineColor;
		} else {
			return selfColor;
		}
	} else {
		return selfColor;
	}
}
]])



-- only for internal use. Used by both the TiledScene and Scene to draw their entities on screen after drawing the scene's map
-- default shader: 52 fps @ 10.000 entities
-- outline shader, 25-35 fps @ 10.000 entities if you swap shader for every entity
-- outline shader, 25-35 fps @ 10.000 entities if you only set the shader once before drawing, but apply the shader to every entity (35-40 fps if only half the entities have an outline)
-- outline shader, 40 fps @ 10.000 entities w/ 50% outlined if you only set the shader when the entity has an outline
-- outline shader, 40-ish fps @ 10.000 entities, each with an outline color from a set of 3 potential colors. Shader set once before drawing, :send() only called when the color changes
-- take-away: only apply shader when entity has an outline, avoid sending too many variables through :send()

function Scene:drawEntities()
	-- the camera transform should already be applied when this function is called!
	local Object
	--local Image, Quad
	local x, y, w, h
	local screenW, screenH = love.graphics:getDimensions()

	-- repeat the same process, but for entities
	for i = 1, #self.Entities do
		Object = self.Entities[i]
		-- check if the entity falls within the screen borders
		if  (Object.Position.x + (1 - Object.Pivot.x) * Object.Size.x	>= self.Camera.Position.x - screenW / (2 * self.Camera.Zoom)) -- OOB on the left
		and (Object.Position.x - Object.Pivot.x * Object.Size.x			<= self.Camera.Position.x + screenW / (2 * self.Camera.Zoom)) -- OOB on the right
		and (Object.Position.y + (1 - Object.Pivot.y) * Object.Size.y	>= self.Camera.Position.y - screenH / (2 * self.Camera.Zoom)) -- OOB above
		and (Object.Position.y - Object.Pivot.y * Object.Size.y			<= self.Camera.Position.y + screenH / (2 * self.Camera.Zoom)) then -- OOB below
			local Img, _ = Object:getSprite()
			if Object.OutlineThickness > 0 then
				love.graphics.setShader(outlineShader)
				outlineShader:send("outlineColor", Object.OutlineColor:array())
				outlineShader:send("thickness", {Object.OutlineThickness / Img:getWidth(), Object.OutlineThickness / Img:getHeight()})
			else
				love.graphics.setShader()
			end
			Object:draw()
		end
	end
	love.graphics.setShader()
end



----------------------------------------------------[[ == OBJECT CREATION == ]]----------------------------------------------------

--[[
	TODO: two types of scenes.
	1. A scene which has *one* image that is the map image. It is drawn first
	2. A scene whose map is made out of a grid. You pass a texture atlas (an image) with the tiles, and a 2d array which says
	for each grid[x][y] which tile in the image is at that grid tile. And a number indicating tile size in pixels
]]




-- creates a new Scene object with the base properties of a Scene
local function newScene(sceneCamera, bgImage, fgImage)
	assert(camera.isCamera(sceneCamera) or sceneCamera == nil, "scene.newScene(sceneCamera, bgImage, fgImage) only accepts a camera instance or nil for 'sceneCamera'")
	module.TotalCreated = module.TotalCreated + 1

	local Object = {
		["Id"] = module.TotalCreated;
		--["SceneImage"] = image;
		["Background"] = bgImage;
		["Foreground"] = fgImage;
		["Camera"] = sceneCamera or camera.new();
		["Entities"] = {}; -- sorted based on ZIndex first, then Position.y
		--["Props"] = {}; -- sorted based on ZIndex first, then Position.y

		-- table with arrays of event functions stored under keys named after the events
		["Events"] = {};
	}

	return setmetatable(Object, Scene)
end


-- atlasImage is a spritesheet / image atlas with the tiles the map consists out of.
-- grid is a 2d array of vectors representing which sprites should be drawn on which tiles of the grid
function newTiledScene(sceneCamera, atlasImage, grid, tileSize)
	assert(camera.isCamera(sceneCamera) or sceneCamera == nil, "scene.newTiledScene(sceneCamera, atlasImage, grid, tileSize) only accepts a camera instance or nil for 'sceneCamera'")
	assert(type(grid) == "table" and type(grid[1]) == "table" and vector2.isVector2(grid[1][1]), "scene.newTiledScene(sceneCamera, atlasImage, grid, tileSize) requires argument 'grid' to be a 2d array of vector2s")
	module.TotalCreated = module.TotalCreated + 1

	-- for each tile in the atlasImage, create a Quad and store it in a 2D array.
	local imageTilesX, imageTilesY = atlasImage:getWidth() / tileSize, atlasImage:getHeight() / tileSize
	local Quads = {}
	for x = 1, imageTilesX do
		Quads[x] = {}
		for y = 1, imageTilesY do
			Quads[x][y] = love.graphics.newQuad((x-1) * tileSize, (y-1) * tileSize, tileSize, tileSize, atlasImage)
		end
	end
	-- now that all quads are created, create a SpriteBatch and initialize it with the right quads on the right locations using the 'grid'
	local SpriteBatch = love.graphics.newSpriteBatch(atlasImage, (#grid * #grid[1]), "static")
	for x = 1, #grid do
		for y = 1, #grid[x] do
			SpriteBatch:add(Quads[grid[x][y].x][grid[x][y].y], (x-1) * tileSize, (y-1) * tileSize)
		end
	end

	-- TODO: create the spritebatch w/ quads that will be used to draw the map image
	local Object = {
		["Id"] = module.TotalCreated;
		["SceneImage"] = atlasImage;
		["SpriteBatch"] = SpriteBatch;
		["Quads"] = Quads;
		["Camera"] = sceneCamera or camera.new();
		-- TODO: combine Entities and Props into one array. scene:at() will be slower, but drawing will be faster (which occurs more often!)
		--["Entities"] = {}; -- sorted based on ZIndex first, then Position.y
		--["Props"] = {}; -- sorted based on ZIndex first, then Position.y

		["Entities"] = {}; -- list of both Prop and Creature instances, sorted by (primarily) ZIndex and (in case of a ZIndex tie) by Position.y

		-- table with arrays of event functions stored under keys named after the events
		["Events"] = {};
	};
	return setmetatable(Object, TiledScene)
end



----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

module.newScene = newScene
module.newTiledScene = newTiledScene
module.isScene = isScene
return setmetatable(module, {__call = function(_, ...) return newScene(...) end})
