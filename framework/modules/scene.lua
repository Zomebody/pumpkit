
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



----------------------------------------------------[[ == METHODS == ]]----------------------------------------------------

-- check if an object is a scene
local function isScene(t)
	return getmetatable(t) == Scene
end



function Scene:setCamera(theCamera)
	assert(camera.isCamera(theCamera), "world:setCamera(obj) only accepts cameras as its argument")
	self.Camera = theCamera
end


function Scene:getCamera()
	return self.Camera
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

	-- TODO: draw entities (and use the camera object to check which entities are within bounds)

	-- reset graphics transform to previous state
	love.graphics.pop()
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

	-- TODO: create the spritebatch w/ quads that will be used to draw the map image
end



----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

module.newScene = newScene
module.isScene = isScene
return setmetatable(module, {__call = function(_, ...) return new(...) end})
