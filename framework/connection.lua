
local module = {}

local conn = {}
conn.__index = conn

local totalConnectionsMade = 0



local function findConnectionInSortedArray(Obj, pairArray)
	local left, right = 1, #pairArray
	local pivot
	while left <= right do
		pivot = math.floor((left + right) / 2)
		if pairArray[pivot][2].Id == Obj.Id then
			return pivot
		elseif pairArray[pivot][2].Id < Obj.Id then -- need to search in the right half now
			left = pivot + 1
		else
			right = pivot - 1
		end
	end
	return nil
end


local function callFunctionArray(arr, ...)
	local connectionList = {}
	-- by first copying over the functions to a new list and then evaluating the new list, table.remove() calls in connection:disconnect() calls cannot influence the second loop :>
	for i = 1, #arr do
		connectionList[#connectionList + 1] = arr[i][1]
	end
	for i = 1, #connectionList do
		connectionList[i](...)
	end
end



local function newConnection(elem, ename)
	totalConnectionsMade = totalConnectionsMade + 1
	local Connection = {
		["Connected"] = true;
		["Id"] = totalConnectionsMade;
		["EventName"] = ename;
		--["EventIndex"] = index; -- event index in the linked object
		["LinkedElement"] = elem;
	}
	return setmetatable(Connection, conn)
end



function conn:disconnect()
	if not self.Connected then
		error("EventConnection cannot be disconnected when it is already disconnected.")
	end
	local Element = self.LinkedElement
	if Element ~= nil then
		if Element.Events[self.EventName] ~= nil then
			local objIndex = findConnectionInSortedArray(self, Element.Events[self.EventName])
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


module.doEvents = callFunctionArray
module.new = newConnection

return module

