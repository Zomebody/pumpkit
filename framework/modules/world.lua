
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

-- TODO: theScene must be a scene of scene3
-- also: create a 3d shader for if you're using a scene3

function module:setScene(theScene)
	assert(scene.isScene(theScene) or scene3.isScene3(theScene) or theScene == nil, "world:setScene(obj) only accepts a scene or scene3 instance or nil.")
	
	-- unload the old scene by triggering its unloading event and un-setting the CurrentScene
	if self.CurrentScene ~= nil then
		-- do event
		local prevScene = self.CurrentScene
		if prevScene.Events.Unloading then
			connection.doEvents(prevScene.Events.Unloading)
		end

		-- unload entities (but only in 2d scenes)
		if scene.isScene(theScene) then
			-- call 'Unloading' on the entities in the scene after calling 'Unloading' on the scene itself, because maybe the scene wants to manually remove some entities upon unloading!
			local Entities = prevScene.Entities
			for i = 1, #Entities do
				if Entities[i].Events.Unloading then
					connection.doEvents(Entities[i].Events.Unloading)
				end
			end
		end

		self.CurrentScene = nil
	end



	-- load the new scene by setting it and triggering its loading event
	if theScene ~= nil then
		self.CurrentScene = theScene
		
		-- first, call Loading on the entities currently in the scene (if this is a 2d scene)
		if scene.isScene(theScene) then
			local Entities = theScene.Entities
			for i = 1, #Entities do
				if Entities[i].Events.Loading then
					connection.doEvents(Entities[i].Events.Loading)
				end
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
	if self.CurrentScene ~= nil then
		-- draw the scene
		-- if it's a scene3, set the shader here to a 3d shader
		self.CurrentScene:draw()
		-- if it's a scene3, clear the shader here
	end
end



----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

return module