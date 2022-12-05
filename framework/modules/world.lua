
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
		if prevScene.Events.Unloading then
			connection.doEvents(prevScene.Events.Unloading)
		end
		-- call 'Unloading' on the entities in the scene after calling 'Unloading' on the scene itself, because maybe the scene wants to manually remove some entities upon unloading!
		local Entities = prevScene.Entities
		for i = 1, #Entities do
			if Entities[i].Events.Unloading then
				connection.doEvents(Entities[i].Events.Unloading)
			end
		end

		self.CurrentScene = nil
	end

	-- load the new scene by setting it and triggering its loading event
	if theScene ~= nil then
		self.CurrentScene = theScene
		-- first, call Loading on the entities currently in the scene
		local Entities = theScene.Entities
		for i = 1, #Entities do
			if Entities[i].Events.Loading then
				connection.doEvents(Entities[i].Events.Loading)
			end
		end
		-- then, call the Loading event on the scene
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