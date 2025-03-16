
----------------------------------------------------[[ == IMPORTS == ]]----------------------------------------------------

local connection = require("framework.connection")



----------------------------------------------------[[ == MODULE == ]]----------------------------------------------------

local module = {
	["Events"] = {}; -- dictionary where keys are event names, values are pairs of the form {function, connection object}
}


function module:initialize()
	if not self.Initialized then
		self.Initialized = true
	else
		return
	end

	-- loop through default love2D callbacks
	-- callbacks that are *excluded* from the love.handlers list: update, draw, errhand, errorhandler, load
	for eventName, func in pairs(love.handlers) do
		local oldFunction = love[eventName] or function() end
		-- overwrite callback with one that also checks if there are connected events!
		love[eventName] = function(...)
			oldFunction(...)
			if self.Events[eventName] ~= nil then -- if there are callbacks registered, run them
				connection.doEvents(self.Events[eventName], ...) -- call the event with the default callback parameters
			end
		end

	end
end


-- eventName is the name of the event to call. All event name strings are accepted, but not all of them may trigger
-- func is the function to link
function module:on(eventName, func)
	if self.Events[eventName] == nil then
		self.Events[eventName] = {}
	end
	local index = #self.Events[eventName] + 1
	local Conn = connection.new(self, eventName)
	self.Events[eventName][index] = {func, Conn}
	return Conn
end



----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

return module
