
----------------------------------------------------[[ == BASE OBJECTS == ]]----------------------------------------------------

local module = {
	["TotalCreated"] = 0;
}

local Spritemesh3 = {}
Spritemesh3.__index = Spritemesh3
Spritemesh3.__tostring = function(tab) return "{Spritemesh3: " .. tostring(tab.Id) .. "}" end



----------------------------------------------------[[ == METHODS == ]]----------------------------------------------------

local function isSpritemesh3(t)
	return getmetatable(t) == Spritemesh3
end



function Spritemesh3:move(offset)
	assert(vector3.isVector3(offset), "Spritemesh3:move(offset) requires argument 'offset' to be of type vector3.")
	self.Position = self.Position + offset
end



function Spritemesh3:moveLocal(offset)
	assert(vector3.isVector3(offset), "Spritemesh3:moveLocal(offset) requires argument 'offset' to be of type vector3.")
	local localVector = matrix4():rotateX(self.Rotation.x):rotateY(self.Rotation.y):rotateZ(self.Rotation.z):toWorldVector(offset)
	self.Position = self.Position + localVector
end



function Spritemesh3:rotate(rotation)
	assert(vector3.isVector3(rotation), "Spritemesh3:rotate(rotation) requires argument 'rotation' to be of type vector3.")
	self.Rotation = self.Rotation + rotation
end



function Spritemesh3:rotateLocal(rotation)
	assert(vector3.isVector3(rotation), "Spritemesh3:rotateLocal(rotation) requires argument 'rotation' to be of type vector3.")
	local applyMatrix = matrix4():rotateX(rotation.x):rotateY(rotation.y):rotateZ(rotation.z)
	local curMatrix = matrix4():rotateX(self.Rotation.x):rotateY(self.Rotation.y):rotateZ(self.Rotation.z)
	local combinedMatrix = curMatrix * applyMatrix
	self.Rotation = combinedMatrix:toEuler("xyz")
end



function Spritemesh3:clone()
	local Mesh = new(self.Mesh, self.Position, self.Rotation, self.Scale, self.Color)
	Mesh.Brightness = self.Brightness
	Mesh.Bloom = self.Bloom
	Mesh.Transparency = self.Transparency
	
	-- keep the scene nil
	return Mesh
end



function Spritemesh3:detach()
	-- remove it from the scene
	-- unlink the scene property
	--local index = findMeshInOrderedArray(self.Scene.BasicMeshes, Obj)
	self.Scene:detachSpriteMesh(self)
end





----------------------------------------------------[[ == OBJECT CREATION == ]]----------------------------------------------------

local function new(meshRef, sheetSize, position, rotation, scale, col)
	assert(meshRef:getTexture() ~= nil, "Spritemesh3.new(meshRef, sheetSize, position, rotation, scale, col) failed because meshRef does not have a texture set.")
	assert(sheetSize == nil or vector2.isVector2(sheetSize), "Spritemesh3.new(meshRef, sheetSize, position, rotation, scale, col) requires argument 'sheetSize' to be nil or a vector2.")
	assert(position == nil or vector3.isVector3(position), "Spritemesh3.new(meshRef, sheetSize, position, rotation, scale, col) requires argument 'position' to be nil or a vector3.")
	assert(rotation == nil or vector3.isVector3(rotation), "Spritemesh3.new(meshRef, sheetSize, position, rotation, scale, col) requires argument 'rotation' to be nil or a vector3.")
	assert(scale == nil or vector3.isVector3(scale), "Spritemesh3.new(meshRef, sheetSize, position, rotation, scale, col) requires argument 'scale' to be nil or a vector3.")
	assert(col == nil or color.isColor(col), "Spritemesh3.new(meshRef, position, sheetSize, rotation, scale, col) requires argument 'col' to be nil or a color.")

	module.TotalCreated = module.TotalCreated + 1

	local Obj = {
		["Id"] = module.TotalCreated;
		["Mesh"] = meshRef;
		["Position"] = position ~= nil and vector3(position) or vector3(0, 0, 0);
		["Rotation"] = rotation ~= nil and vector3(rotation) or vector3(0, 0, 0);
		["Scale"] = scale ~= nil and vector3(scale) or vector3(1, 1, 1);
		["Color"] = col ~= nil and color(col) or color(1, 1, 1);
		["Brightness"] = 0;
		["Bloom"] = 0;
		["Transparency"] = 0;
		-- no CastShadow since it complicates the shadowmap shader too much
		["SheetSize"] = vector2(sheetSize) or vector2(1, 1);
		["SpritePosition"] = vector2(1, 1);
		["Scene"] = nil;
	}

	setmetatable(Obj, Spritemesh3)
	
	return Obj
end



----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

-- pack up and return module
module.new = new
module.isSpritemesh3 = isSpritemesh3
return setmetatable(module, {__call = function(_, ...) return new(...) end})











