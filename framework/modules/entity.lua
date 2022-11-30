
----------------------------------------------------[[ == IMPORTS == ]]----------------------------------------------------

local connection = require("framework.connection")



----------------------------------------------------[[ == BASE OBJECTS == ]]----------------------------------------------------

local module = {
	["TotalCreated"] = 0;
}

local Entity = {}
Entity.__index = Entity
Entity.__tostring = function(tab) return "{Entity: " .. tostring(tab.Id) .. "}" end



----------------------------------------------------[[ == SHADER == ]]----------------------------------------------------
-- TODO: see Shader_Tests folder for implementation details later


----------------------------------------------------[[ == METHODS == ]]----------------------------------------------------

local function isEntity(t)
	return getmetatable(t) == Entity
end


function Entity:setShape(shape)
	assert(shape == "ellipse" or shape == "rectangle", "Entity:setShape(shape) only accepts \"ellipse\" or \"rectangle\" as its arguments")
	self.Shape = shape
end




function Entity:addState(name, Anim)
	assert(type(name) == "string", "Entity:addState(name, Anim) requires argument 'name' to be of type 'string'")
	assert(animation.isAnimation(Anim), "Entity:addState(name, Anim) requires argument 'Anim' to be of type 'animation'")
	if self.States[name] ~= nil then
		error(("Cannot add state %s to entity as it already has a state with the same name"):format(name))
	end
	self.States[name] = {
		["Animation"] = Anim;
	}
end


function Entity:hasState(name)
	return self.States[name] ~= nil
end


function Entity:getState()
	return self.States[self.CurrentState]
end


function Entity:setState(name)
	assert(self:hasState(name), "Entity:setState(name) is being called with 'name' set to a non-existent state")
	if self.Events.StateLeaving ~= nil then
		connection.doEvents(self.Events.StateLeaving, self.CurrentState)
	end
	self:getState().Animation:stop()
	self.CurrentState = name
	self:getState().Animation:play()
	if self.Events.StateEntered ~= nil then
		connection.doEvents(self.Events.StateEntered, self.CurrentState)
	end
end


-- eventName is the name of the event to call. All event name strings are accepted, but not all of them may trigger
-- func is the function to link
function Entity:on(eventName, func)
	if self.Events[eventName] == nil then
		self.Events[eventName] = {}
	end
	local index = #self.Events[eventName] + 1
	local Conn = connection.new(self, eventName)
	self.Events[eventName][index] = {func, Conn}
	return Conn
end



----------------------------------------------------[[ == OBJECT CREATION == ]]----------------------------------------------------

--local function new(img, imgSize)
--	assert(imgSize == nil or vector.isVector(imgSize), "entity.new(image, imgSize) expects argument 'imgSize' to be either nil or of type 'vector'")
local function new(defaultState, Anim)
	assert(type(defaultState) == "string", "entity.new(defaultState, Anim) requires argument 'defaultState' to be of type 'string'")
	assert(animation.isAnimation(Anim), "entity.new(defaultState, Anim) requires argument 'Anim' to be of type 'animation'")
	module.TotalCreated = module.TotalCreated + 1

	local Object = {
		["CurrentState"] = defaultState;
		["Id"] = module.TotalCreated;
		--["Image"] = img;
		--["ImagePivot"] = vector(0.5, 0.5);
		--["ImageSize"] = imgSize or vector(img:getDimensions());
		["Pivot"] = vector(0.5, 0.5);
		["Size"] = vector(32, 32); -- TODO: set this depending on animation
		["Position"] = vector(0, 0);
		["Shape"] = "rectangle";
		["ShapeSize"] = vector(1, 1);
		["States"] = {};
	}

	return setmetatable(Object, Entity)
end



----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

-- pack up and return module
module.new = new
module.isEntity = isEntity
return setmetatable(module, {__call = function(_, ...) return new(...) end})

