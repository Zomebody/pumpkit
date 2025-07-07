
----------------------------------------------------[[ == BASE OBJECTS == ]]----------------------------------------------------

local module = {
	["TotalCreated"] = 0;
}

local Foliage3 = {}
Foliage3.__index = Foliage3
Foliage3.__tostring = function(tab) return "{Foliage3: " .. tostring(tab.Id) .. "}" end



----------------------------------------------------[[ == METHODS == ]]----------------------------------------------------

local function isFoliage3(t)
	return getmetatable(t) == Foliage3
end


function Foliage3:attach(scene3d)
	assert(scene3.isScene3(scene3d), "Foliage3:attach(scene3) requires argument 'scene3' to be a scene3.")
	scene3d:attachMesh(self)
end


function Foliage3:detach()
	-- remove it from the scene
	-- unlink the scene property
	--local index = findMeshInOrderedArray(self.Scene.BasicMeshes, Obj)
	self.Scene:detachMesh(self)
end





----------------------------------------------------[[ == OBJECT CREATION == ]]----------------------------------------------------

local function new(mesh, positions, rotations, scales, cols)
	assert(type(bloom) == "number" or bloom == nil, "foliage3.new(mesh, positions, rotations, scales, cols) requires 'bloom' to be a number or nil")
	assert(type(brightness) == "number" or brightness == nil, "foliage3.new(mesh, positions, rotations, scales, cols) requires 'brightness' to be a number or nil")
	assert(type(texScale) == "number" or texScale == nil, "foliage3.new(mesh, positions, rotations, scales, cols) requires 'texScale' to be a number or nil")
	assert(type(positions) == "table", "foliage3.new(mesh, positions, rotations, scales, cols) requires argument 'positions' to be a table of vector3s, given is nil")
	if rotations == nil then
		rotations = {}
		for i = 1, #positions do rotations[i] = vector3(0, 0, 0) end
	else
		assert(type(rotations) == "table" and #rotations == #positions,
			"foliage3.new(mesh, positions, rotations, scales, cols) requires argument 'rotations' to be nil or a table with vector3s of the same length as 'positions'")
	end
	if scales == nil then
		scales = {}
		for i = 1, #positions do scales[i] = vector3(1, 1, 1) end
	else
		assert(type(scales) == "table" and #scales == #positions,
			"foliage3.new(mesh, positions, rotations, scales, cols) requires argument 'scales' to be nil or a table with vector3s of the same length as 'positions'")
	end
	if cols == nil then
		cols = {}
		for i = 1, #positions do cols[i] = color(1, 1, 1) end
	else
		assert(type(cols) == "table" and #cols == #positions,
			"foliage3.new(mesh, positions, rotations, scales, cols) requires argument 'cols' to be nil or a table with colors of the same length as 'positions'")
	end

	local instancesData = {}
	for i = 1, #positions do
		table.insert(
			instancesData,
			{positions[i].x, positions[i].y, positions[i].z, rotations[i].x, rotations[i].y, rotations[i].z, scales[i].x, scales[i].y, scales[i].z, cols[i].r, cols[i].g, cols[i].b}
		)
	end


	local instanceMesh = love.graphics.newMesh(
		{
			{"instancePosition", "float", 3},
			{"instanceRotation", "float", 3},
			{"instanceScale", "float", 3},
			{"instanceColor", "float", 3}
		},
		instancesData,
		"triangles",
		"static"
	)

	mesh:attachAttribute("instancePosition", instanceMesh, "perinstance") -- first vertex attribute
	mesh:attachAttribute("instanceRotation", instanceMesh, "perinstance") -- second vertex attribute
	mesh:attachAttribute("instanceScale", instanceMesh, "perinstance") -- third vertex attribute
	mesh:attachAttribute("instanceColor", instanceMesh, "perinstance") -- fourth vertex attribute

	module.TotalCreated = module.TotalCreated + 1

	local Obj = {
		["Id"] = module.TotalCreated;
		["Mesh"] = mesh;
		["Texture"] = nil;
		["Instances"] = instanceMesh;
		["Brightness"] = 0;
		["CastShadow"] = false;
		["NormalMap"] = nil;
		["Count"] = #positions;

		["Scene"] = nil;
	}

	setmetatable(Obj, Foliage3)
	
	return Obj
end



----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

-- pack up and return module
module.new = new
module.isFoliage3 = isFoliage3
return setmetatable(module, {__call = function(_, ...) return new(...) end})











