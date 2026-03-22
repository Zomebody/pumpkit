
----------------------------------------------------[[ == BASE OBJECTS == ]]----------------------------------------------------

local module = {
	["TotalCreated"] = 0;
}

local Spritemesh3 = {}
--Spritemesh3.__index = Spritemesh3
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


-- this is probably very inefficient. Probably better to edit the matrix and then rawset the rotation
function Spritemesh3:rotateLocal(rotation)
	assert(vector3.isVector3(rotation), "Spritemesh3:rotateLocal(rotation) requires argument 'rotation' to be of type vector3.")
	local applyMatrix = matrix4():rotateX(rotation.x):rotateY(rotation.y):rotateZ(rotation.z)
	local curMatrix = matrix4():rotateX(self.Rotation.x):rotateY(self.Rotation.y):rotateZ(self.Rotation.z)
	local combinedMatrix = curMatrix * applyMatrix
	self.Rotation = combinedMatrix:toEulerXYZ()
end



function Spritemesh3:clone()
	local SMesh = new(self.Mesh, self.SheetSize, self.Position, self.Rotation, self.Scale, self.Color)
	SMesh.Texture = self.Texture
	SMesh.Brightness = self.Brightness
	SMesh.Bloom = self.Bloom
	SMesh.Transparency = self.Transparency
	SMesh.SheetSize = vector2(self.SheetSize)
	SMesh.SpritePosition = vector2(self.SpritePosition)
	
	-- keep the scene nil
	return SMesh
end


function Spritemesh3:attach(scene3d)
	assert(scene3.isScene3(scene3d), "spritemesh3:attach(scene3) requires argument 'scene3' to be a scene3.")
	scene3d:attachMesh(self)
end



function Spritemesh3:detach()
	self.Scene:detachMesh(self)
end





----------------------------------------------------[[ == OBJECT CREATION == ]]----------------------------------------------------

local function new(meshRef, sheetSize, position, rotation, scale, col, scol)
	assert(sheetSize == nil or vector2.isVector2(sheetSize), "Spritemesh3.new(meshRef, sheetSize, position, rotation, scale, col, scol) requires argument 'sheetSize' to be nil or a vector2.")
	assert(position == nil or vector3.isVector3(position), "Spritemesh3.new(meshRef, sheetSize, position, rotation, scale, col, scol) requires argument 'position' to be nil or a vector3.")
	assert(rotation == nil or vector3.isVector3(rotation), "Spritemesh3.new(meshRef, sheetSize, position, rotation, scale, col, scol) requires argument 'rotation' to be nil or a vector3.")
	assert(scale == nil or vector3.isVector3(scale), "Spritemesh3.new(meshRef, sheetSize, position, rotation, scale, col, scol) requires argument 'scale' to be nil or a vector3.")
	assert(col == nil or color.isColor(col), "Spritemesh3.new(meshRef, position, sheetSize, rotation, scale, col, scol) requires argument 'col' to be nil or a color.")
	assert(scol == nil or color.isColor(scol), "Spritemesh3.new(meshRef, position, sheetSize, rotation, scale, col, scol) requires argument 'scol' to be nil or a color.")

	module.TotalCreated = module.TotalCreated + 1

	position = (position ~= nil) and vector3(position) or vector3(0, 0, 0)
	rotation = (rotation ~= nil) and vector3(rotation) or vector3(0, 0, 0)
	scale = (scale ~= nil) and vector3(scale) or vector3(1, 1, 1)

	local Obj = {
		["Id"] = module.TotalCreated;
		["Mesh"] = meshRef;
		["Texture"] = nil;
		["Color"] = col ~= nil and color(col) or color(1, 1, 1);
		["ColorShadow"] = col ~= nil and color(col) or color(1, 1, 1);
		["Brightness"] = 0;
		["Bloom"] = 0;
		["Silhouette"] = false;
		["Transparency"] = 0;
		["SheetSize"] = vector2(sheetSize) or vector2(1, 1);
		["SpritePosition"] = vector2(1, 1);
		["Scene"] = nil;

		["Matrix"] = matrix4.fromTransforms(position, rotation, scale);
		["_Position"] = position;
		["_Rotation"] = rotation;
		["_Scale"] = scale;
	}

	setmetatable(Obj, Spritemesh3)
	
	return Obj
end



----------------------------------------------------[[ == METATABLE STUFF == ]]----------------------------------------------------

function Spritemesh3:__newindex(key, value)
	if key == "Position" then
		rawset(self, "_Position", value)
		rawset(self, "Matrix", matrix4.fromTransforms(value, self._Rotation, self._Scale))
	elseif key == "Rotation" then
		rawset(self, "_Rotation", value)
		rawset(self, "Matrix", matrix4.fromTransforms(self._Position, value, self._Scale))
	elseif key == "Scale" then
		rawset(self, "_Scale", value)
		rawset(self, "Matrix", matrix4.fromTransforms(self._Position, self._Rotation, value))
	else
		rawset(self, key, value)
	end
end



function Spritemesh3:__index(key)
	if key == "Position" then
		return self._Position
	elseif key == "Rotation" then
		return self._Rotation
	elseif key == "Scale" then
		return self._Scale
	else
		return rawget(Spritemesh3, key) -- needed to look-up class methods
	end
end



----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

-- pack up and return module
module.new = new
module.isSpritemesh3 = isSpritemesh3
return setmetatable(module, {__call = function(_, ...) return new(...) end})











