
--[[

FILE FORMAT:

header:
lms			<- 3 bytes of text
meshIfBig	<- 1 byte (boolean) indicating how many bytes xyz coords take up
version		<- 2 bytes (0-65535)
tri count	<- 2 bytes (0-65535) larger meshes not supported (and definitely not needed)

then, it's a series of triangles:
x = vertex X coordinate (either 2 bytes or 4 bytes)
y = vertex Y coordinate (either 2 bytes or 4 bytes)
z = vertex Z coordinate (either 2 bytes or 4 bytes)
u = UV.x coordinate (float)
v = UV.y coordinate (float)
r = color.r (1 byte unsigned)
g = color.g (1 byte unsigned)
b = color.b (1 byte unsigned)
a = color.a (1 byte unsigned)
nx = normal.x (1 byte)
ny = normal.y (1 byte)
nz = normal.z (1 byte)
tx = tangent.x (1 byte)
ty = tangent.y (1 byte)
tz = tangent.z (1 byte)
bx = bitangent.x (1 byte)
by = bitangent.y (1 byte)
bz = bitangent.z (1 byte)


]]

function createMeshFromFile(filename)
	local vertices = {} -- array of arrays, each subarray: {x, y, z, u, v, r, g, b, a, nx, ny, nz, tx, ty, tz, bx, by, bz}
	
	-- read the whole file all at once
	local data, msg = love.filesystem.read(filename)
	if type(msg) == "string" then
		error(("failed to create mesh '%s': %s"):format(filename, msg))
	end

	-- read header
	local magic, isBig, dataVersion, triCount, index = love.data.unpack("<c3BHH", data, 1) -- 3 characters, 1 byte, 2 unsigned shorts

	if magic ~= "lms" then
		error(("invalid file format for file '%s': magic mismatch"):format(filename))
	end

	local meshIsBig = (isBig ~= 0)
	local vertexFormat = "<hhhffBBBBbbbbbbbbb"
	if meshIsBig then
		vertexFormat  =  "<fffffBBBBbbbbbbbbb"
	end
	local x, y, z, u, v, r, g, b, a, nx, ny, nz, tx, ty, tz, bx, by, bz

	if filename == "maps/backyard/terrain/terrain_sand.lmsh" then
		print(filename)
	end

	for i = 1, triCount * 3 do -- n.o. vertices = triangle count times 3
		x, y, z, u, v, r, g, b, a, nx, ny, nz, tx, ty, tz, bx, by, bz, index = love.data.unpack(vertexFormat, data, index)
		-- decode some of the values
		if not meshIsBig then
			x = x / 8000
			y = y / 8000
			z = z / 8000
		end
		r = r / 255
		g = g / 255
		b = b / 255
		a = a / 255
		nx = nx / 127
		ny = ny / 127
		nz = nz / 127
		tx = tx / 127
		ty = ty / 127
		tz = tz / 127
		bx = bx / 127
		by = by / 127
		bz = bz / 127
		table.insert(vertices, {x, y, z, u, 1 - v, r, g, b, a, nx, ny, nz, tx, ty, tz, bx, by, bz}) -- ALSO surface normals added in the if-statement below!

		if filename == "maps/backyard/terrain/terrain_sand.lmsh" then
			print(tx, tx, tz)
			print(bx, by, bz)
			print(nx, ny, nz)
		end

		-- all of this just to compute a surface normal
		
		if i % 3 == 0 then -- every 3rd vertex calculate and insert the triangle's surface normal
			local last = #vertices
			local t1 = vertices[last - 2]
			local t2 = vertices[last - 1]
			local t3 = vertices[last]
			local v1 = vector3(t1[1], t1[2], t1[3])
			local v2 = vector3(t2[1], t2[2], t2[3])
			local v3 = vector3(t3[1], t3[2], t3[3])
			local edge1 = v2 - v1
			local edge2 = v3 - v1
			local normal = edge1:cross(edge2)
			normal:norm()
			table.insert(t1, normal.x)
			table.insert(t1, normal.y)
			table.insert(t1, normal.z)
			table.insert(t2, normal.x)
			table.insert(t2, normal.y)
			table.insert(t2, normal.z)
			table.insert(t3, normal.x)
			table.insert(t3, normal.y)
			table.insert(t3, normal.z)
		end
		
		
	end
	
	-- create the mesh
	local mesh = love.graphics.newMesh(
		{
			{"VertexPosition", "float", 3},
			{"VertexTexCoord", "float", 2},
			{"VertexColor", "byte", 4},
			{"VertexNormal", "float", 3},
			{"VertexTangent", "float", 3},
			{"VertexBitangent", "float", 3},
			{"SurfaceNormal", "float", 3} -- it pains me but this is *specifically* needed for solving shadow acne & triplanar sampling, that's why we're adding 3 extra floats
		},
		vertices,
		"triangles",
		"static"
	)
	
	return mesh
end




return createMeshFromFile



