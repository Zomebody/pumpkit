
----------------------------------------------------[[ == BASE OBJECTS == ]]----------------------------------------------------

local module = {
	["TotalCreated"] = 0;
}

local Mask = {}
Mask.__index = Mask
Mask.__tostring = function(tab) return "{Mask: " .. tostring(tab.Id) .. "}" end


local maskMesh = nil



----------------------------------------------------[[ == METHODS == ]]----------------------------------------------------

local function isMask(t)
	return getmetatable(t) == Mask
end


function Mask:attach(scene3d)
	assert(scene3.isScene3(scene3d), "Mask:attach(scene3) requires argument 'scene3' to be a scene3.")
	scene3d:attachMask(self)
end


function Mask:detach()
	self.Scene:detachMask(self)
end




----------------------------------------------------[[ == OBJECT CREATION == ]]----------------------------------------------------

local function initMesh()
	local tris = {}
	local prevInner = vector2.fromAngle(0)
	local prevOuter = vector2.fromAngle(0)
	for i = 1, 32 do
		-- both magnitude 1
		local inner = vector2.fromAngle(i / 16 * math.pi)
		local outer = vector2.fromAngle(i / 16 * math.pi)
		-- triangle 1 (inner)
		table.insert(tris, {0, 0, 1})
		table.insert(tris, {prevInner.x, prevInner.y, 1})
		table.insert(tris, {inner.x, inner.y, 1})
		-- triangle 2 (outer 1)
		table.insert(tris, {prevInner.x, prevInner.y, 1})
		table.insert(tris, {prevOuter.x, prevOuter.y, 0})
		table.insert(tris, {inner.x, inner.y, 1})
		-- triangle 3 (outer 2)
		table.insert(tris, {inner.x, inner.y, 1})
		table.insert(tris, {prevOuter.x, prevOuter.y, 0})
		table.insert(tris, {outer.x, outer.y, 0})

		prevInner = inner
		prevOuter = outer
	end

	local mesh = love.graphics.newMesh(
		{
			{"VertexPosition", "float", 2},
			{"VertexIsInner", "float", 1}
		},
		tris,
		"triangles",
		"static"
	)

	maskMesh = mesh

	return mesh
end



local function new(position, innerRadius, outerRadius)

	if maskMesh == nil then
		initMesh()
	end

	module.TotalCreated = module.TotalCreated + 1

	local Obj = {
		["Id"] = module.TotalCreated;
		["Mesh"] = maskMesh;
		["Position"] = vector3(position);
		["InnerRadius"] = 0.5;
		["OuterRadius"] = 1;
		["Scene"] = nil;
	}

	setmetatable(Obj, Mask)
	
	return Obj
end



----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

-- pack up and return module
module.new = new
module.isMask = isMask
return setmetatable(module, {__call = function(_, ...) return new(...) end})











