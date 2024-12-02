

----------------------------------------------------[[ == BASE OBJECTS == ]]----------------------------------------------------

local module = {}


local Particles3 = {}
Particles3.__index = Particles3
Particles3.__tostring = function(tab) return "{Particles3 (" .. tostring(tab.MaxParticles) .. ")}" end



--[[


so I'm not 100% sure how I want to tackle creating particles yet. The basic idea is to use mesh instances and attributes.
Particle positions can be changed by editing the corresponding attribute of a given particle instance. Particles are quad
meshes that have an image applied to them. The basic implementation allows the user to spawn particles from a given source
into some direction (with a random offset) that will live for a certain duration.

For each particle there should be some data stored that describes the direction the particle was emitted at, its speed,
and the moment at which it was emitted. Using all that info you can calculate the position and size of the particle at
any given moment in time


]]



----------------------------------------------------[[ == HELPER FUNCTIONS == ]]----------------------------------------------------

local function getVectorInCone(vec, maxAngle)
	local vecNormal = vector3(vec):setMag(1)


	-- generate random polar and azimuthal angles (whatever that may mean)
	local theta = math.acos(love.math.random() * (math.cos(maxAngle) - 1) + 1) -- constrain to cone
	local phi = math.random() * 2 * math.pi

	-- convert spherical coordinates to Cartesian coordinates
	local randomVector = vector3(
		math.sin(theta) * math.cos(phi),
		math.sin(theta) * math.sin(phi),
		math.cos(theta)
	)

	---------


	-- align the random vector with the base vector
	local up = vector3(0, 0, 1)
	if math.abs(vecNormal.z) > 0.999 then -- Handle near-vertical vectors
		up = vector3(1, 0, 0)
	end

	-- Compute a rotation matrix
	local right = vector3(
		up.y * vecNormal.z - up.z * vecNormal.y,
		up.z * vecNormal.x - up.x * vecNormal.z,
		up.x * vecNormal.y - up.y * vecNormal.x
	)
	right:setMag(1)
	local upAligned = vector3(
		vecNormal.y * right.z - vecNormal.z * right.y,
		vecNormal.z * right.x - vecNormal.x * right.z,
		vecNormal.x * right.y - vecNormal.y * right.x
	)

	-- apply rotation matrix to random vector
	local newRandomVector = vector3(
		randomVector.x * right.x + randomVector.y * upAligned.x + randomVector.z * vecNormal.x,
		randomVector.x * right.y + randomVector.y * upAligned.y + randomVector.z * vecNormal.y,
		randomVector.x * right.z + randomVector.y * upAligned.z + randomVector.z * vecNormal.z
	)
	newRandomVector:setMag(1)

	return newRandomVector
end



----------------------------------------------------[[ == FUNCTIONS == ]]----------------------------------------------------

-- check if an object is a particles3
local function isParticles3(t)
	return getmetatable(t) == Particles3
end



-- emit a certain number of particles at once from the source
function Particles3:emit(count)
	local t = love.timer.getTime()
	for i = 1, count do
		local randomVector = getVectorInCone(self.Direction, self.DirectionDeviation)
		table.insert(self.Spawned, {t, self.Lifetime:randomDecimal(), self.Rotation:randomDecimal(), self.RotationSpeed:randomDecimal(), randomVector, self.Speed:randomDecimal(), love.math.random() * 2 - 1})
	end
	if #self.Spawned > self.MaxParticles then
		local toRemove = #self.Spawned - self.MaxParticles
		for i = 1, toRemove do
			table.remove(self.Spawned, 1) -- remove the oldest particles
		end
	end
end



-- update the position and size of each particle. TODO: probably rename this to :render() or something, since you'll only need to update the info when you're going to render the particles
-- and you won't be rendering the particle emitter multiple times per frame if you're smart
-- or maybe not. Maybe the play is to manually choose when to update particles so you can have them frozen in time or something
function Particles3:update()
	local time = love.timer.getTime()
	local index = 1
	local loopCount = #self.Spawned
	for i = 1, loopCount do

		-- remove any particles that are too old
		if time - self.Spawned[index][1] > self.Spawned[index][2] then
			table.remove(self.Spawned, index) -- remove the index from the table, shifting all indices after it 1 forwards
		else
			local vars = self.Spawned[index]

			-- if the particle wasn't removed, update its size, position and rotation
			local newPosition = self.Source + vars[5] * vars[6] * (time - vars[1]) + 0.5 * self.Gravity * (time - vars[1])^2
			local newRotation = vars[3] + vars[4] * (time - vars[1])
			local x = (time - vars[1]) / vars[2]
			local newSize = vars[7] * self.SizeDeviation:getNumber(x) + self.Size:getNumber(x)
			local newColor = self.Gradient:getColor(x)

			-- TODO: set the mesh attributes here to new values. It should look something like this:
			--[[
			self.Instances:setVertexAttribute(index, 1, newPosition.x, newPosition.y, newPosition.z)
			self.Instances:setVertexAttribute(index, 2, newRotation)
			self.Instances:setVertexAttribute(index, 3, newSize)
			self.Instances:setVertexAttribute(index, 4, newColor.r, newColor.g, newColor.b)
			]]
			
			-- +10fps for doing this instead of setting each vertex attribute separately
			self.Instances:setVertex(index, newPosition.x, newPosition.y, newPosition.z, newRotation, newSize, newColor.r, newColor.g, newColor.b)


			index = index + 1 -- item was not removed, so move the index one further
		end
	end
end



-- create a new particle emitter which uses the given image and can emit at most maxParticles at once
local function new(img, maxParticles)

	-- create quad mesh with the texture on top of it, to be used when rendering the particle in 3d
	local mesh = love.graphics.newMesh(
		{
			{"VertexPosition", "float", 3},
			{"VertexTexCoord", "float", 2},
			{"VertexColor", "byte", 4},
			{"VertexNormal", "float", 3}
		},
		{
			{0.5, 0.5, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1},
			{-0.5, 0.5, 0, 1, 0, 1, 1, 1, 1, 0, 0, 1},
			{0.5, -0.5, 0, 0, 1, 1, 1, 1, 1, 0, 0, 1},
			{0.5, -0.5, 0, 0, 1, 1, 1, 1, 1, 0, 0, 1},
			{-0.5, 0.5, 0, 1, 0, 1, 1, 1, 1, 0, 0, 1},
			{-0.5, -0.5, 0, 1, 1, 1, 1, 1, 1, 0, 0, 1}
		},
		"triangles",
		"static"
	)

	mesh:setTexture(img)

	local instancesData = {}
	for i = 1, maxParticles do
		instancesData[i] = {0, 0, 0, 0, 1, 1, 1, 1}
	end

	-- create instance mesh
	local instanceMesh = love.graphics.newMesh(
		{
			{"instancePosition", "float", 3},
			{"instanceRotation", "float", 1},
			{"instanceScale", "float", 1},
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


	local Obj = {
		["Gradient"] = gradient(0, color(1, 1, 1), 1, color(1, 1, 1)); -- the color the particle has at a given moment in time
		["Source"] = vector3(0, 0, 0); -- location from which particles are emitted
		["Direction"] = vector3(0, 1, 0); -- the direction the particles get emitted from
		["DirectionDeviation"] = math.pi / 8; -- when the particle is emitted, it deviates from the direction with at most this angle (at random)
		["Gravity"] = vector3(0, 0, 0); -- direction into which the particles accelerate
		["Speed"] = range(1, 1); -- minimum and maximum speed at which the particle is emitted
		["Rotation"] = range(0, math.pi * 2); -- minimum and maximum rotation at which the particle is emitted
		["RotationSpeed"] = range(-1, 1); -- the minimum and maximum speed with which the particle rotates around its center (in radians per second)
		["Size"] = numbercurve(0, 1, 1, 1); -- the size of the particle over time
		["SizeDeviation"] = numbercurve(0, 0, 1, 0); -- the size of a particle can deviate by at most this much
		["Lifetime"] = range(1.5, 2); -- for how long the particle lives at minimum & maximum

		["Spawned"] = {}; -- array of particles that are currently alive. Contains info to computer the particle's position & size. Each index has the form {spawnTime, lifetime, startRot, rotSpeed, direction, speed, sizeDeviation}

		["Mesh"] = mesh;
		["Instances"] = instanceMesh;

		["MaxParticles"] = maxParticles; -- maximum number of particles that can be emitted. Cannot be changed as it's tied to the mesh instancing logic
	}

	return setmetatable(Obj, Particles3)
end




----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

module.newParticles3 = newParticles3
module.isParticles3 = isParticles3
return setmetatable(module, {__call = function(_, ...) return new(...) end})


