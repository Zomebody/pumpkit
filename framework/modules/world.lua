
----------------------------------------------------[[ == IMPORTS == ]]----------------------------------------------------

local connection = require("framework.connection")



----------------------------------------------------[[ == BASE OBJECTS == ]]----------------------------------------------------

local module = { -- the world module
	--[[
	["Background"] = {
		["Image"] = nil;
		["Quad"] = nil;
	};
	]]
	["CurrentScene"] = nil;
}



----------------------------------------------------[[ == MODULE INITIALIZATION == ]]----------------------------------------------------

function module:initialize()
	if not self.Initialized then
		self.Initialized = true
	else
		return
	end

	-- Monkey Patching love.update (at end)
	local update = love.update or function() end -- define new update function if it doesn't exist yet
	love.update = function()
		update()
		-- TODO: world update code and such!
	end
end



----------------------------------------------------[[ == METHODS == ]]----------------------------------------------------

function module:setScene(theScene)
	assert(scene.isScene(theScene) or theScene == nil, "world:setScene(obj) only accepts a scene instance or nil.")
	-- unload the old scene by triggering its unloading event and un-setting the CurrentScene
	if self.CurrentScene ~= nil then
		-- do event
		local prevScene = self.CurrentScene
		self.CurrentScene = nil
		if prevScene.Events.Unloading then
			connection.doEvents(prevScene.Events.Unloading)
		end
	end
	-- load the new scene by setting it and triggering its loading event
	if theScene ~= nil then
		self.CurrentScene = theScene
		if theScene.Events.Loading ~= nil then
			connection.doEvents(theScene.Events.Loading)
		end
	end
end


-- returns the CurrentScene property
function module:getScene()
	return self.CurrentScene
end


-- returns the current camera used in the current scene
function module:getCamera()
	local currentScene = self:getScene()
	if currentScene ~= nil then
		return currentScene:getCamera()
	end
	return nil
end



function module:render()
	--if self.Background.Image ~= nil then
		-- if quad, draw quad
		-- otherwise, draw image and stretch to screen bounds
	--end
	if self.CurrentScene ~= nil then
		-- draw the scene
		self.CurrentScene:draw()
	end
end



----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

return module