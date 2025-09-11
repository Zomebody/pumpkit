
local module = {}
-- create the module
local bezier = {}
bezier.__index = bezier

local new


-- check if an object is a bezier
local function isBezier(t)
	return getmetatable(t) == bezier
end



-- returns a copy of a bezier
function bezier:clone()
	return new(self.Points)
end


-- return coordinates in array form
function bezier:array()
	return {self.Points:unpack()}
end


-- return coordinates as a tuple
function bezier:unpack()
	return self.Points:unpack()
end



function bezier:deCasteljau(points, t)
	while #points > 1 do
		local newPoints = {}
		for i = 1, #points - 1 do
			newPoints[i] = points[i] * (1 - t) + points[i + 1] * t
		end
		points = newPoints
	end
	return points[1]
end


function bezier:getVelocityAt(a, t)
	assert(type(a) == "number" and a >= 0 and a <= 1, "bezier:getVelocityAt(a, t) expects 'a' to be a number between 0 and 1.")
	assert((type(t) == "number" and t > 0) or t == nil, "bezier:getVelocityAt(a, t) expects 't' to be a positive number or nil.")

	local n = #self.Points - 1
	if n == 0 then
		if self.Dimensions == 2 then
			return vector2(0, 0)
		elseif self.Dimensions == 3 then
			return vector3(0, 0, 0)
		else
			return vector4(0, 0, 0, 0)
		end
	end


	local derivatives = {}
	for i = 1, n do
		derivatives[i] = (self.Points[i + 1] - self.Points[i]) * n
	end

	-- evaluate at given point
	local tangent = self:deCasteljau(derivatives, a)
	if t == nil then
		if tangent:getMag() > 0 then
			return tangent:norm()
		else
			return vector3(0, 0, 1) -- just return anything that isn't NaN. In an ideal world we throw an error but error handling is annoying
		end
	else
		return tangent / t
	end

end



function bezier:getPoint(t)
	assert(type(t) == "number" and t >= 0 and t <= 1, "bezier:getPoint(t) expects argument 't' to be a number between 0 and 1.")
	return self:deCasteljau(self.Points, t)
end


-- makes a new bezier
local new = function(...)
	local vecs = {...}
	assert(#vecs > 0, "bezier.new(...) expects at least one argument, given are 0 arguments.")
	if type(vecs[1]) == "table" and not (vector2.isVector2(vecs[1]) or vector3.isVector3(vecs[1]) or vector4.isVector4(vecs[1])) then
		vecs = vecs[1]
	end


	local Obj = {
		["Dimensions"] = 0;
		["Points"] = {};
	}

	if vector2.isVector2(vecs[1]) then
		for i = 1, #vecs do
			if vector2.isVector2(vecs[i]) then
				Obj.Points[i] = vector2(vecs[i].x, vecs[i].y)
			else
				error("bezier.new(...) failed because not all vectors are of the same type.")
			end
		end
		Obj.Dimensions = 2
	elseif vector3.isVector3(vecs[1]) then
		for i = 1, #vecs do
			if vector3.isVector3(vecs[i]) then
				Obj.Points[i] = vector3(vecs[i].x, vecs[i].y, vecs[i].z)
			else
				error("bezier.new(...) failed because not all vectors are of the same type.")
			end
		end
		Obj.Dimensions = 3
	elseif vector4.isVector4(vecs[1]) then
		for i = 1, #vecs do
			if vector4.isVector4(vecs[i]) then
				Obj.Points[i] = vector4(vecs[i].x, vecs[i].y, vecs[i].z)
			else
				error("bezier.new(...) failed because not all vectors are of the same type.")
			end
		end
		Obj.Dimensions = 4
	else
		error("bezier.new(...) failed because a table of unknown vectors was given.")
	end


	return setmetatable(Obj, bezier)
end



-- meta function to add a vector to a bezier to offset the bezier
function bezier.__add(a, b)
	--assert(isBezier(a) and vector2.isVector2(b), "add: wrong argument types: (expected <bezier> and <vector2>)")
	assert(isBezier(a) and (
		(vector2.isVector2(b) and a.Dimensions == 2)
		or (vector3.isVector3(b) and a.Dimensions == 3)
		or (vector3.isVector4(b) and a.Dimensions == 4)
		), "add: wrong argument types: (expected <bezier> and <vector2/3/4>)")
	local points = {}
	for i = 1, #a.Points do
		points[i] = a.Points[i] + b
	end
	return new(points)
end



-- pack up and return module
module.new = new
module.isBezier = isBezier
return setmetatable(module, {__call = function(_,...) return new(...) end})


