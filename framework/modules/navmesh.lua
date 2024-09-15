
--local getpath = require("framework.getpath")
--local vector = require(getpath(..., "vector"))
--local line = require(getpath(..., "line"))

local module = {}

local navmesh = {}
navmesh.__index = navmesh


-- check if an object is a navmesh
local function isNavmesh(t)
	return getmetatable(t) == navmesh
end


local function new(trisAndLines)
	assert(type(trisAndLines) == "table", "navmesh(trisAndLines) requires argument 'trisAndLines' to be a table of lines and/or triangles.")

	local mesh = {
		["Margin"] = 0.01; -- margin for boundary checks and going off-path and such
		["Quadtree"] = nil; -- quadtree in which the triangles are stored
		["Vectors"] = {}; -- list of vectors (nodes) that the graph is made out of. Key = integer, value = vector
		["Connections"] = {}; -- key/value dictionary (technically an array though) where key = node number, value = dictionary where keys = nodes to connect to and their values are weights
	}

	-- set the metatable already so the rest of the code below here can start using its methods!
	setmetatable(mesh, navmesh)


	local function tryListLine(l)
		-- check if 'from' is already in the vectors array. If not, add it
		local indexFrom = mesh:getVectorIndex(l.from)
		if indexFrom == nil then
			mesh.Vectors[#mesh.Vectors + 1] = vector2(l.from)
			indexFrom = #mesh.Vectors
			mesh.Connections[indexFrom] = {}
		end

		-- check if 'to' is already in the vectors array. If not, add it
		local indexTo = mesh:getVectorIndex(l.to)
		if indexTo == nil then
			mesh.Vectors[#mesh.Vectors + 1] = vector2(l.to)
			indexTo = #mesh.Vectors
			mesh.Connections[indexTo] = {}
		end

		-- Once 'from' and 'to' are added and/or found, check if the connection already exist. If not, add it to the connections dictionary
		if mesh.Connections[indexFrom][indexTo] == nil then
			mesh.Connections[indexFrom][indexTo] = l:getLength()
		end
		if mesh.Connections[indexTo][indexFrom] == nil then
			mesh.Connections[indexTo][indexFrom] = l:getLength()
		end
	end


	local function tryListTriangle(t)
		tryListLine(t.Line1)
		tryListLine(t.Line2)
		tryListLine(t.Line3)
	end

	-- insert the lines and triangles into the Vectors and Connections tables
	local Obj
	for i = 1, #trisAndLines do
		Obj = trisAndLines[i]
		if triangle.isTriangle(Obj) then
			tryListTriangle(Obj)
		elseif line.isLine(Obj) then
			tryListLine(Obj)
		end
	end

	-- after that, find the minX, minY, maxX and maxY for the quadtree to insert all the objects into
	local minX = math.huge
	local maxX = -math.huge
	local minY = math.huge
	local maxY = -math.huge
	for i = 1, #mesh.Vectors do
		minX = math.min(minX, mesh.Vectors[i].x)
		maxX = math.max(maxX, mesh.Vectors[i].x)
		minY = math.min(minY, mesh.Vectors[i].y)
		maxY = math.max(maxY, mesh.Vectors[i].y)
	end

	-- then, use that to create the quadtree
	mesh.Quadtree = quadtree(3, 10, vector2(minX - 1, minY - 1), vector2((maxX - minX) + 2, (maxY - minY) + 2));

	-- then, finally insert all the triangles into the quadtree. Lines can be ignored because the quadtree is only used for finding the triangles points are inside of
	for i = 1, #trisAndLines do
		if triangle.isTriangle(trisAndLines[i]) then
			local center, radius = trisAndLines[i]:circumcenter()
			mesh.Quadtree:insert(trisAndLines[i], center, radius)
		end
	end

	return mesh

end



function navmesh:getVectorIndex(v)
	for i = 1, #self.Vectors do
		if self.Vectors[i] == v then
			return i
		end
	end
	return nil
end



function navmesh:pathfind(from, to)
	print("------------ PATHFINDING START ------------")
	local startTriangles = self.Quadtree:getInRange(from, self.Margin)
	local startTriangle = nil
	for i = 1, #startTriangles do
		if startTriangles[i]:encloses(from) then
			startTriangle = startTriangles[i]
		end
	end
	if startTriangle == nil then
		print("no startTriangle")
		-- your starting point fell outside the navigation mesh, so no path was found
		return nil
	end

	local endTriangles = self.Quadtree:getInRange(to, self.Margin)
	local endTriangle = nil
	for i = 1, #endTriangles do
		if endTriangles[i]:encloses(to) then
			endTriangle = endTriangles[i]
		end
	end
	if endTriangle == nil then
		print("no endTriangle")
		-- your starting point fell outside the navigation mesh, so no path was found
		return nil
	end

	if startTriangle == endTriangle then
		return {vector2(from), vector2(to)} -- if the starting point and end point fall within the same triangle, there must be a direct line of sight!
	end

	print("start triangle & end triangle")
	print(startTriangle)
	print(endTriangle)

	-- for the starting point and the end point, create a new node which you connect to the three corners of the triangle you are inside of!
	local indexStart = #self.Vectors + 1
	local indexEnd = #self.Vectors + 2
	self.Vectors[indexStart] = vector2(from)
	self.Vectors[indexEnd] = vector2(to)
	self.Connections[indexStart] = {}
	self.Connections[indexEnd] = {}

	local nodesConnectedToEnd = {}

	-- for the new starting node and end node find the three nodes they're connected to
	local nodesDone = 0
	for i = 1, #self.Vectors - 2 do
		if self.Vectors[i] == startTriangle.Line1.from then
			self.Connections[indexStart][i] = from:dist(startTriangle.Line1.from) -- one-way connection from start to corner
		elseif self.Vectors[i] == startTriangle.Line2.from then
			self.Connections[indexStart][i] = from:dist(startTriangle.Line2.from) -- one-way connection from start to corner
		elseif self.Vectors[i] == startTriangle.Line3.from then
			self.Connections[indexStart][i] = from:dist(startTriangle.Line3.from) -- one-way connection from start to corner
		end
		if self.Vectors[i] == endTriangle.Line1.from then
			self.Connections[i][indexEnd] = to:dist(endTriangle.Line1.from) -- one-way connection from corner to end
			table.insert(nodesConnectedToEnd, i)
		elseif self.Vectors[i] == endTriangle.Line2.from then
			self.Connections[i][indexEnd] = to:dist(endTriangle.Line2.from) -- one-way connection from corner to end
			table.insert(nodesConnectedToEnd, i)
		elseif self.Vectors[i] == endTriangle.Line3.from then
			self.Connections[i][indexEnd] = to:dist(endTriangle.Line3.from) -- one-way connection from corner to end
			table.insert(nodesConnectedToEnd, i)
		end
	end

	-- pathfind
	local openSet = {indexStart}
	local cameFrom = {}
	local gScore = {}
	local fScore = {}

	for i, _ in ipairs(self.Vectors) do
		gScore[i] = math.huge
		fScore[i] = math.huge
	end

	gScore[indexStart] = 0
	fScore[indexStart] = self.Vectors[indexStart]:dist(self.Vectors[indexEnd])

	-- A-star, implemented with the help of some ChatGPT
	while #openSet > 0 do
		local current = nil
		local currentScore = math.huge

		for _, node in ipairs(openSet) do
			if fScore[node] < currentScore then
				current = node
				currentScore = fScore[node]
			end
		end

		if current == indexEnd then
			-- reconstruct the path
			local totalPath = {current}

			while cameFrom[current] do
				current = cameFrom[current]
				table.insert(totalPath, 1, current)
			end

			-- replace all nodes with their actual vectors
			for i, node in ipairs(totalPath) do -- by doing an ipairs loop here instead of a regular for i = ... for-loop we avoid...
				totalPath[i] = self.Vectors[node] -- ... a double ]] bracket here! :)
			end

			-- also, don't forget to remove the 6 connections we earlier to the graph
			self.Connections[indexEnd] = nil
			self.Connections[indexStart] = nil
			self.Vectors[indexEnd] = nil
			self.Vectors[indexStart] = nil
			for i, v in ipairs(nodesConnectedToEnd) do
				self.Connections[v][indexEnd] = nil
			end

			-- now *before* the path is returned, check if any shortcuts can be made by checking for each node in the path if there is a direct line
			-- of sight to a node further on the path!
			-- if that's the case, filter out any nodes in between
			
			local curNode = 1
			while curNode < #totalPath do
				local skipToNode = curNode
				for i = curNode + 2, #totalPath do
					-- check if there's a direct line of sight by grabbing all triangles on the line and seeing if the total length traversed over triangles equals the distance betwene the nodes
					local nodeFrom, nodeTo = totalPath[curNode], totalPath[i]
					local disToNode = nodeFrom:dist(nodeTo)
					-- offset nodeFrom and nodeTo slightly by the amount of the margin. That way there are no edge-cases where the line intersecting a triangle only has 1 intersection point!
					nodeFrom = nodeFrom + (nodeFrom - nodeTo):setMag(self.Margin)
					nodeTo = nodeTo + (nodeTo - nodeFrom):setMag(self.Margin)

					local sumAcrossTriangles = 0
					local trianglesInRange = self.Quadtree:getInRange((nodeFrom + nodeTo) / 2, disToNode / 2)

					print(("evaluating connection %d -> %d"):format(curNode, i))
					for k = 1, #trianglesInRange do
						local p1, p2 = trianglesInRange[k]:intersectLine(line(nodeFrom, nodeTo))
						print(p1, p2)
						if p1 ~= nil and p2 ~= nil then
							--local p3, p4 = trianglesInRange[k]:closestTo(nodeFrom), trianglesInRange[k]:closestTo(nodeTo)
							print(("adding (1) %.2f"):format(p1:dist(p2)))
							sumAcrossTriangles = sumAcrossTriangles + p1:dist(p2)
						elseif p1 ~= nil then
							-- edge-case for the start and end-node where you only hit the triangle once because the point itself is inside of the triangle
							if curNode == 1 and trianglesInRange[k]:encloses(from) then
								sumAcrossTriangles = sumAcrossTriangles + from:dist(p1)
							elseif i == #totalPath and trianglesInRange[k]:encloses(to) then
								sumAcrossTriangles = sumAcrossTriangles + to:dist(p1)
							end
							--[[
							if curNode == 1 and startTriangle:dist(p1) < self.Margin then
								sumAcrossTriangles = sumAcrossTriangles + from:dist(p1)
								print(("adding (2) %.2f"):format(from:dist(p1)))
							elseif i == #totalPath and endTriangle:dist(p1) < self.Margin then
								sumAcrossTriangles = sumAcrossTriangles + to:dist(p1)
								print(("adding (3) %.2f"):format(to:dist(p1)))
							end
							]]
						end
					end
					print(("distance: %.2f out of %.2f"):format(sumAcrossTriangles, disToNode))
					-- there's a direct line between two nodes, so skip to that node immediately!
					if sumAcrossTriangles + self.Margin > disToNode then
						skipToNode = i
						print(("skipping to node %d, with a sum of %.2f out of %.2f"):format(skipToNode, sumAcrossTriangles, disToNode))
					else
						break
					end
				end
				if skipToNode > curNode + 1 then
					-- filter out any nodes in between
					local filterCount = (skipToNode - curNode) - 1
					for k = 1, filterCount do
						table.remove(totalPath, curNode + 1) -- remove the nodes that come after the current node equal to the number of nodes you can skip!
					end
				end
				curNode = curNode + 1
			end
			

			return totalPath
		end

		-- remove the current node from the openSet array
		for i = 1, #openSet do
			if openSet[i] == current then
				table.remove(openSet, i)
				break
			end
		end

		for neighbor, distance in pairs(self.Connections[current] or {}) do
			local tentativeGScore = gScore[current] + distance

			if tentativeGScore < gScore[neighbor] then
				cameFrom[neighbor] = current
				gScore[neighbor] = tentativeGScore
				fScore[neighbor] = gScore[neighbor] + distance

				local contains = false
				for i = 1, #openSet do
					if openSet[i] == neighbor then
						contains = true
						break
					end
				end
				if not contains then
					table.insert(openSet, neighbor)
				end
			end
		end
	end


	-- even if no path isfound, remove the 6 connections we added
	self.Connections[indexEnd] = nil
	self.Connections[indexStart] = nil
	self.Vectors[indexEnd] = nil
	self.Vectors[indexStart] = nil
	for i, v in ipairs(nodesConnectedToEnd) do
		self.Connections[v][indexEnd] = nil
	end

	return nil
end




-- pack up and return module
module.new = new
module.isNavmesh = isNavmesh
return setmetatable(module, {__call = function(_, ...) return new(...) end})



