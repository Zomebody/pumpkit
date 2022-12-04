
----------------------------------------------------[[ == IMPORTS == ]]----------------------------------------------------

local connection = require("framework.connection")



----------------------------------------------------[[ == BASE OBJECTS == ]]----------------------------------------------------

local module = {
	["TotalCreated"] = 0;
}

local Entity = {}
Entity.__index = Entity
Entity.__tostring = function(tab) return "{Entity: " .. tostring(tab.Id) .. "}" end

local Creature = {}
Creature.__index = Creature
Creature.__tostring = function(tab) return "{Creature: " .. tostring(tab.Id) .. "}" end
setmetatable(Creature, Entity)

local Prop = {}
Prop.__index = Prop
Prop.__tostring = function(tab) return "{Prop: " .. tostring(tab.Id) .. "}" end
setmetatable(Prop, Entity)



----------------------------------------------------[[ == SHADER == ]]----------------------------------------------------
-- TODO


----------------------------------------------------[[ == METHODS == ]]----------------------------------------------------

local function isCreature(t)
	return getmetatable(t) == Creature
end

local function isProp(t)
	return getmetatable(t) == Prop
end

local function isEntity(t)
	return isCreature(t) or isProp(t)
end

function Creature:setShape(shape)
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

function Creature:addState(name, ...) -- Anim1, Func1, Anim2, Func2, ... (each function returns a value. Function with the highest value returned will have their animation displayed!)
	assert(type(name) == "string", "Creature:addState(name, Anim) requires argument 'name' to be of type 'string'")
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
		assert(animation.isAnimation(anim), "Creature:addState(name, ...) requires each odd-numbered argument in the tuple to be of type 'animation'")
		assert(type(func) == "function", "Creature:addState(name, ...) requires each even-numbered argument in the tuple to be a function")
		table.insert(State.Animations, anim)
		table.insert(State.Priorities, func)
	end
	-- finally, add the new state and return it
	self.States[name] = State
	return State
end



function Creature:hasState(name)
	return self.States[name] ~= nil
end



function Creature:getState()
	return self.States[self.CurrentState]
end


-- returns an image and a quad on the image to draw on screen
function Creature:getSprite()
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
	return State.Animations[curIndex]:getSprite()
end



function Creature:setState(name)
	assert(self:hasState(name), "Creature:setState(name) is being called with 'name' set to a non-existent state")
	if self.CurrentState == name then return end -- do not change state when you are already in the same state
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
	self.Size = vector(State.Animations[1].FrameSize)

	-- play all animations in the new state
	for i = 1, #State.Animations do
		State.Animations[i]:play()
	end
	-- call StateEntered
	if self.Events.StateEntered ~= nil then
		connection.doEvents(self.Events.StateEntered, self.CurrentState)
	end
end

-- return true is e1 should be displayed below e2, which is if its ZIndex is smaller, or in the case of a tie, its Position.y is smaller
local function entityIsBelowEntity(e1, e2)
	if e1.ZIndex == e2.ZIndex then
		return e1.Position.y < e2.Position.y
	else
		return e1.ZIndex < e2.ZIndex
	end
end

function Entity:moveTo(x, y)
	if vector.isVector(x) then
		y = x.y
		x = x.x
	end
	-- find the location of the entity in the Entities array using log2(n) search
	local indexSelf = self.Scene:getEntityIndex(self)
	if indexSelf == nil then
		error(("Entity:moveTo(x, y) cannot be called for entity %s because it cannot be found in its Scene.Entities array!"):format())
	end

	-- find the new index in the array by taking bigger and bigger steps (1, 2, 4, 8 etc.) until you overshoot, then take smaller steps
	-- 1. take a step of size 1
	-- 2. check if you are still in bounds & check if you didn't overshoot
	-- 3. if you didn't overshoot or go OOB, move indexes to the left/right equal to your current step size
	-- 4. if instead you are OOB or overshot, do not take the step and instead halve the step size
	-- 5. if you cannot halve the step size because the step size is already 1, then you are right where you should be
	-- 6. if where you should be is your current array index, do nothing, if it isn't, insert yourself at the current index + 1

	local Entities = self.Scene.Entities

	-- start taking steps
	local currentIndex = indexSelf
	local iterating = true
	if y > self.Position.y then -- move towards the right in the array (positive stepSize)

		local stepSize = 1
		while iterating do
			if Entities[currentIndex + stepSize] ~= nil and entityIsBelowEntity(self, Entities[currentIndex + stepSize]) then -- not out of bounds yet, also no overshooting
				currentIndex = currentIndex + stepSize
				stepSize = stepSize * 2
			elseif stepSize > 1 then -- you either overshot or went out of bounds, so reduce the stepSize
				stepSize = stepSize / 2
			else -- you can no longer reduce the stepSize!
				-- you are currently on the index you should be at! (Because the entity at currentIndex will be shifted towards the left one spot due to moving around)
				-- however, it is also possible that you never moved, in which case you are ON the index you should be at
				-- therefore, check your current index as well. If the current index is yourself, don't move
				iterating = false
				if indexSelf ~= currentIndex then
					-- time to move!
					for i = indexSelf, currentIndex - 1 do
						-- swap the pair
						Entities[i], Entities[i + 1] = Entities[i + 1], Entities[i]
					end
				end
			end
		end
	else
		-- this is a copy of the code above, but with a few small tweaks to work for moving to the left in the array rather than the right
		-- all changes have been commented
		local stepSize = 1
		while iterating do
			if Entities[currentIndex + stepSize] ~= nil and entityIsBelowEntity(Entities[currentIndex + stepSize], self) then -- swapped arguments in entityIsBelowEntity
				currentIndex = currentIndex - stepSize -- minus instead of plus sign
				stepSize = stepSize * 2
			elseif stepSize > 1 then
				stepSize = stepSize / 2
			else
				iterating = false
				if indexSelf ~= currentIndex then
					for i = indexSelf, currentIndex + 1, -1 do -- added iteration of -1 because indexSelf > currentIndex. Also changed currentIndex-1 to currentIndex+1
						Entities[i], Entities[i - 1] = Entities[i - 1], Entities[i] -- swapped plus signs with minus signs
					end
				end
			end
		end
	end
end


function Entity:setImageScale(x, y)
	if vector.isVector(x) then
		self.ImageScale = vector(x) -- vector
	elseif y == nil then
		self.ImageScale = vector(x, x) -- only one coordinate passed
	else
		self.ImageScale = vector(x, y) -- x,y coordinate
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


-- draw the entity (does not take any transforms into consideration! So apply those first!)
function Creature:draw()
	local Image, Quad = self:getSprite()
	local x, y, w, h = Quad:getViewport()
	love.graphics.draw(Image, Quad, self.Position.x, self.Position.y, 0, self.Size.x / w * self.ImageScale.x, self.Size.y / h * self.ImageScale.y, self.Pivot.x * w, self.Pivot.y * h)
end



----------------------------------------------------[[ == OBJECT CREATION == ]]----------------------------------------------------

local function newCreature(defaultState, ...)
	assert(type(defaultState) == "string", "entity.new(defaultState, ...) requires argument 'defaultState' to be of type 'string'")
	module.TotalCreated = module.TotalCreated + 1

	local Object = {
		["CurrentState"] = nil; -- will be set to 'defaultState' when setState() is called later in this function. Had to be kept as 'nil' so that the StateLeaving event isn't called on entity creation
		["Id"] = module.TotalCreated;
		["Pivot"] = vector(0.5, 0.5);
		["Size"] = vector(32, 32); -- (read-only) the space in pixels the entity takes up on screen at a zoom of 1. This may change when the entity's state changes
		["ImageScale"] = vector(1, 1);
		["Position"] = vector(0, 0);
		["Shape"] = "rectangle";
		["ShapeSize"] = vector(1, 1);
		["States"] = {};
		["Scene"] = nil;

		["Events"] = {}; -- list of connected events
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
module.newCreature = newCreature
module.isEntity = isEntity
module.isCreature = isCreature
module.isProp = isProp
return setmetatable(module, {__call = function(_, ...) return newCreature(...) end})

