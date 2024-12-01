

-- mesh files have the following format:
--[[
	# data
	v0 29.4, 1.0, 9.73665
	v1 0.1 84.9 5263.0
	...
	u0 0.5 0.75
	u1 1.0 0.988
	...
	c0 1.0 0.0 1.0 1.0
	c1 0.5 0.5333 1.0 1.0
	...
	n0 0 0 1
	n1 -0.707 0.707 0
	...
	# mesh
	0 4 1 8 4 3 6 22 14 15 19 9
	...

	where in the # data section you have all unique vertices, uv coordinates, colors and normals stored
	and where in the # mesh section individual triangles are stored where each line has the form (v1 u1 c1 n1 v2 u2 c2 n2 v3 u3 c3 n3), i.e. listing 12 references, 4 per vertex


]]


function createMeshFromFile(filename, image)
	local triangles = {}

	-- Open the file
	local file = io.open(filename, "r")
	if not file then
		error("Failed to open file: " .. filename)
	end

	-- new file format
	local positions = {}
	local uvs = {}
	local colors = {}
	local normals = {}

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
			-- store the words from the line into the data dictionaries
			-- the max number of words in a line is 5 (for colors, i.e. c5 1.0, 0.0, 1.0, 1.0). If there are fewer, words[5] etc. will just be nil, so the array becomes smaller
			local firstCharacter = words[1]:sub(1, 1)
			local index = tonumber(words[1]:sub(2))

			if firstCharacter == "v" then
				positions[index] = {tonumber(words[2]), tonumber(words[3]), tonumber(words[4])}
			elseif firstCharacter == "u" then
				uvs[index] = {tonumber(words[2]), tonumber(words[3])}
			elseif firstCharacter == "c" then
				colors[index] = {tonumber(words[2]), tonumber(words[3]), tonumber(words[4]), tonumber(words[5])}
			elseif firstCharacter == "n" then
				normals[index] = {tonumber(words[2]), tonumber(words[3]), tonumber(words[4])}
			end
		else
			-- store the numbers from the line into the array
			local numbers = {}
			for number in string.gmatch(line, "%S+") do
				table.insert(numbers, tonumber(number))
			end
			-- there are exactly 12 words per line in the mesh section, 4 for each triangle (4x3)
			-- v1 u1 c1 n1 v2 u2 c2 n2 v3 u3 c3 n3
			local position1 = positions[numbers[1]]
			local uv1 = uvs[numbers[2]]
			local color1 = colors[numbers[3]]
			local normal1 = normals[numbers[4]]
			local position2 = positions[numbers[5]]
			local uv2 = uvs[numbers[6]]
			local color2 = colors[numbers[7]]
			local normal2 = normals[numbers[8]]
			local position3 = positions[numbers[9]]
			local uv3 = uvs[numbers[10]]
			local color3 = colors[numbers[11]]
			local normal3 = normals[numbers[12]]

			local tri1 = {position1[1], position1[2], position1[3], uv1[1], uv1[2], color1[1], color1[2], color1[3], color1[4], normal1[1], normal1[2], normal1[3]}
			local tri2 = {position2[1], position2[2], position2[3], uv2[1], uv2[2], color2[1], color2[2], color2[3], color2[4], normal2[1], normal2[2], normal2[3]}
			local tri3 = {position3[1], position3[2], position3[3], uv3[1], uv3[2], color3[1], color3[2], color3[3], color3[4], normal3[1], normal3[2], normal3[3]}

			table.insert(triangles, tri1)
			table.insert(triangles, tri2)
			table.insert(triangles, tri3)

		end
	end


	
	-- Close the file
	file:close()
	
	-- Create the mesh
	local mesh = love.graphics.newMesh(
		{
			{"VertexPosition", "float", 3},
			{"VertexTexCoord", "float", 2},
			{"VertexColor", "byte", 4},
			{"VertexNormal", "float", 3}
		},
		triangles,
		"triangles",
		"static"
	)

	if image ~= nil then
		mesh:setTexture(image)
	end
	
	return mesh
end



return createMeshFromFile



