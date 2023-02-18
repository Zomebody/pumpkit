
local module = {}

local gradient = {}
gradient.__index = gradient


-- check if an object is a gradient
local function isGradient(t)
	return getmetatable(t) == gradient
end


local function new(...) -- either a sequence of {0, color()}, {0.1, color()}, etc. or simply 0, color(), 0.1, color(), 0.4, color(), etc.
	local args = {...}
	if #args < 2 then
		error("<gradient> must be created with at least 2 nodes.")
	end

	local gra = {
		["nodes"] = {};
	}

	local i = 0
	while i < #args do
		i = i + 1
		if type(args[i]) == "table" then
			gra.nodes[#gra.nodes + 1] = {args[i][1], args[i][2]}
		else
			gra.nodes[#gra.nodes + 1] = {args[i], args[i + 1]}
			i = i + 1
		end
		assert(type(gra.nodes[#gra.nodes][1]) == "number", ("<gradient> is being created with a non-number value in the spot of a number at node %d."):format(#gra.nodes))
		assert(color.isColor(gra.nodes[#gra.nodes][2]), ("<gradient> is being created with a non-color value in the spot of a color at node %d."):format(#gra.nodes))
	end

	-- evaluate if the gradient has nodes in ascending order w/ the right starting point and end point
	if gra.nodes[1][1] ~= 0 then
		error(("<gradient> must start with its first node at value '0', given is %.3f."):format(gra.nodes[1][1]))
	end
	if gra.nodes[#gra.nodes][1] ~= 1 then
		error(("<gradient> must end with its last node at value '1', given is %.3f."):format(gra.nodes[#gra.nodes][1]))
	end
	for i = 1, #gra.nodes - 1 do
		if gra.nodes[i][1] > gra.nodes[i + 1][1] then
			error("<gradient> is being created with nodes that are not in ascending order.")
		end
	end

	return setmetatable(gra, gradient)
end



function gradient:clone()
	return new(self.nodes)
end



function gradient:getColor(x)
	assert(x >= 0 and x <= 1, ("gradient:getColor(x) expects argument 'x' to be a decimal number in the range [0, 1]. Given is %.3f"):format(x))
	local i = 1
	while self.nodes[i][1] <= x do
		if self.nodes[i][1] == x then
			return self.nodes[i][2]:clone()
		end
		i = i + 1
	end
	-- use i to get the color from the right node
	local colFrom = self.nodes[i - 1][2]
	local colTo = self.nodes[i][2]
	local x1 = self.nodes[i - 1][1]
	local x2 = self.nodes[i][1]
	return color.interpolate(colFrom, colTo, (x - x1) / (x2 - x1))
end



-- pack up and return module
module.new = new
module.isGradient = isGradient
return setmetatable(module, {__call = function(_, ...) return new(...) end})