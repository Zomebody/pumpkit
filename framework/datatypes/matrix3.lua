
local module = {}

-- create the module
local matrix3 = {}
matrix3.__index = matrix3

-- check if an object is a matrix3
local function isMatrix3(t)
	return getmetatable(t) == matrix3
end


-- makes a new matrix3, from a tuple of rows
local function new(m1, m2, m3, m4, m5, m6, m7, m8, m9)
	local Obj = {}

	if m1 == nil then
		Obj[1] = 1
		Obj[2] = 0
		Obj[3] = 0
		Obj[4] = 0
		Obj[5] = 1
		Obj[6] = 0
		Obj[7] = 0
		Obj[8] = 0
		Obj[9] = 1
	elseif type(m1) == "table" and type(m2) == "table" and type(m3) == "table" then
		assert(type(m1[1]) == "number" and type(m1[2]) == "number" and type(m1[3]) == "number", "matrix3.new(row1, row2, row3) requires rows to be arrays with 3 numbers.")
		assert(type(m2[1]) == "number" and type(m2[2]) == "number" and type(m2[3]) == "number", "matrix3.new(row1, row2, row3) requires rows to be arrays with 3 numbers.")
		assert(type(m3[1]) == "number" and type(m3[2]) == "number" and type(m3[3]) == "number", "matrix3.new(row1, row2, row3) requires rows to be arrays with 3 numbers.")
		Obj[1] = m1[1]
		Obj[2] = m1[2]
		Obj[3] = m1[3]
		Obj[4] = m2[1]
		Obj[5] = m2[2]
		Obj[6] = m2[3]
		Obj[7] = m3[1]
		Obj[8] = m3[2]
		Obj[9] = m3[3]
	elseif type(m1) == "number" then
		Obj[1] = m1
		Obj[2] = m2
		Obj[3] = m3
		Obj[4] = m4
		Obj[5] = m5
		Obj[6] = m6
		Obj[7] = m7
		Obj[8] = m8
		Obj[9] = m9
	elseif isMatrix3(m1) then
		Obj[1] = m1[1]
		Obj[2] = m1[2]
		Obj[3] = m1[3]
		Obj[4] = m1[4]
		Obj[5] = m1[5]
		Obj[6] = m1[6]
		Obj[7] = m1[7]
		Obj[8] = m1[8]
		Obj[9] = m1[9]
	else
		error("could not construct matrix3 because none of the constructors match. Make sure each argument is of the right type!")
	end

	return setmetatable(Obj, matrix3)
end



-- construct a matrix that rotates a 3d vector pointing in any direction as if it rotated from dirA to dirB
local function fromRodrigues(dirA, dirB)
	-- normalize inputs
	local a = vector3(dirA):norm()
	local b = vector3(dirB):norm()

	local dotAB = a:dot(b)

	-- means it's already aligned
	if dotAB > 0.9999999 then
		return new()

	-- special case: 180 degree rotation
	elseif dotAB < -0.9999999 then
		-- choose any arbirary vector that is perpendicular
		local perpendicular
		if math.abs(a.x) < 0.9 then
			perpendicular = vector3(1, 0, 0)
		else
			perpendicular = vector3(0, 1, 0)
		end
		local axis = a:cross(perpendicular):norm()
		local x, y, z = axis.x, axis.y, axis.z

		-- rotation by π around axis
		return new(
			-1 + 2 * x^2,  2 * x * y,     2 * x * z,
			2 * y * x,     -1 + 2 * y^2,  2 * y * z,
			2 * z * x,     2 * z * y,     -1 + 2 * z^2
		)
	end

	-- general, non-edge cases
	local v = a:cross(b)
	local k = 1 / (1 + dotAB) -- factor for Rodrigues

	local vx, vy, vz = v.x, v.y, v.z

	-- Rodrigues matrix
	return new(
		dotAB + k * v.x^2,    k * v.x * v.y - v.z,  k * v.x * v.z + v.y,
		k * v.y * v.x + v.z,  dotAB + k * v.y^2,    k * v.y * v.z - v.x,
		k * v.z * v.x - v.y,  k * v.z * v.y + v.x,  dotAB + k * v.z^2
	)

end


-- returns the rows of the matrix3 as a tuple
function matrix3:rows()
	return {self[1], self[2], self[3]}, {self[4], self[5], self[6]}, {self[7], self[8], self[9]}
end


-- returns the columns of the matrix3 as a tuple
function matrix3:columns()
	return {self[1], self[4], self[7]}, {self[2], self[5], self[8]}, {self[3], self[6], self[9]}
end


function matrix3:unpack()
	return self[1], self[2], self[3], self[4], self[5], self[6], self[7], self[8], self[9]
end


-- sets the matrix3 to the identity matrix. Only works if the number of columns and 
function matrix3:identity()
	self[1] = 1
	self[2] = 0
	self[3] = 0
	self[4] = 0
	self[5] = 1
	self[6] = 0
	self[7] = 0
	self[8] = 0
	self[9] = 1
end


function matrix3:determinant()
	return self[1] * (self[5] * self[9] - self[6] * self[8])
			- self[2] * (self[4] * self[9] - self[6] * self[7])
			+ self[3] * (self[4] * self[8] - self[5] * self[7])
end


function matrix3:inverse()
	local det = self:determinant()
	if det == 0 then
		error("matrix3 cannot be inverted because the determinant equals 0.")
	end

	local invDet = 1 / det
	 -- Calculate the adjugate matrix
	local a11 =  (self[5] * self[9] - self[6] * self[8]) * invDet
	local a12 = -(self[2] * self[9] - self[3] * self[8]) * invDet
	local a13 =  (self[2] * self[6] - self[3] * self[5]) * invDet
	local a21 = -(self[4] * self[9] - self[6] * self[7]) * invDet
	local a22 =  (self[1] * self[9] - self[3] * self[7]) * invDet
	local a23 = -(self[1] * self[6] - self[3] * self[4]) * invDet
	local a31 =  (self[4] * self[8] - self[5] * self[7]) * invDet
	local a32 = -(self[1] * self[8] - self[2] * self[7]) * invDet
	local a33 =  (self[1] * self[5] - self[2] * self[4]) * invDet

	-- Create the inverted matrix
	return new(a11, a12, a13, a21, a22, a23, a31, a32, a33)
end



-- add two matrixces together
function matrix3.__add(a, b)
	if isMatrix3(b) then
		return new(
			a[1] + b[1],
			a[2] + b[2],
			a[3] + b[3],
			a[4] + b[4],
			a[5] + b[5],
			a[6] + b[6],
			a[7] + b[7],
			a[8] + b[8],
			a[9] + b[9]
		)
	else
		error("matrix3 addition only works between two matrix3 instances.")
	end
end

-- subtract one matrix from the other
function matrix3.__sub(a, b)
	if isMatrix3(b) then
		return new(
			a[1] - b[1],
			a[2] - b[2],
			a[3] - b[3],
			a[4] - b[4],
			a[5] - b[5],
			a[6] - b[6],
			a[7] - b[7],
			a[8] - b[8],
			a[9] - b[9]
		)
	else
		error("matrix3 subtraction only works between two matrix3 instances.")
	end
end


function matrix3.__unm(a)
	local Obj = new(a:unpack())
	Obj:inverse()
	return Obj
end


function matrix3.__eq(a, b)
	assert(matrix3.isMatrix3(b), "matrix3 == matrix3 operation is only possible on two matrix3 instances.")
	return a[1] == b[1] and a[2] == b[2] and a[3] == b[3] and a[4] == b[4] and a[5] == b[5] and a[6] == b[6] and a[7] == b[7] and a[8] == b[8] and a[9] == b[9]
end


function matrix3.__mul(a, b)
	if type(b) == "number" then
		return new(
			a[1] * b, a[2] * b, a[3] * b,
			a[4] * b, a[5] * b, a[6] * b,
			a[7] * b, a[8] * b, a[9] * b
		)
	elseif isMatrix3(b) then
		return new(
			a[1] * b[1] + a[2] * b[4] + a[3] * b[7],
			a[1] * b[2] + a[2] * b[5] + a[3] * b[8],
			a[1] * b[3] + a[2] * b[6] + a[3] * b[9],
			a[4] * b[1] + a[5] * b[4] + a[6] * b[7],
			a[4] * b[2] + a[5] * b[5] + a[6] * b[8],
			a[4] * b[3] + a[5] * b[6] + a[6] * b[9],
			a[7] * b[1] + a[8] * b[4] + a[9] * b[7],
			a[7] * b[2] + a[8] * b[5] + a[9] * b[8],
			a[7] * b[3] + a[8] * b[6] + a[9] * b[9]
		)
	elseif vector3.isVector3(b) then
		return vector3(
			a[1] * b.x + a[2] * b.y + a[3] * b.z,
			a[4] * b.x + a[5] * b.y + a[6] * b.z,
			a[7] * b.x + a[8] * b.y + a[9] * b.z
		)
	else
		error("matrix3 multiplication only works between two matrix3 instances or a matrix3 and a scalar or a matrix3 and a vector3.")
	end
end


function matrix3:__tostring()
	return string.format(
		"[[%f, %f, %f],\n [%f, %f, %f],\n [%f, %f, %f]]",
		self[1], self[2], self[3],
		self[4], self[5], self[6],
		self[7], self[8], self[9]
	)
end


-- pack up and return module
module.new = new
module.isMatrix3 = isMatrix3
module.fromRodrigues = fromRodrigues
return setmetatable(module, {__call = function(_,...) return new(...) end})
