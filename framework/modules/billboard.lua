
----------------------------------------------------[[ == BASE OBJECTS == ]]----------------------------------------------------

local module = {
	["TotalCreated"] = 0;
}

local Billboard = {}
Billboard.__index = Billboard
Billboard.__tostring = function(tab) return "{Billboard: " .. tostring(tab.Id) .. "}" end



----------------------------------------------------[[ == METHODS == ]]----------------------------------------------------

local function isBillboard(t)
	return getmetatable(t) == Billboard
end


function Billboard:attach(scene3d)
	assert(scene3.isScene3(scene3d), "Billboard:attach(scene3) requires argument 'scene3' to be a scene3.")
	scene3d:attachBillboard(self)
end


function Billboard:detach()
	self.Scene:detachBillboard(self)
end




----------------------------------------------------[[ == OBJECT CREATION == ]]----------------------------------------------------

local function new(texture, position)

	-- don't need normals because we're not doing any fancy lighting
	local mesh = love.graphics.newMesh(
		{
			{"VertexPosition", "float", 3},
			{"VertexTexCoord", "float", 2}
		},
		{
			{1, 1, 0, 1, 0},
			{0, 1, 0, 0, 0},
			{1, 0, 0, 1, 1},
			{1, 0, 0, 1, 1},
			{0, 1, 0, 0, 0},
			{0, 0, 0, 0, 1}
		},
		"triangles",
		"static"
	)
	mesh:setTexture(texture)

	module.TotalCreated = module.TotalCreated + 1

	local Obj = {
		["Id"] = module.TotalCreated;
		["Mesh"] = mesh;
		["Position"] = vector3(position);
		["Rotation"] = 0; -- radians
		["Center"] = vector2(0.5, 0.5); -- 0,0 = bottom left, 1,1 = top right
		["WorldSize"] = vector2(1, 1); -- world units
		["PixelSize"] = vector2(0, 0); -- screen pixels

		["Scene"] = nil;
	}

	setmetatable(Obj, Billboard)
	
	return Obj
end



----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

-- pack up and return module
module.new = new
module.isBillboard = isBillboard
return setmetatable(module, {__call = function(_, ...) return new(...) end})











