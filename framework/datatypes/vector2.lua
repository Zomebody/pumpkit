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
local vector2 = {}
vector2.__index = vector2

-- check if an object is a vector
local function isVector2(t)
	return getmetatable(t) == vector2
end

-- get a random function from Love2d or base lua, in that order.
local rand = math.random
if love and love.math then rand = love.math.random end

-- makes a new vector2
local function new(x, y)
	if isVector2(x) then
		return setmetatable({x=x.x or 0, y=x.y or 0}, vector2)
	else
		return setmetatable({x=x or 0, y=y or 0}, vector2)
	end
end

-- makes a new vector2 from an angle
local function fromAngle(theta)
	return new(math.cos(theta), math.sin(theta))
end

-- makes a vector2 with a random direction
local function random()
	return fromAngle(rand() * math.pi*2)
end

-- set the values of the vector2 to something new
function vector2:set(x,y)
	if isVector2(x) then self.x, self.y = x.x, x.y;return self end
	self.x, self.y = x or self.x, y or self.y
	return self
end

-- replace the values of a vector2 with the values of another vector2
function vector2:replace(v)
	assert(isVector2(v), "replace: wrong argument type: (expected <vector2>, got "..type(v)..")")
	self.x, self.y = v.x, v.y
	return self
end

-- returns a copy of a vector2
function vector2:clone()
	return new(self.x, self.y)
end

-- get the magnitude of a vector2
function vector2:getMag()
	return math.sqrt(self.x^2 + self.y^2)
end

-- get the magnitude squared of a vector2
function vector2:magSq()
	return self.x^2 + self.y^2
end

-- set the magnitude of a vector2
function vector2:setMag(mag)
	self:norm()
	local v = self * mag
	self:replace(v)
	return self
end

-- reflects the vector2 along another vector2
function vector2:reflect(normal, multiplier)
	multiplier = multiplier == nil and 1 or multiplier
	local n = normal:clone():norm()
	self:replace(self - (1 + multiplier) * (self:dot(n) * n))
	return self
end

--[[ take the vector2 and stretch it along another vector2 v by a factor *factor*
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
function vector2:stretch(v, factor)
	local normalized = v:clone():norm()
	local compParallel = self:dot(normalized) * normalized
	local compPerpendicular = self - self:dot(normalized) * normalized
	compPerpendicular:setMag(compPerpendicular:getMag() * factor)
	self:set(compParallel + compPerpendicular)
	return self
end

-- returns a vector2 projected onto vector2 *v*
function vector2:projectOnto(v)
	local normalized = v:clone():norm()
	return self:dot(normalized) * normalized
end


-- meta function to make vector2s negative
-- ex: (negative) -vector2(5,6) is the same as vector2(-5,-6)
function vector2.__unm(v)
	return new(-v.x, -v.y)
end

-- meta function to add vector2s together
-- ex: (vector2(5,6) + vector2(6,5)) is the same as vector2(11,11)
function vector2.__add(a,b)
	assert(isVector2(a) and isVector2(b), "add: wrong argument types: (expected <vector2> and <vector2>)")
	return new(a.x+b.x, a.y+b.y)
end

-- meta function to subtract vectors
function vector2.__sub(a,b)
	assert(isVector2(a) and isVector2(b), "sub: wrong argument types: (expected <vector2> and <vector2>)")
	return new(a.x-b.x, a.y-b.y)
end

-- meta function to multiply vectors
function vector2.__mul(a,b)
	if type(a) == 'number' then 
		return new(a * b.x, a * b.y)
	elseif type(b) == 'number' then
		return new(a.x * b, a.y * b)
	else
		assert(isVector2(a) and isVector2(b),  "mul: wrong argument types: (expected <vector2> or <number>)")
		return new(a.x*b.x, a.y*b.y)
	end
end

-- meta function to divide vector2s
function vector2.__div(a,b)
	assert(isVector2(a) and type(b) == "number", "div: wrong argument types (expected <vector2> and <number>)")
	return new(a.x/b, a.y/b)
end

-- meta function to check if vector2s have the same values
function vector2.__eq(a,b)
	assert(isVector2(a) and isVector2(b), "eq: wrong argument types (expected <vector2> and <vector2>)")
	return a.x==b.x and a.y==b.y
end

-- meta function to change how vector2s appear as string
-- ex: print(vector2(2,8)) - this prints '(2,8)'
function vector2:__tostring()
	return "("..self.x..", "..self.y..")"
end

-- get the distance between two vector2s
function vector2:dist(v)
	assert(isVector2(v), "dist: wrong argument types (expected <vector> and <vector>)")
	return math.sqrt((self.x - v.x)^2 + (self.y - v.y)^2)
end

-- return the dot product of the vector2
function vector2:dot(v)
	assert(isVector2(v), "dot: wrong argument type (expected <vector2>)")
	return self.x * v.x + self.y * v.y
end

-- normalize the vector2 (give it a magnitude of 1)
function vector2:norm()
	local m = self:getMag()
	if m~=0 then
		self:replace(self / m)
	end
	return self
end

-- limit the vector2 to a certain magnitude
function vector2:limit(max)
	assert(type(max) == 'number', "limit: wrong argument type (expected <number>)")
	local mSq = self:magSq()
	if mSq > max^2 then
		self:setMag(max)
	end
	return self
end

-- Clamp each axis between max and min's corresponding axis
function vector2:clamp(min, max)
	assert(isVector2(min) and isVector2(max), "clamp: wrong argument type (expected <vector2> and <vector2>)")
	local x = math.min( math.max( self.x, min.x ), max.x )
	local y = math.min( math.max( self.y, min.y ), max.y )
	self:set(x, y)
	return self
end

-- get the heading (direction) of a vector2
function vector2:heading()
	return math.atan2(self.y, self.x) -- the negative sign here is because a positive Y in Love2D is down!!
end

-- returns the smallest angle between the two vector2s
function vector2:angleDiff(v)
	return math.min((self:heading() - v:heading()) % (math.pi*2), (v:heading() - self:heading()) % (math.pi*2))
end

-- TODO: document this method!!
-- return a vector2 that rotates the current vector2 to the given vector2
function vector2:rotateTo(vec2, byAngle)
	local angDiff = self:angleDiff(vec2)
	if angDiff < byAngle then
		return self:replace(vec2:clone():setMag(self:getMag()))
	end
	local angleA = self:heading()
	local angleB = vec2:heading()
	local absDiff = math.abs(angleA - angleB)
	if absDiff > math.pi then
		if angleA < angleB then
			angleA = angleA + math.pi*2
			local newA = (angleA - byAngle) % 360
			return self:replace(fromAngle(newA):setMag(self:getMag()))
		else
			angleB = angleB + math.pi*2
			local newA = (angleA + byAngle) % 360
			return self:replace(fromAngle(newA):setMag(self:getMag()))
		end
	elseif angleB > angleA then
		return self:replace(fromAngle(angleA + byAngle):setMag(self:getMag()))
	else
		return self:replace(fromAngle(angleA - byAngle):setMag(self:getMag()))
	end
end

-- rotate a vector2 by a certain number of radians
function vector2:rotate(theta) -- edited to pull from: https://github.com/themousery/vector.lua/pull/3/commits/5ac47a29456a6f89939347f6b3b4d3160d732d3c
	--theta = -theta -- make theta negative because the Y-direction in Love2D is DOWN rather than UP
	local s = math.sin(theta)
	local c = math.cos(theta)
	local v = new(
		(c * self.x) + (s * self.y),
		-(s * self.x) + (c * self.y))
	self:replace(v)
	return self
end

-- rotate vector2 by a certain number of radians around a point
function vector2:pivot(theta, v)
	self:set(self.x - v.x, self.y - v.y) -- move to origin
	self:rotate(theta) -- rotate around origin
	self:set(v.x + self.x, v.y + self.y) -- move back to old position with rotation applied
	return self
end

-- return x and y of vector2 as a regular array
function vector2:array()
	return {self.x, self.y}
end

-- return x and y of vector2, unpacked from table
function vector2:unpack()
	return self.x, self.y
end


-- pack up and return module
module.new = new
module.random = random
module.fromAngle = fromAngle
module.isVector2 = isVector2
return setmetatable(module, {__call = function(_,...) return new(...) end})
