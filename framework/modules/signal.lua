
local connection = require("framework.connection")

local module = {
	["Events"] = {};
}


function module:fire(sigName, ...)
	if type(sigName) ~= "string" then
		error("signal:fire() expects the first argument to be of type <string>, given is: " .. type(sigName))
	end
	if self.Events[sigName] ~= nil then
		connection.doEvents(self.Events[sigName], ...)
	end
end


function module:listen(eventName, func)
	if self.Events[eventName] == nil then
		self.Events[eventName] = {}
	end
	local index = #self.Events[eventName] + 1
	local con = connection.new(self, eventName)
	self.Events[eventName][index] = {func, con}
	return con
end


function module:once(eventName, func)
	local con
	con = self:listen(
		eventName,
		function(...)
			con:disconnect()
			func(...)
		end
	)
	return con
end


return setmetatable(module, {["__call"] = function(_, ...) module:fire(...) end})
