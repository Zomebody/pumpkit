
local module = {}

local numbercurve = {}
numbercurve.__index = numbercurve


-- check if an object is a numbercurve
local function isNumbercurve(t)
	return getmetatable(t) == numbercurve
end


local function new(...) -- either a sequence of {0, color()}, {0.1, color()}, etc. or simply 0, color(), 0.1, color(), 0.4, color(), etc.
	local args = {...}
	if #args < 2 then
		error("<numbercurve> must be created with at least 2 nodes.")
	end

	local numcu = {
		["nodes"] = {};
	}

	local i = 0
	while i < #args do
		i = i + 1
		if type(args[i]) == "table" then
			numcu.nodes[#numcu.nodes + 1] = {args[i][1], args[i][2]}
		else
			numcu.nodes[#numcu.nodes + 1] = {args[i], args[i + 1]}
			i = i + 1
		end
		assert(type(numcu.nodes[#numcu.nodes][1]) == "number", ("<numbercurve> is being created with a non-number value in the spot of a number at node %d."):format(#numcu.nodes))
		assert(type(numcu.nodes[#numcu.nodes][2]) == "number", ("<numbercurve> is being created with a non-number value in the spot of a color at node %d."):format(#numcu.nodes))
	end

	-- evaluate if the numbercurve has nodes in ascending order w/ the right starting point and end point
	if numcu.nodes[1][1] ~= 0 then
		error(("<numbercurve> must start with its first node at value '0', given is %.3f."):format(numcu.nodes[1][1]))
	end
	if numcu.nodes[#numcu.nodes][1] ~= 1 then
		error(("<numbercurve> must end with its last node at value '1', given is %.3f."):format(numcu.nodes[#numcu.nodes][1]))
	end
	for i = 1, #numcu.nodes - 1 do
		if numcu.nodes[i][1] > numcu.nodes[i + 1][1] then
			error("<numbercurve> is being created with nodes that are not in ascending order.")
		end
	end

	return setmetatable(numcu, numbercurve)
end



function numbercurve:clone()
	return new(unpack(self.nodes))
end



function numbercurve:getNumber(x)
	assert(x >= 0 and x <= 1, ("numbercurve:getNumber(x) expects argument 'x' to be a decimal number in the range [0, 1]. Given is %.3f"):format(x))
	local i = 1
	while self.nodes[i][1] <= x do
		if self.nodes[i][1] == x then
			return self.nodes[i][2]
		end
		i = i + 1
	end
	-- use i to get the color from the right node
	local num1 = self.nodes[i - 1][2]
	local num2 = self.nodes[i][2]
	local x1 = self.nodes[i - 1][1]
	local x2 = self.nodes[i][1]
	local alpha = (x - x1) / (x2 - x1)
	return num1 * (1 - alpha) + num2 * alpha
end



-- pack up and return module
module.new = new
module.isNumbercurve = isNumbercurve
return setmetatable(module, {__call = function(_, ...) return new(...) end})