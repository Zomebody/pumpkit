
----------------------------------------------------[[ == IMPORTS == ]]----------------------------------------------------

local connection = require("framework.connection")



----------------------------------------------------[[ == BASE OBJECTS == ]]----------------------------------------------------

local module = {
	["TotalCreated"] = 0;
}

local Prop = {}
Prop.__index = Prop
Prop.__tostring = function(tab) return "{Prop: " .. tostring(tab.Id) .. "}" end



----------------------------------------------------[[ == METHODS == ]]----------------------------------------------------

local function isProp(t)
	return getmetatable(t) == Prop
end


-- eventName is the name of the event to call. All event name strings are accepted, but not all of them may trigger
-- func is the function to link
--[[
function Entity:on(eventName, func)
	if self.Events[eventName] == nil then
		self.Events[eventName] = {}
	end
	local index = #self.Events[eventName] + 1
	local Conn = connection.new(self, eventName)
	self.Events[eventName][index] = {func, Conn}
	return Conn
end
]]


----------------------------------------------------[[ == OBJECT CREATION == ]]----------------------------------------------------

local function new(img, quad)
	--assert(type(defaultState) == "string", "entity.new(defaultState, ...) requires argument 'defaultState' to be of type 'string'")
	module.TotalCreated = module.TotalCreated + 1

	local Object = {
		["Id"] = module.TotalCreated;
		["Pivot"] = vector(0.5, 0.5);
		--["Quad"] = quad;
		["Size"] = vector(img:getWidth(), img:getHeight()); -- you can change this property to scale the image on the X and Y axis
		["Position"] = vector(0, 0);
		["Shear"] = vector(0, 0); -- works how you'd expect: a shear of x=1 == shear as much as the image width. Shearing is applied at the pivot point of where the image is drawn.

		["Events"] = {}; -- list of connected events
	}

	return setmetatable(Object, Entity)
end



----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

-- pack up and return module
module.new = new
module.isEntity = isEntity
return setmetatable(module, {__call = function(_, ...) return new(...) end})

