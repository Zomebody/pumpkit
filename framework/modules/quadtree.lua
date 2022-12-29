
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



local Quadtree = {}
Quadtree.__index = Quadtree


local function new(bucketSize, maxSplits, position, size)
	local Obj = {
		["Position"] = position ~= nil and vector(position) or vector(0, 0);
		["Size"] = size ~= nil and vector(size) or vector(1000, 1000);
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
			["Position"] = vector(position);
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
function Quadtree:findClosestItem(position, closestDis)
	local closestItem = nil
	local closestDistance = closestDis
	-- first check current quadtree's items
	for i = 1, #self.Items do
		local dis = (self.Items[i].Position - position):getMag()
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
				local splitDistance = (closestChildItem.Position - position):getMag()
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
	for i = 1, #self.Items do
		local Item = self.Items[i]
		if (Item.Position - position):getMag() - Item.Radius <= radius then
			--itemsInRange[#itemsInRange + 1] = Item.Item
			dict[Item.Item] = true
		end
	end

	-- check sub-trees
	for i = 1, #self.Splits do
		local Split = self.Splits[i]
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
	for i = 1, #self.Items do
		local Item = self.Items[i]
		if (Item.Position - position):getMag() <= Item.Radius then
			dict[Item.Item] = true
		end
	end
	-- check sub-splits
	for i = 1, #self.Splits do
		local Split = self.Splits[i]
		-- check if the position falls within the bounds of the sub-split
		if position.x >= Split.Position.x and position.x <= Split.Position.x + Split.Size.x and position.y >= Split.Position.y and position.y <= Split.Position.y + Split.Size.y then
			Split:findAt(position, dict)
		end
	end
end


-- split the quadtree into 4 quadrants of equal size
function Quadtree:split()
	self.Splits[1] = new(self.BucketSize, self.MaxSplits - 1, self.Position, self.Size / 2)
	self.Splits[2] = new(self.BucketSize, self.MaxSplits - 1, self.Position + vector(self.Size.x / 2, 0), self.Size / 2)
	self.Splits[3] = new(self.BucketSize, self.MaxSplits - 1, self.Position + vector(0, self.Size.y / 2), self.Size / 2)
	self.Splits[4] = new(self.BucketSize, self.MaxSplits - 1, self.Position + vector(self.Size.x / 2, self.Size.y / 2), self.Size / 2)
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

