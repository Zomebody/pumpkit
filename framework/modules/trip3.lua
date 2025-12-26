-- SAME INTERNAL STRUCTURE AS MESH3, IT'S JUST THE SHADERS THAT ACT DIFFERENTLY
----------------------------------------------------[[ == BASE OBJECTS == ]]----------------------------------------------------

local module = {
	["TotalCreated"] = 0;
}

local Trip3 = {}
Trip3.__index = Trip3
Trip3.__tostring = function(tab) return "{Trip3: " .. tostring(tab.Id) .. "}" end



----------------------------------------------------[[ == METHODS == ]]----------------------------------------------------

local function isTrip3(t)
	return getmetatable(t) == Trip3
end



function Trip3:move(offset)
	assert(vector3.isVector3(offset), "Trip3:move(offset) requires argument 'offset' to be of type vector3.")
	self.Position = self.Position + offset
end



function Trip3:moveLocal(offset)
	assert(vector3.isVector3(offset), "Trip3:moveLocal(offset) requires argument 'offset' to be of type vector3.")
	local localVector = matrix4():rotateX(self.Rotation.x):rotateY(self.Rotation.y):rotateZ(self.Rotation.z):toWorldVector(offset)
	self.Position = self.Position + localVector
end



function Trip3:rotate(rotation)
	assert(vector3.isVector3(rotation), "Trip3:rotate(rotation) requires argument 'rotation' to be of type vector3.")
	self.Rotation = self.Rotation + rotation
end



function Trip3:rotateLocal(rotation)
	assert(vector3.isVector3(rotation), "Trip3:rotateLocal(rotation) requires argument 'rotation' to be of type vector3.")
	local applyMatrix = matrix4():rotateX(rotation.x):rotateY(rotation.y):rotateZ(rotation.z)
	local curMatrix = matrix4():rotateX(self.Rotation.x):rotateY(self.Rotation.y):rotateZ(self.Rotation.z)
	local combinedMatrix = curMatrix * applyMatrix
	self.Rotation = combinedMatrix:toEulerXYZ()
end



function Trip3:clone()
	local Mesh = new(self.Mesh, self.Position, self.Rotation, self.Scale, self.Color)
	Mesh.Texture = self.Texture
	Mesh.Brightness = self.Brightness
	Mesh.Bloom = self.Bloom
	Mesh.FresnelColor = color(self.FresnelColor)
	Mesh.FresnelStrength = self.FresnelStrength
	Mesh.FresnelPower = self.FresnelPower
	Mesh.Transparency = self.Transparency
	Mesh.TextureScale = self.TextureScale
	Mesh.CastShadow = self.CastShadow
	Mesh.NormalMap = self.NormalMap
	-- keep the scene nil
	return Mesh
end


function Trip3:attach(scene3d)
	assert(scene3.isScene3(scene3d), "trip3:attach(scene3) requires argument 'scene3' to be a scene3.")
	scene3d:attachMesh(self)
end


function Trip3:detach()
	-- remove it from the scene
	self.Scene:detachMesh(self)
end





----------------------------------------------------[[ == OBJECT CREATION == ]]----------------------------------------------------

local function new(meshRef, position, rotation, scale, col, scol)
	assert(position == nil or vector3.isVector3(position), "trip3.new(meshRef, position, rotation, scale, col) requires argument 'position' to be nil or a vector3.")
	assert(rotation == nil or vector3.isVector3(rotation), "trip3.new(meshRef, position, rotation, scale, col) requires argument 'rotation' to be nil or a vector3.")
	assert(scale == nil or vector3.isVector3(scale), "trip3.new(meshRef, position, rotation, scale, col) requires argument 'scale' to be nil or a vector3.")
	assert(col == nil or color.isColor(col), "trip3.new(meshRef, position, rotation, scale, col) requires argument 'col' to be nil or a color.")
	assert(scol == nil or color.isColor(scol), "trip3.new(meshRef, position, rotation, scale, col) requires argument 'scol' to be nil or a color.")

	module.TotalCreated = module.TotalCreated + 1

	local Obj = {
		["Id"] = module.TotalCreated;
		["Mesh"] = meshRef;
		["Texture"] = nil;
		["Position"] = position ~= nil and vector3(position) or vector3(0, 0, 0);
		["Rotation"] = rotation ~= nil and vector3(rotation) or vector3(0, 0, 0);
		["Scale"] = scale ~= nil and vector3(scale) or vector3(1, 1, 1);
		["Color"] = col ~= nil and color(col) or color(1, 1, 1);
		["ColorShadow"] = scol ~= nil and color(scol) or color(0.5, 0.5, 0.5);
		["Brightness"] = 0;
		["Bloom"] = 0;
		["FresnelColor"] = color(1, 1, 1);
		["FresnelStrength"] = 0;
		["FresnelPower"] = 1;
		["Masked"] = false;
		["Transparency"] = 0;
		["CastShadow"] = false;
		["TextureScale"] = 1;
		["NormalMap"] = nil;
		["Scene"] = nil;
	}

	setmetatable(Obj, Trip3)
	
	return Obj
end



----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

-- pack up and return module
module.new = new
module.isTrip3 = isTrip3
return setmetatable(module, {__call = function(_, ...) return new(...) end})











