
----------------------------------------------------[[ == BASE OBJECTS == ]]----------------------------------------------------

local module = {
	["TotalCreated"] = 0;
}

local Ripplemesh3 = {}
Ripplemesh3.__index = Ripplemesh3
Ripplemesh3.__tostring = function(tab) return "{Ripplemesh3: " .. tostring(tab.Id) .. "}" end

local new



----------------------------------------------------[[ == METHODS == ]]----------------------------------------------------

local function isRipplemesh3(t)
	return getmetatable(t) == Ripplemesh3
end



function Ripplemesh3:move(offset)
	assert(vector3.isVector3(offset), "Ripplemesh3:move(offset) requires argument 'offset' to be of type vector3.")
	self.Position = self.Position + offset
end



function Ripplemesh3:moveLocal(offset)
	assert(vector3.isVector3(offset), "Ripplemesh3:moveLocal(offset) requires argument 'offset' to be of type vector3.")
	local localVector = matrix4():rotateX(self.Rotation.x):rotateY(self.Rotation.y):rotateZ(self.Rotation.z):toWorldVector(offset)
	self.Position = self.Position + localVector
end



function Ripplemesh3:rotate(rotation)
	assert(vector3.isVector3(rotation), "Ripplemesh3:rotate(rotation) requires argument 'rotation' to be of type vector3.")
	self.Rotation = self.Rotation + rotation
end



function Ripplemesh3:rotateLocal(rotation)
	assert(vector3.isVector3(rotation), "Ripplemesh3:rotateLocal(rotation) requires argument 'rotation' to be of type vector3.")
	local applyMatrix = matrix4():rotateX(rotation.x):rotateY(rotation.y):rotateZ(rotation.z)
	local curMatrix = matrix4():rotateX(self.Rotation.x):rotateY(self.Rotation.y):rotateZ(self.Rotation.z)
	local combinedMatrix = curMatrix * applyMatrix
	self.Rotation = combinedMatrix:toEulerXYZ()
end



function Ripplemesh3:clone()
	local RMesh = new(self.Mesh, self.Position, self.Rotation, self.Scale, self.Color, self.FoamColor)
	RMesh.Brightness = self.Brightness
	RMesh.Bloom = self.Bloom
	RMesh.WaterVelocity = vector4(self.WaterVelocity)
	RMesh.FoamVelocity = vector4(self.FoamVelocity)
	RMesh.DistortionVelocity = vector2(self.DistortionVelocity)
	RMesh.NormalMap = self.NormalMap
	RMesh.DataMap = self.DataMap
	
	-- keep the scene nil
	return RMesh
end



function Ripplemesh3:attach(scene3d)
	assert(scene3.isScene3(scene3d), "spritemesh3:attach(scene3) requires argument 'scene3' to be a scene3.")
	scene3d:attachMesh(self)
end



function Ripplemesh3:detach()
	self.Scene:detachMesh(self)
end





----------------------------------------------------[[ == OBJECT CREATION == ]]----------------------------------------------------

new = function(meshRef, position, rotation, scale, col, foamCol)
	assert(meshRef:getTexture() ~= nil, "Ripplemesh3.new(meshRef, position, rotation, scale, col, foamCol) failed because meshRef does not have a texture set.")
	assert(position == nil or vector3.isVector3(position), "Ripplemesh3.new(meshRef, position, rotation, scale, col, foamCol) requires argument 'position' to be nil or a vector3.")
	assert(rotation == nil or vector3.isVector3(rotation), "Ripplemesh3.new(meshRef, position, rotation, scale, col, foamCol) requires argument 'rotation' to be nil or a vector3.")
	assert(scale == nil or vector3.isVector3(scale), "Ripplemesh3.new(meshRef, position, rotation, scale, col, foamCol) requires argument 'scale' to be nil or a vector3.")
	assert(col == nil or color.isColor(col), "Ripplemesh3.new(meshRef, position, rotation, scale, col, foamCol) requires argument 'col' to be nil or a color.")
	assert(foamCol == nil or color.isColor(col), "Ripplemesh3.new(meshRef, position, rotation, scale, col, foamCol) requires argument 'foamCol' to be nil or a color.")

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
		["FresnelColor"] = color(1, 1, 1);
		["FresnelStrength"] = 0;
		["FresnelPower"] = 1;
		["FoamColor"] = foamCol ~= nil and color(foamCol) or color(1, 1, 1);
		["WaterVelocity"] = vector4(0, 0, 0, 0); -- xy = color map velocity, zw = distortion velocity
		["FoamVelocity"] = vector4(0, 0, 0, 0); -- xy = foam 1 velocity, zw = foam 2 velocity
		["DataMap"] = nil; -- r&g = distortion as fraction of image size, b = noise value (foams 1 and 2 share the texture), a = foaminess (0=no foam, 0.3=30%) (if nil, a substitute is used)
		["Scene"] = nil;
	}

	setmetatable(Obj, Ripplemesh3)
	
	return Obj
end



----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

-- pack up and return module
module.new = new
module.isRipplemesh3 = isRipplemesh3
return setmetatable(module, {__call = function(_, ...) return new(...) end})











