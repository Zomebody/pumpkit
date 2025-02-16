
local jit = require("jit")
local module = {}


local function circleIntersectsRectangle(cPosition, cRadius, rTopLeft, rBottomRight)
	local closestX = math.max(math.min(cPosition.x, rBottomRight.x), rTopLeft.x)
	local closestY = math.max(math.min(cPosition.y, rBottomRight.y), rTopLeft.y)
	local disX = cPosition.x - closestX
	local disY = cPosition.y - closestY
	local disSquared = disX^2 + disY^2
	return disSquared <= cRadius^2
end




local function lineIntersectsRectangle(line, rTopLeft, rBottomRight)
	-- sort line's points
	local x1, y1 = line.from.x, line.from.y
	local x2, y2 = line.to.x, line.to.y
	if x1 > x2 then x1, x2 = x2, x1 end
	if y1 > y2 then y1, y2 = y2, y1 end

	local minX, minY = rTopLeft.x, rTopLeft.y
	local maxX, maxY = rBottomRight.x, rBottomRight.y

	-- early return if either points are inside the rectangle
	if x1 >= minX and x1 <= maxX and y1 >= minY and y1 <= maxY then
		return true
	end
	if x2 >= minX and x2 <= maxX and y2 >= minY and y2 <= maxY then
		return true
	end

	-- early return if line's bounding box does not overlap the rectangle
	if x2 < minX or x1 > maxX or y2 < minY or y1 > maxY then
		return false
	end
	
	-- check intersection with each edge
	local rTopRight = vector2(maxX, minY)
	local rBottomLeft = vector2(minX, maxY)
	return line:intersects(line2(rTopLeft, rTopRight))
		or line:intersects(line2(rBottomLeft, rBottomRight))
		or line:intersects(line2(rTopLeft, rBottomLeft))
		or line:intersects(line2(rTopRight, rBottomRight))
end



local Quadtree = {}
Quadtree.__index = Quadtree


local function new(position, size, bucketSize, maxSplits)
	assert(vector2.isVector2(position), "quadtree.new(position, size, bucketSize, maxSplits) requires argument 'position' to be a vector2.")
	assert(vector2.isVector2(size), "quadtree.new(position, size, bucketSize, maxSplits) requires argument 'size' to be a vector2.")
	assert(type(bucketSize) == "number", "quadtree.new(position, size, bucketSize, maxSplits) requires argument 'bucketSize' to be a number.")
	assert(type(maxSplits) == "number", "quadtree.new(position, size, bucketSize, maxSplits) requires argument 'maxSplits' to be a number.")
	local Obj = {
		["Position"] = position ~= nil and vector2(position) or vector2(0, 0);
		["Size"] = size ~= nil and vector2(size) or vector2(1000, 1000);
		["BucketSize"] = bucketSize;
		["MaxSplits"] = maxSplits;
		["Items"] = {};
		["Splits"] = {};
	}

	return setmetatable(Obj, Quadtree)
end



function Quadtree:insert(Object, position, radius)
	local success = false
	-- bounds check
	if not circleIntersectsRectangle(position, radius, self.Position, self.Position + self.Size) then
		return false
	end
	-- check if the current quadtree has space left for children
	if #self.Items < self.BucketSize or self.MaxSplits == 0 then
		self.Items[#self.Items + 1] = {
			["Item"] = Object;
			["Position"] = vector2(position);
			["Radius"] = radius;
		}
		return true
	else
		-- if there is no space left to insert an item into the current quadtree, try inserting it into the quadtree's splits
		if #self.Splits == 0 and self.MaxSplits > 0 then
			self:split()
		end
		for i = 1, #self.Splits do
			local s = self.Splits[i]:insert(Object, position, radius)
			if s == true then
				success = true
			end
		end
	end
	return success
end


function Quadtree:findClosest(position)
	local closest = self:findClosestItem(position, math.huge)
	if closest == nil then
		return
	end
	return closest.Item
end



-- this is prone to crashing due to a bug in LuaJIT!
-- actually, I think it was due to a bug in my logic and now it should work just fine
function Quadtree:findClosestItem(position, closestDis)
	local closestItem = nil
	local closestDistance = closestDis
	-- first check current quadtree's items
	for i = 1, #self.Items do
		local dis = position:dist(self.Items[i].Position) --(self.Items[i].Position - position):getMag()
		if dis < closestDistance then
			closestItem = self.Items[i]
			closestDistance = dis
		end
	end
	-- recursively check quadtree splits
	for i = 1, #self.Splits do
		-- check if the quadtree intersects with a circle around the given position, with a radius equal to the distance to the closest point found so far
		-- if there is no intersection, then the quadtree should not be considered because the closest point within that quadtree is already further away than the closest distance so far
		if circleIntersectsRectangle(position, closestDistance, self.Splits[i].Position, self.Splits[i].Position + self.Splits[i].Size) then
			local closestChildItem = self.Splits[i]:findClosestItem(position, closestDistance)
			if closestChildItem ~= nil then
				local splitDistance = position:dist(closestChildItem.Position) --(closestChildItem.Position - position):getMag()
				if splitDistance < closestDistance then
					closestItem = closestChildItem
					closestDistance = splitDistance
				end
			end
		end
	end

	return closestItem
end

jit.off(Quadtree.findClosestItem) -- due to a bug in LuaJIT, the findClosestItem can cause a crash. Therefore, turn off LuaJIT for that function specifically!


-- calls getInRange() and then converts the dictionary to an array
function Quadtree:getInRange(position, radius)
	local dict = {}
	self:findInRange(position, radius, dict)
	local arr = {}
	for k, v in pairs(dict) do
		arr[#arr + 1] = k
	end
	return arr
end

-- this function may be slow when called every frame for a large radius!
-- to help alleviate the problem, increase the bucket size!

-- find all items in a given range. Skip over sub-trees that are too far from the given position w/ radius. 'dict' is a dictionary with the items so far
-- the reason for a dictionary is because an item may be inserted into multiple sub-trees, so using a dictionary prevents duplicates!
function Quadtree:findInRange(position, radius, dict)
	-- add items in the current quadtree if they are in range
	local Item = nil
	for i = 1, #self.Items do
		Item = self.Items[i]
		if position:dist(Item.Position) - Item.Radius <= radius then
			--itemsInRange[#itemsInRange + 1] = Item.Item
			dict[Item.Item] = true
		end
	end

	-- check sub-trees
	local Split = nil
	for i = 1, #self.Splits do
		Split = self.Splits[i]
		-- check if any position in the given quadtree is within range, otherwise skip the whole quadtree!
		if circleIntersectsRectangle(position, radius, Split.Position, Split.Position + Split.Size) then
			Split:findInRange(position, radius, dict)
		end
	end

	return itemsInRange
end



function Quadtree:at(position)
	local dict = {}
	self:findAt(position, dict)
	local arr = {}
	for k, v in pairs(dict) do
		arr[#arr + 1] = k
	end
	return arr
end



function Quadtree:findAt(position, dict)
	-- check children
	local Item = nil
	for i = 1, #self.Items do
		Item = self.Items[i]
		if position:dist(Item.Position) <= Item.Radius then
			dict[Item.Item] = true
		end
	end
	-- check sub-splits
	local Split = nil
	for i = 1, #self.Splits do
		Split = self.Splits[i]
		-- check if the position falls within the bounds of the sub-split
		if position.x >= Split.Position.x and position.x <= Split.Position.x + Split.Size.x and position.y >= Split.Position.y and position.y <= Split.Position.y + Split.Size.y then
			Split:findAt(position, dict)
		end
	end
end



function Quadtree:atLine(line)
	local dict = {}
	self:findAtLine(line, dict)
	local arr = {}
	for k, v in pairs(dict) do
		arr[#arr + 1] = k
	end
	return arr
end



function Quadtree:findAtLine(line, dict)
	-- check children
	local Item = nil
	for i = 1, #self.Items do
		Item = self.Items[i]
		if line:dist(Item.Position) <= Item.Radius then
			dict[Item.Item] = true
		end
	end
	-- check sub-splits
	for i = 1, #self.Splits do
		Split = self.Splits[i]
		-- check if line intersects sub-split. If so, check the split
		if lineIntersectsRectangle(line, Split.Position, Split.Position + Split.Size) then
			Split:findAtLine(line, dict)
		end
	end
end



-- THIS FUNCTION IS INCREDIBLY SLOW FOR LARGE QUADTREES! (if no position and radius is supplied)
function Quadtree:remove(Obj, position, radius)
	radius = radius == nil and 0 or radius
	-- check if the object is in the current tree and if so, remove it
	local deleted = false
	for i = 1, #self.Items do
		if self.Items[i].Item == Obj then
			table.remove(self.Items, i)
			deleted = true
			break
		end
	end
	-- if not removed, check all sub-trees
	if not deleted then
		for i = 1, #self.Splits do
			local Split = self.Splits[i]
			local del = false
			if position ~= nil then
				if circleIntersectsRectangle(position, radius, Split.Position, Split.Position + Split.Size) then
					del = Split:remove(Obj, position, radius)
				end
			else
				del = Split:remove(Obj)
			end
			if del then
				deleted = true
			end
		end
	end
	return deleted
end


function Quadtree:getItems()
	local dict = {}
	self:getSubItems(dict)
	local arr = {}
	for k, v in pairs(dict) do
		arr[#arr + 1] = k
	end
	return arr
end

function Quadtree:getSubItems(dict)
	for i = 1, #self.Items do
		dict[self.Items[i].Item] = true
	end
	for i = 1, #self.Splits do
		self.Splits[i]:getSubItems(dict)
	end
end


-- split the quadtree into 4 quadrants of equal size
function Quadtree:split()
	self.Splits[1] = new(self.Position, self.Size / 2, self.BucketSize, self.MaxSplits - 1)
	self.Splits[2] = new(self.Position + vector2(self.Size.x / 2, 0), self.Size / 2, self.BucketSize, self.MaxSplits - 1)
	self.Splits[3] = new(self.Position + vector2(0, self.Size.y / 2), self.Size / 2, self.BucketSize, self.MaxSplits - 1)
	self.Splits[4] = new(self.Position + vector2(self.Size.x / 2, self.Size.y / 2), self.Size / 2, self.BucketSize, self.MaxSplits - 1)
	-- moving items from the current quadtree to child quadtrees worsens performance! So just keep them in the parent quadtree :>
end



function Quadtree:draw()
	-- draw bounding box
	love.graphics.rectangle("line", self.Position.x, self.Position.y, self.Size.x, self.Size.y)
	-- draw items
	for i = 1, #self.Items do
		love.graphics.circle("line", self.Items[i].Position.x, self.Items[i].Position.y, self.Items[i].Radius)
	end
	-- draw subdivisions
	for i = 1, #self.Splits do
		self.Splits[i]:draw()
	end
end


module.new = new
return setmetatable(module, {__call = function(_, ...) return new(...) end})

