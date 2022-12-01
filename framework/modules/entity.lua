
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


--[[

TODO:
an entity has 1 or more states
each state has one or more animations
when entering a state, all animations of that state are played
when leaving a state, all animations of that state are stopped
each animation is assigned a function that returns a number (or 0 if no numbers is passed)
the animation whose function returns the largest number is displayed. In case of a tie, the first animation with the largest number is displayed
]]

function Entity:addState(name, ...) -- Anim1, Func1, Anim2, Func2, ... (each function returns a value. Function with the highest value returned will have their animation displayed!)
	assert(type(name) == "string", "Entity:addState(name, Anim) requires argument 'name' to be of type 'string'")
	if self.States[name] ~= nil then
		error(("Cannot add state %s to entity as it already has a state with the same name"):format(name))
	end
	-- create new state to fill in
	local State = {
		["Animations"] = {}; -- table of animation objects
		["Priorities"] = {}; -- table of functions where Priorities[i] corresponds to the animation Animations[i]. Functions return numbers indicating the priority of each animation. Highest priority animation is shown
	}
	-- initialize state with animations and functions
	local anim, func
	for i = 1, select("#", ...), 2 do
		anim, func = select(i, ...)
		assert(animation.isAnimation(anim), "Entity:addState(name, ...) requires each odd-numbered argument in the tuple to be of type 'animation'")
		assert(type(func) == "function", "Entity:addState(name, ...) requires each even-numbered argument in the tuple to be a function")
		table.insert(State.Animations, anim)
		table.insert(State.Priorities, func)
	end
	-- finally, add the new state and return it
	self.States[name] = State
	return State
end



function Entity:hasState(name)
	return self.States[name] ~= nil
end



function Entity:getState()
	return self.States[self.CurrentState]
end


-- returns an image and a quad on the image to draw on screen
function Entity:getSprite()
	local State = self:getState()
	local curIndex, highestPriority = 1, -math.huge
	local priority
	-- calculate which animation to grab the sprite from
	for i = 1, #State.Priorities do
		priority = State.Priorities[i]()
		if priority > highestPriority then
			highestPriority = priority
			curIndex = i
		end
	end
	-- return the sprite of the currently shown animation (Image, Quad)
	return State.Animations[i]:getSprite()
end



function Entity:setState(name)
	assert(self:hasState(name), "Entity:setState(name) is being called with 'name' set to a non-existent state")
	local State
	if self.CurrentState ~= nil then -- when creating a new entity, CurrentState will be nil, so this check is needed to prevent StateLeaving from firing upon entity creation
		-- call StateLeaving
		if self.Events.StateLeaving ~= nil then
			connection.doEvents(self.Events.StateLeaving, self.CurrentState)
		end
		-- stop all animations from the current state
		State = self:getState()
		for i = 1, #State.Animations do
			State.Animations[i]:stop()
		end
	end
	
	-- set self to new state
	self.CurrentState = name
	State = self:getState()

	-- update the entity Size property
	self.Size = vector(State.Animations[1].FrameWidth, State.Animations[i].FrameHeight)

	-- play all animations in the new state
	for i = 1, #State.Animations do
		State.Animations[i]:play()
	end
	-- call StateEntered
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

local function new(defaultState, ...)
	assert(type(defaultState) == "string", "entity.new(defaultState, ...) requires argument 'defaultState' to be of type 'string'")
	module.TotalCreated = module.TotalCreated + 1

	local Object = {
		["CurrentState"] = nil; -- will be set to 'defaultState' when setState() is called later in this function. Had to be kept as 'nil' so that the StateLeaving event isn't called on entity creation
		["Id"] = module.TotalCreated;
		["Pivot"] = vector(0.5, 0.5);
		["Size"] = vector(32, 32); -- TODO: set this whenever the state changes; has the same values as the animation's frame width & height
		["Position"] = vector(0, 0);
		["Shape"] = "rectangle";
		["ShapeSize"] = vector(1, 1);
		["States"] = {};
	}
	-- set metatable early so that :addState() can be called
	setmetatable(Object, Entity)

	-- add the default state and set it
	Object:addState(defaultState, ...)
	Object:setState(defaultState)

	return Object
end



----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

-- pack up and return module
module.new = new
module.isEntity = isEntity
return setmetatable(module, {__call = function(_, ...) return new(...) end})

