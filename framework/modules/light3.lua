
----------------------------------------------------[[ == BASE OBJECTS == ]]----------------------------------------------------

local module = {
	["TotalCreated"] = 0;
}

local Light3 = {}
Light3.__index = Light3
Light3.__tostring = function(tab) return "{Light3: " .. tostring(tab.Id) .. "}" end



----------------------------------------------------[[ == METHODS == ]]----------------------------------------------------

local function isLight3(t)
	return getmetatable(t) == Light3
end



function Light3:move(offset)
	assert(vector3.isVector3(offset), "Light3:move(offset) requires argument 'offset' to be of type vector3.")
	self.Position = self.Position + offset
end


function Light3:clone()
	local Light = new(self.Position, self.Color, self.Range, self.Strength)
	-- keep the scene nil
	return Light
end



function Light3:detach()
	self.Scene:detachLight(self)
end





----------------------------------------------------[[ == OBJECT CREATION == ]]----------------------------------------------------

local function new(position, col, range, strength)
	assert(position == nil or vector3.isVector3(position), "Light3.new(position, col, range, strength) requires argument 'position' to be nil or a vector3.")
	assert(col == nil or color.isColor(col), "Light3.new(position, col, range, strength) requires argument 'col' to be nil or a color.")
	assert(range == nil or type(range) == "number", "Light3.new(position, col, range, strength) requires argument 'range' to be nil or a number.")
	assert(strength == nil or type(strength) == "number", "Light3.new(position, col, range, strength) requires argument 'strength' to be nil or a number.")

	module.TotalCreated = module.TotalCreated + 1

	local Obj = {
		["Id"] = module.TotalCreated;
		["Position"] = position ~= nil and vector3(position) or vector3(0, 0, 0);
		["Color"] = col ~= nil and color(col) or color(1, 1, 1);
		["Range"] = range ~= nil and range or 1;
		["Strength"] = strength ~= nil and strength or 1;
		["Scene"] = nil;
	}

	setmetatable(Obj, Light3)
	
	return Obj
end



----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

-- pack up and return module
module.new = new
module.isLight3 = isLight3
return setmetatable(module, {__call = function(_, ...) return new(...) end})











