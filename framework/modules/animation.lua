

local getpath = require("framework.getpath")
local vector = require(getpath(..., "../datatypes/vector"))

local module = {
	["Active"] = {}
}

local animation = {}
animation.__index = animation


function module.isAnimation(Obj)
	return getmetatable(Obj) == animation
end


function module:update()
	local dt = love.timer.getDelta()
	local i = 1
	while i <= #module.Active do
		local stopped = module.Active[i]:update(dt)
		if not stopped then
			i = i + 1
		end
	end
end

-- module can only be initialized once
function module:initialize()
	if not module.Initialized then
		module.Initialized = true
	else
		return
	end

	-- Monkey Patching love.update such that animations are updated at the end
	local update = love.update or function() end
	love.update = function()
		update()
		self:update()
	end
end




-- start playing the animation by setting its state and putting it in the active animations list
-- animation must be idle in order to start
function animation:play()
	if self.State ~= "idle" then
		return false
	end
	self.CurrentFrame = 1
	self.Quad:setViewport(self.FrameCoordinates[self.CurrentFrame].x, self.FrameCoordinates[self.CurrentFrame].y, self.FrameWidth, self.FrameHeight)
	self.State = "playing"
	module.Active[#module.Active + 1] = self

	-- check if the first frame is marked, and if so, call OnFrameReached
	if self.OnFrameReached ~= nil and self.MarkedFrames[1] ~= nil then
		self.OnFrameReached(self.MarkedFrames[1])
	end
	return true
end


-- set the state to paused if the animation is playing
function animation:pause()
	if not self.State == "playing" then
		return false
	end
	self.State = "paused"
	return true
end


-- play the animation without resetting the properties
function animation:resume()
	if self.State == "idle" then
		self:play()
		return true
	elseif self.State == "paused" then
		self.State = "playing"
		return true
	end
	return false
end


-- stop the animation by setting its state and removing it from the active list. Only works for animations that are playing
function animation:stop()
	if self.State == "idle" then
		return false
	end
	self.State = "idle"
	self.TimePlayed = 0
	self.CurrentFrame = 1
	--self.Quad:setViewport(self.FrameCoordinates[self.CurrentFrame].x, self.FrameCoordinates[self.CurrentFrame].y, self.FrameWidth, self.FrameHeight)
	for i = 1, #module.Active do
		if module.Active[i] == self then
			table.remove(module.Active, i)
			return true
		end
	end
	return false
end


-- update the animation by proceeding to the next frame
-- TODO: if a marked frame is skipped over, the OnFrameReached callback will not trigger for the skipped frame. fix this!
function animation:update(dt)
	if self.State == "playing" then
		local prevFrame = self.CurrentFrame
		self.TimePlayed = self.TimePlayed + dt

		-- check if the end of the animation has been reached
		local stopAnimation = false
		if self.TimePlayed > (self.FrameCount * self.FrameDuration) then
			if self.Looped then
				self.TimePlayed = self.TimePlayed % (self.FrameCount * self.FrameDuration)
			else
				self.TimePlayed = self.FrameCount * self.FrameDuration
				stopAnimation = true
			end
			-- trigger end reached callback
			if self.OnEndReached ~= nil then
				self.OnEndReached()
			end
		end

		local curFrame = math.ceil(self.TimePlayed / self.FrameDuration)
		self.CurrentFrame = curFrame
		self.Quad:setViewport(self.FrameCoordinates[self.CurrentFrame].x, self.FrameCoordinates[self.CurrentFrame].y, self.FrameWidth, self.FrameHeight)
		if curFrame ~= prevFrame and self.MarkedFrames[curFrame] ~= nil and self.OnFrameReached ~= nil then
			self.OnFrameReached(self.MarkedFrames[curFrame])
		end

		if stopAnimation then
			self:stop()
		end
	end
end



-- markes the given frame number. Marked frames are passed to the OnFrameReached callback
function animation:markFrame(frameNumber, name)
	self.MarkedFrames[frameNumber] = name
end


function animation:getSprite()
	return self.ReferenceImage, self.Quad
end


function animation:getSize()
	return self.FrameWidth, self.FrameHeight
end

function animation:__tostring()
	return "{" .. self.State .. ", " .. tostring(self.CurrentFrame) .. "/" .. tostring(self.FrameCount) .. ", " .. tostring(self.FrameWidth) .. "x" .. tostring(self.FrameHeight) .. ", " .. tostring(self.Looped) .. "}"
end





local function new(refImg, width, height, coordinates, playSpeed, looped)
	local Obj = {
		-- properties
		["State"] = "idle"; -- idle, paused, playing
		["TimePlayed"] = 0;
		["ReferenceImage"] = refImg;
		["Quad"] = nil;
		["CurrentFrame"] = 1;
		["FrameCoordinates"] = {}; -- {vector(x1, y1), vector(x2, y2), etc.}
		["FrameCount"] = 0;
		["FrameWidth"] = width or refImg:getWidth();
		["FrameHeight"] = height or refImg:getHeight();
		["FrameDuration"] = playSpeed == nil and 8 or (1 / playSpeed);
		["Looped"] = looped or false;
		["MarkedFrames"] = {};
		-- callbacks
		["OnFrameReached"] = nil;
		["OnEndReached"] = nil;
	}

	-- transform coordinates into readable format for the animation
	if coordinates == nil then
		local framesX = math.floor(refImg:getWidth() / Obj.FrameWidth)
		local framesY = math.floor(refImg:getHeight() / Obj.FrameHeight)
		for x = 0, framesX - 1 do
			for y = 0, framesY - 1 do
				Obj.FrameCoordinates[#Obj.FrameCoordinates + 1] = vector(x * Obj.FrameWidth, y * Obj.FrameHeight)
			end
		end
	elseif vector.isVector(coordinates[1]) then -- table of vectors
		for i = 1, #coordinates do
			Obj.FrameCoordinates[i] = vector((coordinates[i].x - 1) * Obj.FrameWidth, (coordinates[i].y - 1) * Obj.FrameHeight)
		end
	elseif type(coordinates[1]) == "table" then -- table of tables
		for i = 1, #coordinates do
			Obj.FrameCoordinates[i] = vector((coordinates[i][1] - 1) * Obj.FrameWidth, (coordinates[i][2] - 1) * Obj.FrameHeight)
		end
	else -- number sequence table
		local n = 1
		for i = 1, #coordinates, 2 do
			Obj.FrameCoordinates[n] = vector((coordinates[i] - 1) * Obj.FrameWidth, (coordinates[i + 1] - 1) * Obj.FrameHeight)
			n = n + 1
		end
	end

	Obj.FrameCount = #Obj.FrameCoordinates

	-- create a Quad to be used for drawing the animation
	Obj.Quad = love.graphics.newQuad(Obj.FrameCoordinates[1].x, Obj.FrameCoordinates[1].y, Obj.FrameWidth, Obj.FrameHeight, Obj.ReferenceImage:getDimensions())

	return setmetatable(Obj, animation)
end



module.new = new
return setmetatable(module, {__call = function(_, ...) return new(...) end})


