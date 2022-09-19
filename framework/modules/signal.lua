
local Signal = {
	["Connected"] = {};
}

local conn = {}
conn.__index = conn

local totalCreated = 0


function Signal:fire(sigName, ...)
	if type(signName) ~= "string" then
		error("signal:fire() expects the first argument to be of type <string>")
	end
	local array = self.Connected[sigName]
	if array ~= nil then
		local copiedArray = {}
		for i = 1, #array do
			copiedArray[i] = array[i]
		end
		for i = 1, #copiedArray do
			copiedArray[i].Function(...)
		end
	end
end


Signal.__call = function(...)
	return fire(...)
end



function Signal:listen(name, func, isOnce)
	if isOnce == nil then
		isOnce = false
	end
	totalCreated = totalCreated + 1
	local Connection = {
		["Connected"] = true;
		["Id"] = totalCreated;
		["IsOnce"] = isOnce;
		["Function"] = func;
	}
	if Signal.Connected[name] == nil then
		Signal.Connected[name] = {}
	end
	Signal.Connected[name][#Signal.Connected[name] + 1] = Connection
	return setmetatable(Connection, conn)
end




function Signal:once(name, func)
	return self:listen(name, func, true)
end



--[[
function conn:disconnect()
	if not self.Connected then
		error("EventConnection cannot be disconnected when it is already disconnected.")
	end
	local Element = self.LinkedElement
	if Element ~= nil then
		if Element.Events[self.EventName] ~= nil then
			local objIndex = FindConnectionInSortedArray(self, Element.Events[self.EventName])
			if objIndex ~= nil then
				table.remove(Element.Events[self.EventName], objIndex) -- table.remove guarantees the ascending connection id order, and no gaps will be left behind in the array
				if #Element.Events[self.EventName] == 0 then
					Element.Events[self.EventName] = nil
				end
				self.Connected = false
				return true
			else
				error("EventConnection is disconnecting but the function to disconnect no longer exists.")
			end
		else
			error("EventConnection is disconnecting but its referenced instance has no event dictionary. Did you try disconnecting the events of a removed object?")
		end
	end
	return false
end

]]





return Signal
