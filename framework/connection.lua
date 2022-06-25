
local module = {}

local conn = {}
conn.__index = conn


local function newConnection(elem, ename, index)
	local Connection = {
		["Connected"] = true;
		["EventName"] = ename;
		["EventIndex"] = index; -- event index in the linked object
		["LinkedElement"] = elem;
	}
	return setmetatable(Connection, conn)
end

function conn:disconnect()
	if not self.Connected then return end
	local Element = self.LinkedElement
	if Element ~= nil then
		if Element.Events[self.EventName] ~= nil then
			if Element.Events[self.EventName][self.EventIndex] ~= nil then
				Element.Events[self.EventName][self.EventIndex] = nil
				if #Element.Events[self.EventName] == 0 then -- there are no more events with this name that are linked to the given UI element
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


module.new = newConnection

return module

