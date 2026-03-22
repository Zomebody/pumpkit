
----------------------------------------------------[[ == BASE OBJECTS == ]]----------------------------------------------------

local module = {
	["TotalCreated"] = 0;
}

local Mesh3Group = {}
Mesh3Group.__index = Mesh3Group
Mesh3Group.__tostring = function(tab) return "{Mesh3Group: " .. tostring(tab.Id) .. "}" end
--[[
local attributeIndex = {
	["Position"] = 1;
	["Rotation"] = 2;
	["Scale"] = 3;
	["Color"] = 4;
	["ColorShadow"] = 5;
}
]]


----------------------------------------------------[[ == METHODS == ]]----------------------------------------------------

local function isMesh3Group(t)
	return getmetatable(t) == Mesh3Group
end


function Mesh3Group:attach(scene3d)
	assert(scene3.isScene3(scene3d), "mesh3group:attach(scene3) requires argument 'scene3' to be a scene3.")
	scene3d:attachMesh(self)
end


function Mesh3Group:detach()
	-- remove it from the scene
	-- unlink the scene property
	self.Scene:detachMesh(self)
end

--[[
function Mesh3Group:changeInstance(index, property, newValue)
	self.Instances:setVertexAttribute(index, attributeIndex[property], newValue:components())
end
]]



----------------------------------------------------[[ == OBJECT CREATION == ]]----------------------------------------------------

local function new(mesh, positions, rotations, scales, cols, shadowcols)
	assert(type(positions) == "table", "mesh3group.new(mesh, positions, rotations, scales, cols, shadowcols) requires argument 'positions' to be a table of vector3s, given is nil")
	if rotations == nil then
		rotations = {}
		for i = 1, #positions do rotations[i] = vector3(0, 0, 0) end
	else
		assert(type(rotations) == "table" and #rotations == #positions,
			"mesh3group.new(mesh, positions, rotations, scales, cols, shadowcols) requires argument 'rotations' to be nil or a table with vector3s of the same length as 'positions'")
	end
	if scales == nil then
		scales = {}
		for i = 1, #positions do scales[i] = vector3(1, 1, 1) end
	else
		assert(type(scales) == "table" and #scales == #positions,
			"mesh3group.new(mesh, positions, rotations, scales, cols, shadowcols) requires argument 'scales' to be nil or a table with vector3s of the same length as 'positions'")
	end
	if cols == nil then
		cols = {}
		for i = 1, #positions do cols[i] = color(1, 1, 1) end
	else
		assert(type(cols) == "table" and #cols == #positions,
			"mesh3group.new(mesh, positions, rotations, scales, cols, shadowcols) requires argument 'cols' to be nil or a table with colors of the same length as 'positions'")
	end
	if shadowcols == nil then
		shadowcols = {}
		for i = 1, #positions do shadowcols[i] = color(0, 0, 0) end
	else
		assert(type(shadowcols) == "table" and #shadowcols == #positions,
			"mesh3group.new(mesh, positions, rotations, scales, cols, shadowcols) requires argument 'shadowcols' to be nil or a table with colors of the same length as 'positions'")
	end

	local instancesData = {}
	for i = 1, #positions do
		local meshMatrix = matrix4.fromTransforms(positions[i], rotations[i], scales[i])
		table.insert(
			instancesData,
			{
				--positions[i].x, positions[i].y, positions[i].z, rotations[i].x, rotations[i].y, rotations[i].z, scales[i].x, scales[i].y, scales[i].z,
				meshMatrix[1], meshMatrix[2], meshMatrix[3], meshMatrix[4],
				meshMatrix[5], meshMatrix[6], meshMatrix[7], meshMatrix[8],
				meshMatrix[9], meshMatrix[10], meshMatrix[11], meshMatrix[12],
				meshMatrix[13], meshMatrix[14], meshMatrix[15], meshMatrix[16],
				cols[i].r, cols[i].g, cols[i].b,
				shadowcols[i].r, shadowcols[i].g, shadowcols[i].b
			}
		)
	end

	-- TODO: replacve position, rotation, scale with 4 attributes corresponding to the 4 rows (or columns? probs columns) of the model matrix
	local instanceMesh = love.graphics.newMesh(
		{
			{"instMatColumn1", "float", 4},
			{"instMatColumn2", "float", 4},
			{"instMatColumn3", "float", 4},
			{"instMatColumn4", "float", 4},
			--{"instancePosition", "float", 3}, -- column 1
			--{"instanceRotation", "float", 3}, -- column 2
			--{"instanceScale", "float", 3}, -- column 3
			-- column 4
			{"instanceColor", "float", 3},
			{"instanceColorShadow", "float", 3}
		},
		instancesData,
		"triangles",
		"static"
	)

	--mesh:attachAttribute("instancePosition", instanceMesh, "perinstance") -- first vertex attribute
	--mesh:attachAttribute("instanceRotation", instanceMesh, "perinstance") -- second vertex attribute
	--mesh:attachAttribute("instanceScale", instanceMesh, "perinstance") -- third vertex attribute
	mesh:attachAttribute("instMatColumn1", instanceMesh, "perinstance")
	mesh:attachAttribute("instMatColumn2", instanceMesh, "perinstance")
	mesh:attachAttribute("instMatColumn3", instanceMesh, "perinstance")
	mesh:attachAttribute("instMatColumn4", instanceMesh, "perinstance")
	mesh:attachAttribute("instanceColor", instanceMesh, "perinstance")
	mesh:attachAttribute("instanceColorShadow", instanceMesh, "perinstance")

	module.TotalCreated = module.TotalCreated + 1

	local Obj = {
		["Id"] = module.TotalCreated;
		["Mesh"] = mesh;
		["Texture"] = nil;
		["Instances"] = instanceMesh;
		["Brightness"] = 0;
		["Bloom"] = 0;
		["FresnelColor"] = color(1, 1, 1);
		["FresnelStrength"] = 0;
		["FresnelPower"] = 1;
		["Masked"] = false;
		["Silhouette"] = false;
		["CastShadow"] = false;
		["NormalMap"] = nil;
		["Count"] = #positions;
		["Scene"] = nil;
	}

	setmetatable(Obj, Mesh3Group)
	
	return Obj
end



----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

-- pack up and return module
module.new = new
module.isMesh3Group = isMesh3Group
return setmetatable(module, {__call = function(_, ...) return new(...) end})











