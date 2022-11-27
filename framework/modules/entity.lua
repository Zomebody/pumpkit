
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


function Entity:setShape(shape)
	assert(shape == "ellipse" or shape == "rectangle", "Entity:setShape(shape) only accepts \"ellipse\" or \"rectangle\" as its arguments")
	self.Shape = shape
end




----------------------------------------------------[[ == OBJECT CREATION == ]]----------------------------------------------------

local function new(img, imgSize)
	assert(imgSize == nil or vector.isVector(imgSize), "entity.new(image, imgSize) expects argument 'imgSize' to be either nil or of type 'vector'")
	module.TotalCreated = module.TotalCreated + 1

	local Object = {
		["Id"] = module.TotalCreated;
		["Image"] = img;
		["ImagePivot"] = vector(0.5, 0.5);
		["ImageSize"] = imgSize or vector(img:getDimensions());
		["Position"] = vector(0, 0);
		["Shape"] = "rectangle";
		["ShapeSize"] = vector(1, 1);
	}

	return setmetatable(Object, Entity)
end



----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

-- pack up and return module
module.new = new
module.isEntity = isEntity
return setmetatable(module, {__call = function(_, ...) return new(...) end})

