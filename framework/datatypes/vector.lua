local module = {
_version = "vector.lua v2019.14.12",
_description = "a simple vector library for Lua based on the PVector class from processing",
_url = "https://github.com/themousery/vector.lua",
_license = [[
Copyright (c) 2018 themousery

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
	]]
}

-- create the module
local vector = {}
vector.__index = vector

-- get a random function from Love2d or base lua, in that order.
local rand = math.random
if love and love.math then rand = love.math.random end

-- makes a new vector
local function new(x, y)
	return setmetatable({x=x or 0, y=y or 0}, vector)
end

-- makes a new vector from an angle
local function fromAngle(theta)
	return new(math.cos(theta), -math.sin(theta))
end

-- makes a vector with a random direction
local function random()
	return fromAngle(rand() * math.pi*2)
end

-- check if an object is a vector
local function isVector(t)
	return getmetatable(t) == vector
end

-- set the values of the vector to something new
function vector:set(x,y)
	if isVector(x) then self.x, self.y = x.x, x.y;return self end
	self.x, self.y = x or self.x, y or self.y
	return self
end

-- replace the values of a vector with the values of another vector
function vector:replace(v)
	assert(isVector(v), "replace: wrong argument type: (expected <vector>, got "..type(v)..")")
	self.x, self.y = v.x, v.y
	return self
end

-- returns a copy of a vector
function vector:clone()
	return new(self.x, self.y)
end

-- get the magnitude of a vector
function vector:getMag()
	return math.sqrt(self.x^2 + self.y^2)
end

-- get the magnitude squared of a vector
function vector:magSq()
	return self.x^2 + self.y^2
end

-- set the magnitude of a vector
function vector:setMag(mag)
	self:norm()
	local v = self * mag
	self:replace(v)
	return self
end

-- reflects the vector along another vector
function vector:reflect(normal, multiplier)
	multiplier = multiplier == nil and 1 or multiplier
	local n = normal:clone():norm()
	--self:replace(self - (1 + multiplier) * (self:dot(n)) * n)
	self:replace(self - (1 + multiplier) * (self:dot(n) * n))
	return self
end

--[[ take the vector and stretch it along another vector v by a factor *factor*
so e.g. a:stretch(v, -0.6) gives *b*
_____________________
|					|
|	  \ 			|
|	   \_________	|
|	   /\	  a		|
|	b /	 \			|
|	 /	  \			|
|		   \ v		|
|					|
^^^^^^^^^^^^^^^^^^^]]
function vector:stretch(v, factor)
	local normalized = v:clone():norm()
	local compParallel = self:dot(normalized) * normalized
	local compPerpendicular = self - self:dot(normalized) * normalized
	compPerpendicular:setMag(compPerpendicular:getMag() * factor)
	self:set(compParallel + compPerpendicular)
	return self
end

-- returns a vector projected onto vector *v*
function vector:projectOnto(v)
	local normalized = v:clone():norm()
	return self:dot(normalized) * normalized
end


-- meta function to make vectors negative
-- ex: (negative) -vector(5,6) is the same as vector(-5,-6)
function vector.__unm(v)
	return new(-v.x, -v.y)
end

-- meta function to add vectors together
-- ex: (vector(5,6) + vector(6,5)) is the same as vector(11,11)
function vector.__add(a,b)
	assert(isVector(a) and isVector(b), "add: wrong argument types: (expected <vector> and <vector>)")
	return new(a.x+b.x, a.y+b.y)
end

-- meta function to subtract vectors
function vector.__sub(a,b)
	assert(isVector(a) and isVector(b), "sub: wrong argument types: (expected <vector> and <vector>)")
	return new(a.x-b.x, a.y-b.y)
end

-- meta function to multiply vectors
function vector.__mul(a,b)
	if type(a) == 'number' then 
		return new(a * b.x, a * b.y)
	elseif type(b) == 'number' then
		return new(a.x * b, a.y * b)
	else
		assert(isVector(a) and isVector(b),  "mul: wrong argument types: (expected <vector> or <number>)")
		return new(a.x*b.x, a.y*b.y)
	end
end

-- meta function to divide vectors
function vector.__div(a,b)
	assert(isVector(a) and type(b) == "number", "div: wrong argument types (expected <vector> and <number>)")
	return new(a.x/b, a.y/b)
end

-- meta function to check if vectors have the same values
function vector.__eq(a,b)
	assert(isVector(a) and isVector(b), "eq: wrong argument types (expected <vector> and <vector>)")
	return a.x==b.x and a.y==b.y
end

-- meta function to change how vectors appear as string
-- ex: print(vector(2,8)) - this prints '(2,8)'
function vector:__tostring()
	return "("..self.x..", "..self.y..")"
end

-- get the distance between two vectors
function vector.dist(a,b)
	assert(isVector(a) and isVector(b), "dist: wrong argument types (expected <vector> and <vector>)")
	return math.sqrt((a.x-b.x)^2 + (a.y-b.y)^2)
end

-- return the dot product of the vector
function vector:dot(v)
	assert(isVector(v), "dot: wrong argument type (expected <vector>)")
	return self.x * v.x + self.y * v.y
end

-- normalize the vector (give it a magnitude of 1)
function vector:norm()
	local m = self:getMag()
	if m~=0 then
		self:replace(self / m)
	end
	return self
end

-- limit the vector to a certain amount
function vector:limit(max)
	assert(type(max) == 'number', "limit: wrong argument type (expected <number>)")
	local mSq = self:magSq()
	if mSq > max^2 then
		self:setMag(max)
	end
	return self
end

-- Clamp each axis between max and min's corresponding axis
function vector:clamp(min, max)
	assert(isVector(min) and isVector(max), "clamp: wrong argument type (expected <vector> and <vector>)")
	local x = math.min( math.max( self.x, min.x ), max.x )
	local y = math.min( math.max( self.y, min.y ), max.y )
	self:set(x,y)
	return self
end

-- get the heading (direction) of a vector
function vector:heading()
	return -math.atan2(self.y, self.x)
end

-- returns the smallest angle between the two vectors
function vector:angleDiff(v)
	return math.min((self:heading() - v:heading()) % (math.pi*2), (v:heading() - self:heading()) % (math.pi*2))
end

-- rotate a vector by a certain number of radians
function vector:rotate(theta) -- edited to pull from: https://github.com/themousery/vector.lua/pull/3/commits/5ac47a29456a6f89939347f6b3b4d3160d732d3c
	local s = math.sin(theta)
	local c = math.cos(theta)
	local v = new(
		(c * self.x) + (s * self.y),
		-(s * self.x) + (c * self.y))
	self:replace(v)
  return self
end

-- rotate vector by a certain number of radians around a point
function vector:pivot(theta, v)
	self:set(self.x - v.x, self.y - v.y) -- move to origin
	self:rotate(theta) -- rotate around origin
	self:set(v.x + self.x, v.y + self.y) -- move back to old position with rotation applied
	return self
end

-- return x and y of vector as a regular array
function vector:array()
	return {self.x, self.y}
end

-- return x and y of vector, unpacked from table
function vector:unpack()
	return self.x, self.y
end


-- pack up and return module
module.new = new
module.random = random
module.fromAngle = fromAngle
module.isVector = isVector
return setmetatable(module, {__call = function(_,...) return new(...) end})
