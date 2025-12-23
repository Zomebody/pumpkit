
----------------------------------------------------[[ == BASE OBJECTS == ]]----------------------------------------------------

local module = {
	["TotalCreated"] = 0;
}

local Mask = {}
Mask.__index = Mask
Mask.__tostring = function(tab) return "{Mask: " .. tostring(tab.Id) .. "}" end


local maskMesh = nil



----------------------------------------------------[[ == CREATE TEXTURE == ]]----------------------------------------------------

local kernel = {
	{0, 32, 8, 40, 2, 34, 10, 42},
	{48, 16, 56, 24, 50, 18, 58, 26},
	{12, 44, 4, 36, 14, 46, 6, 38},
	{60, 28, 52, 20, 62, 30, 54, 22},
	{3, 35, 11, 43, 1, 33, 9, 41},
	{51, 19, 59, 27, 49, 17, 57, 25},
	{15, 47, 7, 39, 13, 45, 5, 37},
	{63, 31, 55, 23, 61, 29, 53, 21}
}

local imgData = love.image.newImageData(8, 8)
imgData:mapPixel(
	function(x, y, r, g, b, a)
		local value = kernel[x + 1][y + 1] / 63
		return value, value, value, 1
	end
)
local meshTexture = love.graphics.newImage(imgData)
meshTexture:setWrap("repeat")



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

	mesh:setTexture(meshTexture)
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
		["InnerRadius"] = innerRadius;
		["OuterRadius"] = outerRadius;
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











