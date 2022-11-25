
----------------------------------------------------[[ == BASE OBJECTS == ]]----------------------------------------------------

local module = {
	["TotalCreated"] = 0;
}

local Entity = {}
Entity.__index = Entity
Entity.__tostring = function(tab) return "{Entity: " .. tostring(tab.Id) .. "}" end



----------------------------------------------------[[ == METHODS == ]]----------------------------------------------------

local function isEntity(t)
	return getmetatable(t) == Entity
end

--[[
function Entity:setShape(shape)
	assert(shape == "ellipse" or shape == "rectangle", "Entity:setShape(shape) only accepts \"ellipse\" or \"rectangle\" as its arguments")
	self.Shape = shape
end
]]



----------------------------------------------------[[ == OBJECT CREATION == ]]----------------------------------------------------

local function new(img--[[, size]])
	module.TotalCreated = module.TotalCreated + 1

	local Object = {
		["Id"] = module.TotalCreated;
		["Position"] = vector(0, 0);
		--["Size"] = size or vector(img:getDimensions());
		["Image"] = img;
		["Pivot"] = vector(0.5, 0.5);
	}

	return setmetatable(Object, Entity)
end



----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

-- pack up and return module
module.new = new
module.isEntity = isEntity
return setmetatable(module, {__call = function(_, ...) return new(...) end})

