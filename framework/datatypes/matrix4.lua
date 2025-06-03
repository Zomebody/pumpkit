local module = {}

-- create the module
local matrix4 = {}
matrix4.__index = matrix4

-- check if an object is a matrix4
local function isMatrix4(t)
	return getmetatable(t) == matrix4
end

-- makes a new matrix4, from a tuple of rows
local function new(m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, m14, m15, m16)
	local Obj = {}

	if m1 == nil then
		Obj[1] = 1
		Obj[2] = 0
		Obj[3] = 0
		Obj[4] = 0
		Obj[5] = 0
		Obj[6] = 1
		Obj[7] = 0
		Obj[8] = 0
		Obj[9] = 0
		Obj[10] = 0
		Obj[11] = 1
		Obj[12] = 0
		Obj[13] = 0
		Obj[14] = 0
		Obj[15] = 0
		Obj[16] = 1
	elseif type(m1) == "table" and type(m2) == "table" and type(m3) == "table" and type(m4) == "table" then
		assert(type(m1[1]) == "number" and type(m1[2]) == "number" and type(m1[3]) == "number" and type(m1[4]) == "number", "matrix4.new(row1, row2, row3, row4) requires rows to be arrays with 4 numbers.")
		assert(type(m2[1]) == "number" and type(m2[2]) == "number" and type(m2[3]) == "number" and type(m2[4]) == "number", "matrix4.new(row1, row2, row3, row4) requires rows to be arrays with 4 numbers.")
		assert(type(m3[1]) == "number" and type(m3[2]) == "number" and type(m3[3]) == "number" and type(m3[4]) == "number", "matrix4.new(row1, row2, row3, row4) requires rows to be arrays with 4 numbers.")
		assert(type(m4[1]) == "number" and type(m4[2]) == "number" and type(m4[3]) == "number" and type(m4[4]) == "number", "matrix4.new(row1, row2, row3, row4) requires rows to be arrays with 4 numbers.")
		Obj[1] = m1[1]
		Obj[2] = m1[2]
		Obj[3] = m1[3]
		Obj[4] = m1[4]
		Obj[5] = m2[1]
		Obj[6] = m2[2]
		Obj[7] = m2[3]
		Obj[8] = m2[4]
		Obj[9] = m3[1]
		Obj[10] = m3[2]
		Obj[11] = m3[3]
		Obj[12] = m3[4]
		Obj[13] = m4[1]
		Obj[14] = m4[2]
		Obj[15] = m4[3]
		Obj[16] = m4[4]
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
		Obj[10] = m10
		Obj[11] = m11
		Obj[12] = m12
		Obj[13] = m13
		Obj[14] = m14
		Obj[15] = m15
		Obj[16] = m16
	elseif isMatrix4(m1) then
		for i = 1, 16 do
			Obj[i] = m1[i]
		end
	else
		error("could not construct matrix4 because none of the constructors match. Make sure each argument is of the right type!")
	end

	return setmetatable(Obj, matrix4)
end



local function fromQuaternion(q) -- vector4s are also allowed
	local xx = q.x^2
	local yy = q.y^2
	local zz = q.z^2
	local xy = q.x * q.y
	local xz = q.x * q.z
	local yz = q.y * q.z
	local wx = q.w * q.x
	local wy = q.w * q.y
	local wz = q.w * q.z

	return new(
		1 - 2 * (yy + zz), 2 * (xy - wz), 2 * (xz + wy), 0,
		2 * (xy + wz), 1 - 2 * (xx + zz), 2 * (yz - wx), 0,
		2 * (xz - wy), 2 * (yz + wx), 1 - 2 * (xx + yy), 0,
		0, 0, 0, 1
	)
end



--[[
-- helper function for interpolate
local function lerp(a, b, t)
	return a + (b - a) * t
end

-- helper function for interpolate
local function slerpQuaternion(q1, q2, t)
	local dot = q1.x * q2.x + q1.y * q2.y + q1.z * q2.z + q1.w * q2.w
	if dot < 0 then
		q2 = -q2
		dot = -dot
	end

	dot = math.min(1, math.max(-1, dot))
	local theta = math.acos(dot)
	local sinTheta = math.sin(theta)
	if sinTheta < 0.001 then
		return vector4(
			lerp(q1.x, q2.x, t),
			lerp(q1.y, q2.y, t),
			lerp(q1.z, q2.z, t),
			lerp(q1.w, q2.w, t)
		):norm()
	end

	-- interpolation weights
	local w1 = math.sin((1 - t) * theta) / sinTheta
	local w2 = math.sin(t * theta) / sinTheta

	return vector4(
		q1.x * w1 + q2.x * w2,
		q1.y * w1 + q2.y * w2,
		q1.z * w1 + q2.z * w2,
		q1.w * w1 + q2.w * w2
	):norm()
end
]]


-- interpolate from one matrix4 to another matrix4, useful when moving cameras from one place to another
local function interpolate(m1, m2, t)
	-- get positions
	local p1 = m1:getPosition() -- getPosition works correctly
	local p2 = m2:getPosition()

	local newP = lerp(p1, p2, t) -- works correctly

	-- get rotations
	local q1 = m1:toQuaternion() -- worked correctly in online converter
	local q2 = m2:toQuaternion()
	--local newQ = slerpQuaternion(q1, q2, t)
	local newQ = quaternion.slerp(q1, q2, t)

	-- get scales
	local s1 = m1:getScale()
	local s2 = m2:getScale()
	local newS = lerp(s1, s2, t)

	local baseMatrix = fromQuaternion(newQ) -- newQ -- also works correctly somehow????
	--print("matrix from quaternion")
	--print(baseMatrix)
	local scaleMatrix = new(
		newS.x, 0, 0, 0,
		0, newS.y, 0, 0,
		0, 0, newS.z, 0,
		0, 0, 0, 1
	)

	-- combine
	baseMatrix = baseMatrix * scaleMatrix -- scale matrix

	baseMatrix:translate(newP.x, newP.y, newP.z)
	--print("baseMatrix:", baseMatrix:getPosition())
	return baseMatrix
end



local function rotationX(angle)
	local c = math.cos(angle)
	local s = math.sin(angle)
	return new(
		1, 0, 0, 0,
		0, c, s, 0,
		0, -s, c, 0,
		0, 0, 0, 1
	)
end


local function rotationY(angle)
	local c = math.cos(angle)
	local s = math.sin(angle)
	return new(
		c, 0, -s, 0,
		0, 1, 0, 0,
		s, 0, c, 0,
		0, 0, 0, 1
	)
end


local function rotationZ(angle)
	local c = math.cos(angle)
	local s = math.sin(angle)
	return new(
		c, s, 0, 0,
		-s, c, 0, 0,
		0, 0, 1, 0,
		0, 0, 0, 1
	)
end



local function translation(x, y, z)
	if vector3.isVector3(x) then
		z = x.z
		y = x.y
		x = x.x
	end
	return new(
		0, 0, 0, x,
		0, 0, 0, y,
		0, 0, 0, z,
		0, 0, 0, 1
	)
end


local function perspective(aspectRatio, fov, far, near)
	if far == nil then far = 1000 end
	if near == nil then near = 0.1 end

	local m11 = 1 / (aspectRatio * math.tan(fov / 2))
	local m22 = 1 / math.tan(fov / 2)
	local m33 = -(far + near) / (far - near)
	local m43 = -(2 * far * near) / (far - near)
	local m34 = -1

	return new(
		m11, 0, 0, 0,
		0, m22, 0, 0,
		0, 0, m33, m34,
		0, 0, m43, 0
	)
end


local function orthographic(left, right, top, bottom, far, near)
	if far == nil then far = 1000 end
	if near == nil then near = 0.1 end

	local m11 = 2 / (right - left)
	local m22 = 2 / (top - bottom)
	local m33 = -2 / (far - near)
	local m41 = -(right + left) / (right - left)
	local m42 = -(top + bottom) / (top - bottom)
	local m43 = -(far + near) / (far - near)
	local m44 = 1

	return new(
		m11, 0,   0,   0,
		0,   m22, 0,   0,
		0,   0,   m33, 0,
		m41, m42, m43, m44
	)
end



local function lookAtWorld(position, direction, up)
	up = up or vector3(0, 0, 1)

	local zAxis = -direction:norm() -- minus one is needed here
	-- right-vector
	local xAxis = up:cross(zAxis):norm()
	-- (view-space) up-vector
	local yAxis = zAxis:cross(xAxis)


	return new(
		xAxis.x, xAxis.y, xAxis.z, 0,
		yAxis.x, yAxis.y, yAxis.z, 0,
		zAxis.x, zAxis.y, zAxis.z, 0,
		position.x, position.y, position.z, 1
	)
end




-- from euler angles and specify the euler order
local function fromEuler(euler, order)
	local rotX = rotationX(euler.x)
	local rotY = rotationY(euler.y)
	local rotZ = rotationZ(euler.z)

	if order == "xyz" then
		return rotZ * rotY * rotX
	elseif order == "yxz" then
		return rotZ * rotX * rotY
	elseif order == "zyx" then
		return rotX * rotY * rotZ
	elseif order == "xzy" then
		return rotY * rotZ * rotX
	elseif order == "yzx" then
		return rotX * rotZ * rotY
	elseif order == "zxy" then
		return rotY * rotX * rotZ
	else
		error("Invalid rotation order supplied in fromEuler")
	end
end



-- using the same calculation as found here: https://github.com/CoppeliaRobotics/lua/blob/master/matrix.lua
function matrix4:toEulerXYZ() -- assumes xyz order
	--local euler = vector3(0, 0, 0)

	return vector3(
		math.atan2(self[7], self[11]),
		math.atan2(-self[3], math.sqrt(self[7]^2 + self[11]^2)),
		math.atan2(self[2], self[1])
	)
end



-- given is a local directional vector. Calculate a new vector that describes the same direction, but in world space rather than relative to the camera
function matrix4:toWorldVector(vec)
	local right = vector3(self[1], self[2], self[3])
	local up = vector3(self[5], self[6], self[7])
	local forward = vector3(self[9], self[10], self[11])

	local deltaRight = vector3(right.x * vec.x, right.y * vec.x, right.z * vec.x)
	local deltaUp = vector3(up.x * vec.y, up.y * vec.y, up.z * vec.y)
	local deltaForward = vector3(forward.x * vec.z, forward.y * vec.z, forward.z * vec.z)

	local deltaVector = vector3(
		deltaRight.x + deltaUp.x + deltaForward.x,
		deltaRight.y + deltaUp.y + deltaForward.y,
		deltaRight.z + deltaUp.z + deltaForward.z
	)

	return deltaVector
end


-- converted from https://www.euclideanspace.com/maths/geometry/rotations/conversions/matrixToQuaternion/
function matrix4:toQuaternion()
	local trace = self[1] + self[6] + self[11]
	local qw, qx, qy, qz

	if trace > 0 then
		local s = math.sqrt(trace + 1) * 2
		qw = 0.25 * s
		qx = (self[10] - self[7]) / s
		qy = (self[3] - self[9]) / s
		qz = (self[5] - self[2]) / s
	else
		if self[1] > self[6] and self[1] > self[11] then
			local s = 2 * math.sqrt(1 + self[1] - self[6] - self[11])
			qw = (self[10] - self[7]) / s
			qx = 0.25 * s
			qy = (self[2] + self[5]) / s
			qz = (self[3] + self[9]) / s
		elseif self[6] > self[11] then
			local s = 2 * math.sqrt(1 + self[6] - self[1] - self[11])
			qw = (self[3] - self[9]) / s
			qx = (self[2] + self[5]) / s
			qy = 0.25 * s
			qz = (self[7] + self[10]) / s
		else
			local s = 2 * math.sqrt(1 + self[11] - self[1] - self[6])
			qw = (self[5] - self[2]) / s
			qx = (self[3] + self[9]) / s
			qy = (self[7] + self[10]) / s
			qz = 0.25 * s
		end
	end

	return quaternion(qx, qy, qz, qw)

end


-- get the scale of the upper-left 3x3 matrix as a vector3 representing the scale of each row
function matrix4:getScale()
	local sx = math.sqrt(self[1]^2 + self[2]^2 + self[3]^2)
	local sy = math.sqrt(self[5]^2 + self[6]^2 + self[7]^2)
	local sz = math.sqrt(self[9]^2 + self[10]^2 + self[11]^2)
	return vector3(sx, sy, sz)
end


function matrix4:getPosition()
	return vector3(self[13], self[14], self[15])
end



-- returns the rows of the matrix4 as a tuple
function matrix4:rows()
	return {self[1], self[2], self[3], self[4]}, {self[5], self[6], self[7], self[8]}, {self[9], self[10], self[11], self[12]}, {self[13], self[14], self[15], self[16]}
end


-- returns the columns of the matrix4 as a tuple
function matrix4:columns()
	return {self[1], self[5], self[9], self[13]}, {self[2], self[6], self[10], self[14]}, {self[3], self[7], self[11], self[15]}, {self[4], self[8], self[12], self[16]}
end


function matrix4:unpack()
	return self[1], self[2], self[3], self[4], self[5], self[6], self[7], self[8], self[9], self[10], self[11], self[12], self[13], self[14], self[15], self[16]
end


-- sets the matrix4 to the identity matrix
function matrix4:identity()
	self[1] = 1
	self[2] = 0
	self[3] = 0
	self[4] = 0
	self[5] = 0
	self[6] = 1
	self[7] = 0
	self[8] = 0
	self[9] = 0
	self[10] = 0
	self[11] = 1
	self[12] = 0
	self[13] = 0
	self[14] = 0
	self[15] = 0
	self[16] = 1
	return self
end



function matrix4:translate(x, y, z)
	if vector3.isVector3(x) then
		z = x.z
		y = x.y
		x = x.x
	end
	self[13] = self[13] + x
	self[14] = self[14] + y
	self[15] = self[15] + z
	return self
end


-- rotate a matrix along the X-axis by a certain angle
function matrix4:rotateX(angle)
	local rx = rotationX(angle)
	return self * rx
end

-- rotate a matrix along the Y-axis by a certain angle
function matrix4:rotateY(angle)
	local ry = rotationY(angle)
	return self * ry
end

-- rotate a matrix along the Z-axis by a certain angle
function matrix4:rotateZ(angle)
	local rz = rotationZ(angle)
	return self * rz
end


-- return the transpose of the matrix
function matrix4:transpose()

	return new(self[1], self[5], self[9], self[13], self[2], self[6], self[10], self[14], self[3], self[7], self[11], self[15], self[4], self[8], self[12], self[16])
end




-- calculate the determinant of the matrix4: https://semath.info/src/determinant-four-by-four.html
function matrix4:determinant()
	local a = self
	local det = a[1] * (a[6] * a[11] * a[16]     +     a[7] * a[12] * a[14]     +     a[8] * a[10] * a[15]     -     a[8] * a[11] * a[14]     -     a[7] * a[10] * a[16]     -     a[6] * a[12] * a[15])
				- a[5] * (a[2] * a[11] * a[16]     +     a[3] * a[12] * a[14]     +     a[4] * a[10] * a[15]     -     a[4] * a[11] * a[14]     -     a[3] * a[10] * a[16]     -     a[2] * a[12] * a[15])
				+ a[9] * (a[2] * a[7] * a[16]     +     a[3] * a[8] * a[14]     +     a[4] * a[6] * a[15]     -     a[4] * a[7] * a[14]     -     a[3] * a[6] * a[16]     -     a[2] * a[8] * a[15])
				- a[13] * (a[2] * a[7] * a[12]     +     a[3] * a[8] * a[10]     +     a[4] * a[6] * a[11]     -     a[4] * a[7] * a[10]     -     a[3] * a[6] * a[12]     -     a[2] * a[8] * a[11])
	return det
end



-- invert the matrix4
function matrix4:inverse()
	local det = self:determinant()
	if det == 0 then
		error("matrix4 cannot be inverted because the determinant equals 0.")
	end

	local invDet = 1 / det
	local a = self

	-- Calculate the adjugate matrix (this can be done more efficiently) <-- this comment was generated by ChatGPT lol
	local inv = {
		(a[6]*a[11]*a[16] - a[6]*a[12]*a[15] - a[10]*a[7]*a[16] + a[10]*a[8]*a[15] + a[14]*a[7]*a[12] - a[14]*a[8]*a[11]) * invDet,
		(-a[2]*a[11]*a[16] + a[2]*a[12]*a[15] + a[10]*a[3]*a[16] - a[10]*a[4]*a[15] - a[14]*a[3]*a[12] + a[14]*a[4]*a[11]) * invDet,
		(a[2]*a[7]*a[16] - a[2]*a[8]*a[15] - a[6]*a[3]*a[16] + a[6]*a[4]*a[15] + a[14]*a[3]*a[8] - a[14]*a[4]*a[7]) * invDet,
		(-a[2]*a[7]*a[12] + a[2]*a[8]*a[11] + a[6]*a[3]*a[12] - a[6]*a[4]*a[11] - a[10]*a[3]*a[8] + a[10]*a[4]*a[7]) * invDet,
		(-a[5]*a[11]*a[16] + a[5]*a[12]*a[15] + a[9]*a[7]*a[16] - a[9]*a[8]*a[15] - a[13]*a[7]*a[12] + a[13]*a[8]*a[11]) * invDet,
		(a[1]*a[11]*a[16] - a[1]*a[12]*a[15] - a[9]*a[3]*a[16] + a[9]*a[4]*a[15] + a[13]*a[3]*a[12] - a[13]*a[4]*a[11]) * invDet,
		(-a[1]*a[7]*a[16] + a[1]*a[8]*a[15] + a[5]*a[3]*a[16] - a[5]*a[4]*a[15] - a[13]*a[3]*a[8] + a[13]*a[4]*a[7]) * invDet,
		(a[1]*a[7]*a[12] - a[1]*a[8]*a[11] - a[5]*a[3]*a[12] + a[5]*a[4]*a[11] + a[9]*a[3]*a[8] - a[9]*a[4]*a[7]) * invDet,
		(a[5]*a[10]*a[16] - a[5]*a[12]*a[14] - a[9]*a[6]*a[16] + a[9]*a[8]*a[14] + a[13]*a[6]*a[12] - a[13]*a[8]*a[10]) * invDet,
		(-a[1]*a[10]*a[16] + a[1]*a[12]*a[14] + a[9]*a[2]*a[16] - a[9]*a[4]*a[14] - a[13]*a[2]*a[12] + a[13]*a[4]*a[10]) * invDet,
		(a[1]*a[6]*a[16] - a[1]*a[8]*a[14] - a[5]*a[2]*a[16] + a[5]*a[4]*a[14] + a[13]*a[2]*a[8] - a[13]*a[4]*a[6]) * invDet,
		(-a[1]*a[6]*a[12] + a[1]*a[8]*a[10] + a[5]*a[2]*a[12] - a[5]*a[4]*a[10] - a[9]*a[2]*a[8] + a[9]*a[4]*a[6]) * invDet,
		(-a[5]*a[10]*a[15] + a[5]*a[11]*a[14] + a[9]*a[6]*a[15] - a[9]*a[7]*a[14] - a[13]*a[6]*a[11] + a[13]*a[7]*a[10]) * invDet,
		(a[1]*a[10]*a[15] - a[1]*a[11]*a[14] - a[9]*a[2]*a[15] + a[9]*a[3]*a[14] + a[13]*a[2]*a[11] - a[13]*a[3]*a[10]) * invDet,
		(-a[1]*a[6]*a[15] + a[1]*a[7]*a[14] + a[5]*a[2]*a[15] - a[5]*a[3]*a[14] - a[13]*a[2]*a[7] + a[13]*a[3]*a[6]) * invDet,
		(a[1]*a[6]*a[11] - a[1]*a[7]*a[10] - a[5]*a[2]*a[11] + a[5]*a[3]*a[10] + a[9]*a[2]*a[7] - a[9]*a[3]*a[6]) * invDet
	}

	return new(unpack(inv))
end

-- add two matrices together
function matrix4.__add(a, b)
	if isMatrix4(b) then
		return new(
			a[1] + b[1],
			a[2] + b[2],
			a[3] + b[3],
			a[4] + b[4],
			a[5] + b[5],
			a[6] + b[6],
			a[7] + b[7],
			a[8] + b[8],
			a[9] + b[9],
			a[10] + b[10],
			a[11] + b[11],
			a[12] + b[12],
			a[13] + b[13],
			a[14] + b[14],
			a[15] + b[15],
			a[16] + b[16]
		)
	else
		error("matrix4 addition only works between two matrix4 instances.")
	end
end

-- subtract one matrix from the other
function matrix4.__sub(a, b)
	if isMatrix4(b) then
		return new(
			a[1] - b[1],
			a[2] - b[2],
			a[3] - b[3],
			a[4] - b[4],
			a[5] - b[5],
			a[6] - b[6],
			a[7] - b[7],
			a[8] - b[8],
			a[9] - b[9],
			a[10] - b[10],
			a[11] - b[11],
			a[12] - b[12],
			a[13] - b[13],
			a[14] - b[14],
			a[15] - b[15],
			a[16] - b[16]
		)
	else
		error("matrix4 subtraction only works between two matrix4 instances.")
	end
end


-- invert the matrix
function matrix4.__unm(a)
	local Obj = new(a:unpack())
	return Obj:inverse()
end


-- check equality of two matrices
function matrix4.__eq(a, b)
	assert(isMatrix4(b), "matrix4 == matrix4 operation is only possible on two matrix4 instances.")
	for i = 1, 16 do
		if a[i] ~= b[i] then
			return false
		end
	end
	return true
end


-- multiply matrix by another matrix or a scalar
function matrix4.__mul(a, b)
	if type(b) == "number" then
		return new(
			a[1] * b, a[2] * b, a[3] * b, a[4] * b,
			a[5] * b, a[6] * b, a[7] * b, a[8] * b,
			a[9] * b, a[10] * b, a[11] * b, a[12] * b,
			a[13] * b, a[14] * b, a[15] * b, a[16] * b
		)
	elseif isMatrix4(b) then
		return new(
			a[1] * b[1] + a[2] * b[5] + a[3] * b[9] + a[4] * b[13],
			a[1] * b[2] + a[2] * b[6] + a[3] * b[10] + a[4] * b[14],
			a[1] * b[3] + a[2] * b[7] + a[3] * b[11] + a[4] * b[15],
			a[1] * b[4] + a[2] * b[8] + a[3] * b[12] + a[4] * b[16],
			a[5] * b[1] + a[6] * b[5] + a[7] * b[9] + a[8] * b[13],
			a[5] * b[2] + a[6] * b[6] + a[7] * b[10] + a[8] * b[14],
			a[5] * b[3] + a[6] * b[7] + a[7] * b[11] + a[8] * b[15],
			a[5] * b[4] + a[6] * b[8] + a[7] * b[12] + a[8] * b[16],
			a[9] * b[1] + a[10] * b[5] + a[11] * b[9] + a[12] * b[13],
			a[9] * b[2] + a[10] * b[6] + a[11] * b[10] + a[12] * b[14],
			a[9] * b[3] + a[10] * b[7] + a[11] * b[11] + a[12] * b[15],
			a[9] * b[4] + a[10] * b[8] + a[11] * b[12] + a[12] * b[16],
			a[13] * b[1] + a[14] * b[5] + a[15] * b[9] + a[16] * b[13],
			a[13] * b[2] + a[14] * b[6] + a[15] * b[10] + a[16] * b[14],
			a[13] * b[3] + a[14] * b[7] + a[15] * b[11] + a[16] * b[15],
			a[13] * b[4] + a[14] * b[8] + a[15] * b[12] + a[16] * b[16]
		)
	elseif vector4.isVector4(b) then
		return vector4(
			a[1] * b.x + a[2] * b.y + a[3] * b.z + a[4] * b.w,
			a[5] * b.x + a[6] * b.y + a[7] * b.z + a[8] * b.w,
			a[9] * b.x + a[10] * b.y + a[11] * b.z + a[12] * b.w,
			a[13] * b.x + a[14] * b.y + a[15] * b.z + a[16] * b.w
		)
	else
		error("matrix4 multiplication only works between two matrix4 instances or a matrix4 and a scalar.")
	end
end


-- convert matrix to string for display
function matrix4:__tostring()
	return string.format(
		"[[%f, %f, %f, %f],\n [%f, %f, %f, %f],\n [%f, %f, %f, %f],\n [%f, %f, %f, %f]]",
		self[1], self[2], self[3], self[4],
		self[5], self[6], self[7], self[8],
		self[9], self[10], self[11], self[12],
		self[13], self[14], self[15], self[16]
	)
end


-- pack up and return module
module.new = new
module.rotationX = rotationX
module.rotationY = rotationY
module.rotationZ = rotationZ
module.perspective = perspective
module.orthographic = orthographic
module.lookAtWorld = lookAtWorld
module.translation = translation
module.fromEuler = fromEuler
module.fromQuaternion = fromQuaternion
module.interpolate = interpolate
module.isMatrix4 = isMatrix4
return setmetatable(module, {__call = function(_, ...) return new(...) end})
