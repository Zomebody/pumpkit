

----------------------------------------------------[[ == BASE OBJECTS == ]]----------------------------------------------------

local module = {
	["TotalCreated"] = 0;
}


local Particles3 = {}
Particles3.__index = Particles3
Particles3.__tostring = function(tab) return "{Particles3 (" .. tostring(tab.MaxParticles) .. ")}" end



--[[


TODO:

- SpawnRadius (range, default: 0,0)
- if the Direction vector is larger than 1, particles will randomly spawn in a circle around its source, with the circle being aligned to the Direction vector


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



function getRandomPerpendicularVector(vec)
	if vec:getMag() == 0 then
		return vector3.random()
	end

	local arbitraryVector = (math.abs(vec.x) > 0.9 and vector3.new(0, 1, 0) or vector3.new(1, 0, 0))
	local perpendicular = vec:cross(arbitraryVector):norm()
	local perpendicular2 = vec:cross(perpendicular):norm()
	local angle = love.math.random() * 2 * math.pi

	local randomVector = perpendicular * math.cos(angle) + perpendicular2 * math.sin(angle)

	return randomVector
end



----------------------------------------------------[[ == FUNCTIONS == ]]----------------------------------------------------

-- check if an object is a particles3
local function isParticles3(t)
	return getmetatable(t) == Particles3
end




function Particles3:emit(count)
	local emittedAt = love.timer.getTime()

	local lifetime
	local velocity
	local rotation
	local rotationSpeed
	local scaleOffset
	local offsetVector
	local position

	local facingMode = 0
	if self.FacesCamera and self.FacesVelocity then
		facingMode = 0.75
	elseif self.FacesCamera then
		facingMode = 0.25
	elseif self.FacesVelocity then
		facingMode = 0.5
	end

	

	for i = 1, count do

		-- calculate new instance properties
		offsetVector = getRandomPerpendicularVector(self.Direction) * math.sqrt(love.math.random() * (self.SpawnRadius.max^2 - self.SpawnRadius.min^2) + self.SpawnRadius.min^2)
		if line3.isLine3(self.Source) then
			position = self.Source.from + love.math.random() * (self.Source.to - self.Source.from) + offsetVector
		else
			position = self.Source + offsetVector
		end
		lifetime = self.Lifetime:randomDecimal()
		velocity = getVectorInCone(self.Direction, self.DirectionDeviation) * self.Speed:randomDecimal()
		rotation = self.Rotation:randomDecimal()
		rotationSpeed = self.RotationSpeed:randomDecimal()
		scaleOffset = (love.math.random() - 0.5) * 2

		self.Instances:setVertex(self.SpawnIndex, position.x, position.y, position.z, emittedAt, lifetime, velocity.x, velocity.y, velocity.z, rotation, rotationSpeed, scaleOffset, facingMode)

		self.SpawnIndex = (self.SpawnIndex % self.MaxParticles) + 1
	end
end




function Particles3:draw(shaderRef)
	shaderRef:send("dataTexture", self.DataTexture)
	shaderRef:send("gravity", {self.Gravity.x, self.Gravity.y, self.Gravity.z})
	shaderRef:send("currentTime", love.timer.getTime())
	shaderRef:send("drag", self.Drag)
	shaderRef:send("brightness", self.Brightness)
	shaderRef:send("zOffset", self.ZOffset)
	shaderRef:send("flipbookData", {self.FlipbookSize, self.FlipbookFrames}) -- pack into vec2 to reduce send calls I guess
	love.graphics.drawInstanced(self.Mesh, self.MaxParticles) -- draw all the particles, but in practice most of them will be drawn at a scale of 0 because they're inactive
end



-- create a new particle emitter which uses the given image and can emit at most maxParticles at once
local function new(img, maxParticles, properties)

	-- create quad mesh with the texture on top of it, to be used when rendering the particle in 3d
	local mesh = love.graphics.newMesh(
		{
			{"VertexPosition", "float", 3},
			{"VertexTexCoord", "float", 2}
		},
		{
			{0.5, 0.5, 0, 0, 0},
			{-0.5, 0.5, 0, 1, 0},
			{0.5, -0.5, 0, 0, 1},
			{0.5, -0.5, 0, 0, 1},
			{-0.5, 0.5, 0, 1, 0},
			{-0.5, -0.5, 0, 1, 1}
		},
		"triangles",
		"static"
	)

	mesh:setTexture(img)

	-- dummy data, will be updated automatically when :emit() is called
	local instancesData = {}
	for i = 1, maxParticles do
		instancesData[i] = {0, 0, 0, -9999, 0, 0, 0, 0, 0, 0, 0}
	end

	-- create instance mesh
	local instanceMesh = love.graphics.newMesh(
		{
			{"instPosition", "float", 3},
			{"instEmittedAt", "float", 1},
			{"instLifetime", "float", 1},
			{"instVelocity", "float", 3},
			{"instRotation", "float", 1},
			{"instRotationSpeed", "float", 1},
			{"instScaleOffset", "float", 1},
			{"instFacingMode", "float", 1}
		},
		instancesData,
		"triangles",
		"stream"
	)

	mesh:attachAttribute("instPosition", instanceMesh, "perinstance") -- first vertex attribute
	mesh:attachAttribute("instEmittedAt", instanceMesh, "perinstance") -- second vertex attribute
	mesh:attachAttribute("instLifetime", instanceMesh, "perinstance") -- third vertex attribute
	mesh:attachAttribute("instVelocity", instanceMesh, "perinstance") -- fourth vertex attribute
	mesh:attachAttribute("instRotation", instanceMesh, "perinstance") -- fifth vertex attribute
	mesh:attachAttribute("instRotationSpeed", instanceMesh, "perinstance") -- sixth vertex attribute
	mesh:attachAttribute("instScaleOffset", instanceMesh, "perinstance") -- seventh vertex attribute
	mesh:attachAttribute("instFacingMode", instanceMesh, "perinstance") -- eight vertex attribute

	local gradient = properties.Gradient or gradient(0, color(1, 1, 1), 1, color(1, 1, 1))
	local source = properties.Source or vector3(0, 0, 0)
	local direction = properties.Direction or vector3(0, 1, 0)
	local directionDeviation = properties.DirectionDeviation or math.pi / 8
	local spawnRadius = properties.SpawnRadius or range(0, 0)
	local gravity = properties.Gravity or vector3(0, 0, 0)
	local speed = properties.Speed or range(1, 1)
	local rotation = properties.Rotation or range(0, math.pi * 2)
	local rotationSpeed = properties.RotationSpeed or range(-1, 1)
	local size = properties.Size or numbercurve(0, 1, 1, 1)
	local sizeDeviation = properties.SizeDeviation or numbercurve(0, 0, 1, 0)
	local lifetime = properties.Lifetime or range(1.5, 2)
	local facesCamera = properties.FacesCamera or false
	local facesVelocity = properties.FacesVelocity or false
	local drag = properties.Drag or 0
	local brightness = properties.Brightness or 1
	local zOffset = properties.ZOffset or 0
	local blends = properties.Blends or false
	local fbSize = properties.FlipbookSize or 1
	local fbFrames = properties.FlipbookFrames or 1
	
	local c, s1, s2, high1, low1, high2, low2
	local data = love.image.newImageData(64, 2)
	data:mapPixel(
		function(x, y, r, g, b, a)
			if y == 0 then
				c = gradient:getColor(x / 64)
				return c:components()
			else
				s1 = size:getNumber(x / 64) / 10
				s2 = sizeDeviation:getNumber(x / 64) / 10
				high1 = math.floor(s1 * 256) / 256
				low1 = s1 * 256 % 1
				high2 = math.floor(s2 * 256) / 256
				low2 = s2 * 256 % 1
				return high1, low1, high2, low2
			end
		end
	)
	local dataTexture = love.graphics.newImage(data)

	module.TotalCreated = module.TotalCreated + 1

	local Obj = {
		["Id"] = module.TotalCreated;
		["Gradient"] = gradient; -- the color the particle has at a given moment in time
		["Source"] = source; -- location from which particles are emitted
		["Blends"] = blends; -- if false, particle is directly drawn to screen w/ depth registered (prone to sorting issues). If true, blends with other particles order-independently
		["ZOffset"] = zOffset;
		["Direction"] = direction; -- the direction the particles get emitted from
		["DirectionDeviation"] = directionDeviation; -- when the particle is emitted, it deviates from the direction with at most this angle (at random)
		["SpawnRadius"] = spawnRadius;
		["Gravity"] = gravity; -- direction into which the particles accelerate
		["Speed"] = speed; -- minimum and maximum speed at which the particle is emitted
		["Rotation"] = rotation; -- minimum and maximum rotation at which the particle is emitted
		["RotationSpeed"] = rotationSpeed; -- the minimum and maximum speed with which the particle rotates around its center (in radians per second)
		["Size"] = size; -- the size of the particle over time
		["SizeDeviation"] = sizeDeviation; -- the size of a particle can deviate by at most this much
		["Lifetime"] = lifetime; -- for how long the particle lives at minimum & maximum
		["FacesCamera"] = facesCamera; -- if true, billboard behavior is enabled
		["FacesVelocity"] = facesVelocity; -- if true and facesCamera is false, particle aligns with velocity. If true and facesCamera is true, billboard behavior with rotation based on screen space velocity
		["Drag"] = drag;
		["Brightness"] = brightness;
		["FlipbookSize"] = fbSize; -- size of the flipbook image. A size of 3 means 9 cells, 4 = 16 cells, 5 = 25 cells etc.
		["FlipbookFrames"] = fbFrames; -- the number of frames to play during the particle's lifetime

		["DataTexture"] = dataTexture; -- contains curves encoded into an image for faster look-ups on the GPU

		--["Spawned"] = {}; -- array of particles that are currently alive. Contains info to computer the particle's position & size. Each index has the form {spawnTime, lifetime, startRot, rotSpeed, direction, speed, sizeDeviation}
		["SpawnIndex"] = 1; -- counter that keeps track of how many particles have spawned so it knows which particles are next up in the pool to emit

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


