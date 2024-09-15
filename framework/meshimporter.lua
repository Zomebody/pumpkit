


function createMeshFromFile(filename, image)
	local triangles = {}

	-- Open the file
	local file = io.open(filename, "r")
	if not file then
		error("Failed to open file: " .. filename)
	end
	
	-- read the file line by line
	for line in file:lines() do
		local tri = {}
		for word in string.gmatch(line, "%S+") do
			table.insert(tri, tonumber(word))
		end
		table.insert(triangles, tri)
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



