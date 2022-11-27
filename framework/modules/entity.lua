
----------------------------------------------------[[ == BASE OBJECTS == ]]----------------------------------------------------

local module = {
	["TotalCreated"] = 0;
}

local Entity = {}
Entity.__index = Entity
Entity.__tostring = function(tab) return "{Entity: " .. tostring(tab.Id) .. "}" end



----------------------------------------------------[[ == SHADER == ]]----------------------------------------------------
--[[
-- outline shader shamelessly copied from https://blogs.love2d.org/content/let-it-glow-dynamically-adding-outlines-characters
local outlineShader = love.graphics.newShader([ [
vec4 resultCol;
extern vec2 stepSize;
extern vec4 outlineColor; // TODO: implement this!

vec4 effect(vec4 col, Image texture, vec2 texturePos, vec2 screenPos) {
	// get color of pixels:
	number alpha = 4 * texture2D(texture, texturePos).a;
	alpha -= texture2D( texture, texturePos + vec2(stepSize.x, 0.0f)).a;
	alpha -= texture2D( texture, texturePos + vec2(-stepSize.x, 0.0f)).a;
	alpha -= texture2D( texture, texturePos + vec2(0.0f, stepSize.y)).a;
	alpha -= texture2D( texture, texturePos + vec2(0.0f, -stepSize.y)).a;

	// calculate resulting color
	resultCol = vec4(1.0f, 1.0f, 1.0f, alpha) * outlineColor;
	// return color for current pixel
	return resultCol;
}
] ])
]]


----------------------------------------------------[[ == METHODS == ]]----------------------------------------------------

local function isEntity(t)
	return getmetatable(t) == Entity
end


function Entity:setShape(shape)
	assert(shape == "ellipse" or shape == "rectangle", "Entity:setShape(shape) only accepts \"ellipse\" or \"rectangle\" as its arguments")
	self.Shape = shape
end

--[[
function Entity:outline()

end
]]



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

