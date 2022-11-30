
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

-- returns the location to insert 'item' into table 'tab' based on the 'Position' property, where every following element has a higher Position.y value
local function getInsertionIndexInAscendingArray(tab, item)
	if #tab == 0 then
		return 1
	end
	local l, r = 1, #tab
	local mid
	while l ~= r do
		mid = math.floor((l + r) / 2)
		if tab[mid].Position.y > item.Position.y then
			r = math.max(l, mid - 1)
		else
			l = math.min(mid + 1, r)
		end
	end
	if item.Position.y < tab[l].Position.y then
		return l
	else
		return l + 1
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
	assert(entity.isEntity(Object), "Scene:addEntity(obj) requires it argument to be of type 'entity'")
	
	-- log2(n) search
	local index = getInsertionIndexInAscendingArray(self.Entities, Object)
	table.insert(self.Entities, index, Object)
end


-- return the entity located the given screen coordinate
function Scene:at(x, y)
	if vector.isVector(x) then
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
		Entity = self.Entities[i]
		dx = Entity.Position.x - worldX
		dy = Entity.Position.y - worldY
		if Entity.Shape == "rectangle" then
			if math.abs(dx) <= Entity.ShapeSize.x / 2 and math.abs(dy) <= Entity.ShapeSize.y / 2 then -- 'point within rectangle' check
				return Entity
			end
		elseif Entity.Shape == "ellipse" then
			if dx^2 / (Entity.ShapeSize.x / 2)^2 + dy^2 / (Entity.ShapeSize.y / 2)^2 <= 1 then -- 'point within ellipse' check
				return Entity
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

	-- draw the scene image
	love.graphics.draw(self.SceneImage)

	self:drawEntities()

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


-- only for internal use. Used by both the TiledScene and Scene to draw their entities on screen after drawing the scene's map
-- default shader, forwards looping through entities: 170-180 fps @ 10.000 entities
function Scene:drawEntities()
	-- the camera transform should already be applied!
	local Object
	local w, h
	for i = 1, #self.Entities do
		Object = self.Entities[i]
		w, h = Object.Image:getDimensions()
		love.graphics.draw(Object.Image, Object.Position.x, Object.Position.y, 0, Object.ImageSize.x / w, Object.ImageSize.y / h, Object.ImagePivot.x * w, Object.ImagePivot.y * h)
	end
end



----------------------------------------------------[[ == OBJECT CREATION == ]]----------------------------------------------------

--[[
	TODO: two types of scenes.
	1. A scene which has *one* image that is the map image. It is drawn first
	2. A scene whose map is made out of a grid. You pass a texture atlas (an image) with the tiles, and a 2d array which says
	for each grid[x][y] which tile in the image is at that grid tile. And a number indicating tile size in pixels
]]




-- creates a new Scene object with the base properties of a Scene
local function newScene(image, sceneCamera)
	assert(camera.isCamera(sceneCamera) or sceneCamera == nil, "scene.newScene(image, sceneCamera) only accepts a camera instance or nil for 'sceneCamera'")
	module.TotalCreated = module.TotalCreated + 1

	local Object = {
		["Id"] = module.TotalCreated;
		["SceneImage"] = image;
		["Camera"] = sceneCamera or camera.new();
		["Entities"] = {};

		-- table with arrays of event functions stored under keys named after the events
		["Events"] = {};
	}

	return setmetatable(Object, Scene)
end

-- atlasImage is a spritesheet / image atlas with the tiles the map consists out of.
-- grid is a 2d array of vectors representing which sprites should be drawn on which tiles of the grid
function newTiledScene(atlasImage, grid, tileSize, sceneCamera)
	assert(camera.isCamera(sceneCamera) or sceneCamera == nil, "scene.newTiledScene(atlasImage, grid, sceneCamera) only accepts a camera instance or nil for 'sceneCamera'")
	assert(type(grid) == "table" and type(grid[1]) == "table" and vector.isVector(grid[1][1]), "scene.newTiledScene(atlasImage, grid, tileSize, sceneCamera) requires argument 'grid' to be a 2d array of vectors")
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
		["Entities"] = {};

		-- table with arrays of event functions stored under keys named after the events
		["Events"] = {};
	};
	return setmetatable(Object, TiledScene)
end



----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

module.newScene = newScene
module.newTiledScene = newTiledScene
module.isScene = isScene
return setmetatable(module, {__call = function(_, ...) return new(...) end})
