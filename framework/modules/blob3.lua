
----------------------------------------------------[[ == BASE OBJECTS == ]]----------------------------------------------------

local module = {
	["TotalCreated"] = 0;
}

local Blob3 = {}
Blob3.__index = Blob3
Blob3.__tostring = function(tab) return "{Blob3: " .. tostring(tab.Id) .. "}" end



----------------------------------------------------[[ == METHODS == ]]----------------------------------------------------

local function isBlob3(t)
	return getmetatable(t) == Blob3
end



function Blob3:move(offset)
	assert(vector3.isVector3(offset), "Blob3:move(offset) requires argument 'offset' to be of type vector3.")
	self.Position = self.Position + offset
end


function Blob3:clone()
	local Blob = new(self.Position, self.Range)
	-- keep the scene nil
	return Blob
end



function Blob3:detach()
	self.Scene:detachBlob(self)
end





----------------------------------------------------[[ == OBJECT CREATION == ]]----------------------------------------------------

local function new(position, range)
	assert(position == nil or vector3.isVector3(position), "Blob3.new(position, range) requires argument 'position' to be nil or a vector3.")
	assert(range == nil or type(range) == "number", "Blob3.new(position, range) requires argument 'range' to be nil or a number.")

	module.TotalCreated = module.TotalCreated + 1

	local Obj = {
		["Id"] = module.TotalCreated;
		["Position"] = position ~= nil and vector3(position) or vector3(0, 0, 0);
		["Range"] = range ~= nil and range or 1;
		["Scene"] = nil;
	}

	setmetatable(Obj, Blob3)
	
	return Obj
end



----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

-- pack up and return module
module.new = new
module.isBlob3 = isBlob3
return setmetatable(module, {__call = function(_, ...) return new(...) end})











