
----------------------------------------------------[[ == BASE OBJECTS == ]]----------------------------------------------------

local module = {}

local Floodmap = {}
Floodmap.__index = Floodmap
Floodmap.__tostring = function(tab) return ("{Floodmap: w=%d, h=%d}"):format(self.Size.x, self.Size.y) end


-- TODO: add a 'BlockMap' which encodes per tile if you can pass it or not. It's needed in case you want tiles with >1 movement cost, which are temporarily blocked.


----------------------------------------------------[[ == METHODS == ]]----------------------------------------------------

-- check if an object is a floodmap
local function isFloodmap(t)
	return getmetatable(t) == Fighter
end




function Floodmap:inBounds(vec2)
	return vec2.x > 0 and vec2.x <= self.Size.x and vec2.y > 0 and vec2.y <= self.Size.y
end


function Floodmap:clearWeights()
	self.Start = vector2(0, 0)
	for x = 1, self.Size.x do
		for y = 1, self.Size.y do
			self.WeightMap[x][y] = math.huge
		end
	end

	self.Filled = false
end


function Floodmap:clearCosts()
	self.Start = vector2(0, 0)
	for x = 1, self.Size.x do
		for y = 1, self.Size.y do
			self.CostMap[x][y] = 1
		end
	end
end



-- returns an array of vector2s that describes the path to the given tile from where the map was being filled in, alongside an array with corresponding weights
function Floodmap:getPath(toVec2)
	assert(self:inBounds(toVec2), "Floodmap:getPath(toVec2) failed because the given coordinate falls outside the map.")
	assert(self.Filled, "Floodmap:getPath(toVec2) can only be called when the floodmap has first been filled with Floodmap:fill().")
	local curVec = vector2(toVec2)
	local path = {}
	local weights = {}

	local offsets = {
		vector2(-1, 0),
		vector2(1, 0),
		vector2(0, -1),
		vector2(0, 1)
	}

	while curVec ~= self.Start do
		table.insert(path, 1, vector2(curVec))
		table.insert(weights, 1, self.WeightMap[curVec.x][curVec.y])
		local lowestAdjacent = nil
		local lowestCost = math.huge

		for i = 1, #offsets do
			local checkTile = curVec + offsets[i]
			if self:inBounds(checkTile) and self.WeightMap[checkTile.x][checkTile.y] < lowestCost then
				lowestAdjacent = checkTile
				lowestCost = self.WeightMap[checkTile.x][checkTile.y]
			end
		end

		if lowestAdjacent then
			curVec = lowestAdjacent
		else
			path = nil
			break -- no path to target
		end
	end
	table.insert(path, 1, vector2(self.Start))
	table.insert(weights, 1, 0)

	return path, weights

end


-- applies flood fill at the given coordinate, or array of coordinates
function Floodmap:fill(vec2, maxWeight)
	assert(self:inBounds(vec2), "Floodmap:fill(vec2) failed because the given coordinate falls outside the map.")

	if maxWeight == nil then maxWeight = math.huge end
	
	
	if self.Filled then
		self:clearWeights()
	end

	local offsets = {
		vector2(-1, 0),
		vector2(1, 0),
		vector2(0, -1),
		vector2(0, 1)
	}

	local pending = {vector2(vec2)} -- tiles that are currently being flooded and are pending further flooding
	self.WeightMap[vec2.x][vec2.y] = 0

	repeat
		local poppedTile = table.remove(pending, 1)
		local curCost = self.WeightMap[poppedTile.x][poppedTile.y]
		local checkTile = vector2()
		for i = 1, #offsets do
			checkTile:set(poppedTile.x + offsets[i].x, poppedTile.y + offsets[i].y)
			if self:inBounds(checkTile) and (not self:isWall(checkTile)) then
				local newWeight = curCost + self.CostMap[checkTile.x][checkTile.y]
				if newWeight < self.WeightMap[checkTile.x][checkTile.y] and newWeight <= maxWeight then
					self.WeightMap[checkTile.x][checkTile.y] = newWeight
					table.insert(pending, vector2(checkTile))
				end
			end
		end
	until #pending == 0

	self.Start = vector2(vec2)
	self.Filled = true
end



function Floodmap:setCost(vec2, cost)
	assert(self:inBounds(vec2), "Floodmap:setCost(vec2, cost) failed because the given coordinate falls outside the map.")
	assert(vector2.isVector2(vec2) or type(vec2) == "table", "Floodmap:setCost(vec2, cost) requires argument 'vec2' to be a vector2 or array of vector2s.")
	assert(type(cost) == "number" or type(cost) == nil, "Floodmap:setCost(vec2, cost) requires argument 'cost' to be a number or nil.")
	if cost == nil then cost = 1 end

	if vector2.isVector2(vec2) then
		self.CostMap[vec2.x][vec2.y] = cost
	else
		for i = 1, #vec2 do
			self.CostMap[vec2[i].x][vec2[i].y] = cost
		end
	end
end



function Floodmap:getReach(vec2, distance)
	assert(self:inBounds(vec2), "Floodmap:getReach(vec2, distance) failed because the given coordinate falls outside the map.")

	if self.Filled then
		self:clearWeights()
	end

	local offsets = {
		vector2(-1, 0),
		vector2(1, 0),
		vector2(0, -1),
		vector2(0, 1)
	}

	local pending = {vector2(vec2)} -- tiles that are currently being flooded and are pending further flooding
	self.WeightMap[vec2.x][vec2.y] = 0

	local reached = {}
	if not self:isWall(pending[1]) then
		table.insert(reached, vector2(vec2))
	end

	repeat
		local poppedTile = table.remove(pending, 1)
		local curCost = self.WeightMap[poppedTile.x][poppedTile.y]
		local checkTile = vector2()
		for i = 1, #offsets do
			checkTile:set(poppedTile.x + offsets[i].x, poppedTile.y + offsets[i].y)
			if self:inBounds(checkTile) and (not self:isWall(checkTile)) and self.WeightMap[checkTile.x][checkTile.y] > curCost + self.CostMap[checkTile.x][checkTile.y] then
				-- due to using costs, a tile may need to be checked more than once. However, we don't want duplicates in the 'reached' array
				-- therefore, we can check if the weight of the tile is math.huge to see if it has been reached at least once before, and only insert it once into 'reached'
				local newWeight = curCost + self.CostMap[checkTile.x][checkTile.y] -- cost that might be assigned to the adjacent tile
				if self.WeightMap[checkTile.x][checkTile.y] == math.huge and newWeight <= distance then
					table.insert(reached, vector2(checkTile))
				end
				self.WeightMap[checkTile.x][checkTile.y] = newWeight
				if newWeight < distance then
					table.insert(pending, vector2(checkTile))
				end
			end
		end
	until #pending == 0

	self:clearWeights()
	return reached
end



function Floodmap:getCost(vec2)
	assert(self:inBounds(vec2), "Floodmap:getCost(vec2) failed because the given coordinate falls outside the map.")
	assert(vector2.isVector2(vec2) or type(vec2) == "table", "Floodmap:getCost(vec2) requires argument 'vec2' to be a vector2.")
	return self.CostMap[vec2.x][vec2.y]
end



function Floodmap:setWall(vec2, state)
	assert(vector2.isVector2(vec2) or type(vec2) == "table", "Floodmap:setWall(vec2, state) requires argument 'vec2' to be a vector2 or array of vector2s.")
	assert(type(state) == "boolean", "Floodmap:setWall(vec2, state) requires argument 'state' to be a boolean.")
	if type(vec2) == "table" then
		for i = 1, #vec2 do
			assert(self:inBounds(vec2[i]), "Floodmap:setWall(vec2, state) failed because one of the given coordinates falls outside the map.")
		end
	else
		assert(self:inBounds(vec2), "Floodmap:setWall(vec2, state) failed because the given coordinate falls outside the map.")
	end

	if vector2.isVector2(vec2) then
		self.Map[vec2.x][vec2.y] = (state and 1 or 0)
	else
		for i = 1, #vec2 do
			self.Map[vec2[i].x][vec2[i].y] = (state and 1 or 0)
		end
	end
end



function Floodmap:isWall(vec2)
	assert(self:inBounds(vec2), "Floodmap:isWall(vec2) failed because the given coordinate falls outside the map.")
	assert(vector2.isVector2(vec2) or type(vec2) == "table", "Floodmap:isWall(vec2) requires argument 'vec2' to be a vector2.")
	return self.Map[vec2.x][vec2.y] == 1
end



-- return the cells containing the largest (non-infinite) weights if filled
function Floodmap:getHighestWeights()
	assert(self.Filled, "Floodmap:getHighestWeights() can only be called when the floodmap is filled.")
	local largest = -math.huge
	local cells = {}
	for x = 1, #self.WeightMap do
		for y = 1, #self.WeightMap[x] do
			if self.WeightMap[x][y] < math.huge then -- ignore infinite
				if self.WeightMap[x][y] == largest then
					table.insert(cells, vector2(x, y))
				elseif self.WeightMap[x][y] > largest then
					largest = self.WeightMap[x][y]
					cells = {vector2(x, y)}
				end
			end
		end
	end
	return cells, largest
end



function Floodmap:print()
	print(("-"):rep(self.Size.x * 4 + 3))
	for y = 1, self.Size.y do
		local line = "| "
		for x = 1, self.Size.x do
			if self.WeightMap[x][y] == math.huge then
				line = line .. "inf "
			else
				line = line .. ("%03d"):format(self.WeightMap[x][y]) .. " "
			end
			
		end
		line = line .. "|"
		print(line)
	end
	print(("-"):rep(self.Size.x * 4 + 3))
end



----------------------------------------------------[[ == OBJECT CREATION == ]]----------------------------------------------------

local function newObject(w, h)
	local Obj = {
		["Size"] = vector2(w, h);
		["Filled"] = false;
		["Start"] = vector2(0, 0); -- if Filled == true, this will indicate from which tile the flood fill started
		["Map"] = {}; -- 2d array containing per tile if you can walk over it or not. 0 = walkable, 1 = wall/blocked
		["CostMap"] = {}; -- 2d array containing per tile how much it costs to traverse them. Tiles are usually set to 1
		["WeightMap"] = {}; -- 2d array containing per tile how far away it is from the point from which it was being filled, math.huge for tiles that are sectioned off
	}

	return setmetatable(Obj, Floodmap)
end



local function new(w, h)
	if vector2.isVector2(w) then
		h = w.y
		w = w.x
	end
	local Obj = newObject(w, h)
	
	for x = 1, w do
		Obj.Map[x] = {}
		Obj.CostMap[x] = {}
		Obj.WeightMap[x] = {}
		for y = 1, h do
			Obj.Map[x][y] = 0
			Obj.CostMap[x][y] = 1
			Obj.WeightMap[x][y] = math.huge
		end
	end
	
	return Obj
end



local function fromImageData(imgData)
	--local imgData = love.image.newImageData(pathToImg)
	if type(imgData) == "string" then
		imgData = love.image.newImageData(imgData)
	end
	local w, h = imgData:getDimensions()

	local Obj = newObject(w, h)

	
	for x = 1, w do
		Obj.Map[x] = {}
		Obj.CostMap[x] = {}
		Obj.WeightMap[x] = {}
		for y = 1, h do
			Obj.WeightMap[x][y] = math.huge
			Obj.CostMap[x][y] = 1
			-- don't need to set CostMap[x][y] here since :setCost() will do that anyway
			local r, g, b, a = imgData:getPixel(x - 1, y - 1)
			if r == 0 and g == 0 and b == 0 then -- black, thus a wall
				Obj.Map[x][y] = 1
			else -- white, thus walkable
				Obj.Map[x][y] = 0
			end
		end
	end

	return Obj
end



----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

-- pack up and return module
module.new = new
module.fromImageData = fromImageData
module.isFloodmap = isFloodmap
return setmetatable(module, {__call = function(_, ...) return new(...) end})





