

-- .lcol files have the following format:
--[[
	# data
	v0 5.8273, 6.9854, 0.0
	v1 3.1182, 8.8730, 0.0
	...
	# lines
	0 4
	3 9
	8 7
	...

	where in the # data section you have all unique vertices
	and where in the # lines section you have edges that make up the collision


]]


function createCollisionFromFile(filename, margin)
	if margin == nil then
		margin = 0.01
	end

	-- store bounds to know how big to make the quadtree later
	local minX, maxX = math.huge, -math.huge
	local minY, maxY = math.huge, -math.huge
	
	-- open the file
	local file = io.open(filename, "r")
	if not file then
		error("Failed to open file: " .. filename)
	end

	-- new file format
	local positions = {}
	local lines = {} -- vector2s and line2s that will be used to construct the navmesh

	local readingData = true
	for line in file:lines() do
		if line:sub(1, 1) == "#" then
			if line == "# lines" then
				readingData = false
			end
		elseif readingData then
			-- read the words from the line into an array
			local words = {}
			for word in string.gmatch(line, "%S+") do
				table.insert(words, tonumber(word))
			end
			-- update bounds
			minX = math.min(minX, words[1])
			maxX = math.max(maxX, words[1])
			minY = math.min(minY, words[2])
			maxY = math.max(maxY, words[2])
			-- convert each line into a vector3 (z-coordinate is stored yet ignored for now)
			table.insert(positions, vector3(words[1], words[2], words[3]))
		else
			-- store the numbers from the line into the array
			local numbers = {}
			for number in string.gmatch(line, "%S+") do
				table.insert(numbers, tonumber(number))
			end

			table.insert(lines, line2(
				vector2(positions[numbers[1] + 1].x, positions[numbers[1] + 1].y),
				vector2(positions[numbers[2] + 1].x, positions[numbers[2] + 1].y)
			))
			

		end
	end
	
	-- close the file
	file:close()
	
	-- create the navmesh
	local colTree = quadtree(
		vector2(minX - margin, minY - margin),
		vector2((maxX - minX) + margin * 2, (maxY - minY) + margin * 2),
		3,
		8
	)
	for i = 1, #lines do
		colTree:insert(lines[i], lines[i]:getCenter(), lines[i]:getLength() / 2)
	end

	
	return colTree
end



return createCollisionFromFile



