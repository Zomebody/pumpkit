

-- .lnav files have the following format:
--[[
	# data
	v0 29.4, 1.0, 9.73665
	v1 0.1 84.9 5263.0
	...
	# mesh
	0 4 1
	3 9
	8 7 14
	...

	where in the # data section you have all unique vertices
	and where in the # mesh section you have triangles and edges that make up the navmesh graph


]]


function createNavFromFile(filename, margin)
	
	-- open the file
	local file = io.open(filename, "r")
	if not file then
		error("Failed to open file: " .. filename)
	end

	-- new file format
	local positions = {}
	local elements = {} -- vector2s and line2s that will be used to construct the navmesh

	local readingData = true
	for line in file:lines() do
		if line:sub(1, 1) == "#" then
			if line == "# mesh" then
				readingData = false
			end
		elseif readingData then
			-- read the words from the line into an array
			local words = {}
			for word in string.gmatch(line, "%S+") do
				table.insert(words, word)
			end
			-- convert each line into a vector3 (z-coordinate is stored yet ignored for now)
			table.insert(positions, vector3(tonumber(words[1]), tonumber(words[2]), tonumber(words[3])))
		else
			-- store the numbers from the line into the array
			local numbers = {}
			for number in string.gmatch(line, "%S+") do
				table.insert(numbers, tonumber(number))
			end

			if #numbers == 2 then -- line2
				table.insert(elements, line2(
					vector2(positions[numbers[1] + 1].x, positions[numbers[1] + 1].y),
					vector2(positions[numbers[2] + 1].x, positions[numbers[2] + 1].y)
				))
			elseif #numbers == 3 then -- triangle
				table.insert(elements, triangle(
					vector2(positions[numbers[1] + 1].x, positions[numbers[1] + 1].y),
					vector2(positions[numbers[2] + 1].x, positions[numbers[2] + 1].y),
					vector2(positions[numbers[3] + 1].x, positions[numbers[3] + 1].y)
				))
			end
			

		end
	end
	
	-- close the file
	file:close()
	
	-- create the navmesh
	local navigator = navmesh(elements, margin)

	
	return navigator
end



return createNavFromFile



