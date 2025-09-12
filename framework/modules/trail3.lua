

----------------------------------------------------[[ == BASE OBJECTS == ]]----------------------------------------------------

local module = {
	["TotalCreated"] = 0;
}

local UP_DIRECTION = vector3(0, 0, 1)
local FRONT_DIRECTION = vector3(0, 1, 0)


local Trail3 = {}
Trail3.__index = Trail3
Trail3.__tostring = function(tab) return "{Trail3 (" .. tostring(tab.MaxParticles) .. ")}" end



----------------------------------------------------[[ == HELPER FUNCTIONS == ]]----------------------------------------------------

-- calculates the left and right side coordinates of the trail at the given point on the cur
function calculateSides(Trail, point, direction)
	if Trail.FacesCamera == false then
		local right
		if direction.z < 0.999999 then
			right = direction:cross(UP_DIRECTION)
		else
			right = FRONT_DIRECTION:cross(direction) -- this situation should never really occur but it's good to have it just in case
		end
		return point - right * 0.5 * Trail.Width, point + right * 0.5 * Trail.Width
	else
		if Trail.Scene == nil then
			error("failed to calculate Trail3's sides as it is not attached to a scene3")
		end
		local camDirection = Trail.Scene:getCamera():getLookVector()
		local right
		if math.abs(direction:dot(camDirection)) < 0.999999 then
			right = -direction:cross(camDirection)
		else
			right = FRONT_DIRECTION:cross(direction) -- idem, rare situation alert. IDK IF THIS IS CORRECT BUT IT'S KINDA HARD TO TEST LOL
		end
		return point - right * 0.5 * Trail.Width, point + right * 0.5 * Trail.Width
	end
end




----------------------------------------------------[[ == FUNCTIONS == ]]----------------------------------------------------

-- check if an object is a particles3
local function isTrail3(t)
	return getmetatable(t) == Trail3
end



-- assumes the correct shader is already set - which is done in scene3
-- trails won't draw depth as they're semi-transparent in nature. They're drawn after semi-transparent objects meaning they won't show behind those
-- trails aren't sorted either
-- also don't forget to have disabled backface culling!
function Trail3:draw(shaderRef)
	-- update the geometry of the mesh!
	local age = love.timer.getTime() - self.SpawnedAt

	-- calculate where on the path segments are so we can calculate the range of vertices to draw
	local x1 = age / self.Duration -- where on the path the front (right) of the trail is, where 0 = start, 1 = end
	local x0 = (age - self.Length) / self.Duration -- where on the path the back (left) of the trail is, where 0 = start, 1 = end

	-- don't draw if the trail falls fully outside the path
	if x1 < 0 or x0 > 1 then
		return
	end

	profiler:pushLabel("draw range")

	local segsOnPath = self.Segments * self.Duration / self.Length -- how many segments the trail would need at minimum to be able to fill the whole path at once
	local segsPerSecond = segsOnPath / self.Duration -- how many segments travel across any point on the path per second
	-- how many segments to cut off both ends of the trail at the given moment in time based on how far along the path the trail is
	local cutAtRight = math.max(0, -segsOnPath + segsPerSecond * age) -- if would have been negative/0, the front of the trail has yet to pass the end-point of the path
	local cutAtLeft = math.max(0, self.Segments - segsPerSecond * age) -- if would have been negative/0, the back of the trail has already passed the starting point of the path

	-- calculate the range of segments to be drawn based on where along the path the segments are
	-- these two are in the range [0, segments]
	local fromEdge = math.min(math.floor(cutAtLeft), self.Segments - 1)
	local toEdge = math.max(1, math.ceil(self.Segments - cutAtRight))

	-- set draw range using the edges we just calculated
	self.Mesh:setDrawRange(1 + 2 * fromEdge, 2 + 2 * (toEdge - fromEdge))

	profiler:popLabel()


	profiler:pushLabel("attributes")
	-- construct for each edge where on the bezier it lays. Also calculates for edges that aren't drawn because it makes the code easier
	local factors = {}
	for i = 0, self.Segments do
		factors[i] = x0 + i / self.Segments * (x1 - x0)
	end

	-- now calculate for each *shown* edge its position & direction on the bezier and use that to update the vertices in the edge on the left and right of the point
	local direction
	local position
	local x
	local left, right
	-- TODO: get scene camera here and if FacesCamera == true but scene is nil, error here. Should on average be a lot faster
	for i = fromEdge, toEdge do
		-- calculate 'x' between 0 and 1
		x = math.max(0, math.min(1, factors[i])) -- clamp because the start/end edge may be cut off, so clamping will put it at the start/end of the path
		direction = self.Path:getVelocityAt(x)
		profiler:pushLabel("point")
		position = self.Path:getPoint(x)
		profiler:popLabel()

		profiler:pushLabel("sides")
		left, right = calculateSides(self, position, direction)
		profiler:popLabel()

		self.Mesh:setVertexAttribute(1 + 2 * i, 1, left.x, left.y, left.z)
		self.Mesh:setVertexAttribute(2 + 2 * i, 1, right.x, right.y, right.z)
	end

	profiler:popLabel()

	profiler:pushLabel("vars & draw")

	-- also uhh send the actual shader variables
	shaderRef:send("meshTexture", self.Texture)
	shaderRef:send("meshBrightness", self.Brightness)
	shaderRef:send("meshColor", {self.Color.r, self.Color.g, self.Color.b})

	love.graphics.draw(self.Mesh)

	profiler:popLabel()
end



function Trail3:emit()
	-- this is literally just it, lol
	self.SpawnedAt = love.timer.getTime()
end



function Trail3:attach(scene3d)
	assert(scene3.isScene3(scene3d), "trail3:attach(scene3) requires argument 'scene3' to be a scene3.")
	scene3d:attachTrail(self)
end



function Trail3:detach()
	-- remove it from the scene
	self.Scene:detachTrail(self)
end



-- create a new particle emitter which uses the given image and can emit at most maxParticles at once
local function new(path, segments, img)
	assert(bezier.isBezier(path) and path.Dimensions == 3, "Trail3.newTrail3(path, segments, img) failed because 'bezier' is not a 3d bezier.")
	assert(type(segments) == "number" and segments >= 1 and segments <= 100, "Trail3.newTrail3(path, segments, img) failed because 'segments' is not a number or out of the range 1-100")
	-- if no image is supplied, just create a white pixel I suppose
	if img == nil then
		local imgData = love.image.newImageData(1, 1)
		imgData:mapPixel(function() return 1, 1, 1, 1 end)
		img = love.graphics.newImage(imgData)
	end

	-- create mesh data
	local meshData = {}
	for i = 0, segments do
		-- positional data doesn't really matter as it will change every frame anyway
		-- the only thing that doesn't change is the UV coordinates, so we make sure to fill those in correctly
		table.insert(meshData, {0, 0, 0, i / segments, 0}) -- trails textures are horizontal! (right side is pointing 'forwards')
		table.insert(meshData, {0, 0, 0, i / segments, 1})
	end


	-- don't need normals because we're not doing any fancy lighting
	local mesh = love.graphics.newMesh(
		{
			{"VertexPosition", "float", 3},
			{"VertexTexCoord", "float", 2}
		},
		meshData,
		"strip", -- omg first time using strip!!!
		"stream"
	)


	module.TotalCreated = module.TotalCreated + 1

	local Obj = {
		["Id"] = module.TotalCreated;
		["Mesh"] = mesh;
		["Segments"] = segments;
		["Texture"] = img;
		["Path"] = path; -- setting bezier by reference, this should never go wrong since beziers cannot be changed after creation anyway
		["Duration"] = 1; -- how long it takes to travel from start to finish across the path (in seconds)
		["Length"] = 0.5; -- how long a section of the path has any piece of the mesh displayed over it (in seconds)
		["Width"] = 1; -- how wide the trail is in world units
		["Angle"] = 0; -- if 0, faces world-up, then rotates around its heading direction based on angle
		["FacesCamera"] = false; -- if true it will be rotated to face the scene's camera
		["Brightness"] = 1; -- how much it's affected by the ambient lighting
		["Color"] = color(1, 1, 1);

		["SpawnedAt"] = -math.huge;

		["Scene"] = nil;
	}

	return setmetatable(Obj, Trail3)
end



function Trail3:__tostring()
	return "{Trail3 #" .. tostring(self.Id) .. ": " .. tostring(self.Segments) .. "}"
end




----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

module.newTrail3 = newTrail3
module.isTrail3 = isTrail3
return setmetatable(module, {__call = function(_, ...) return new(...) end})



