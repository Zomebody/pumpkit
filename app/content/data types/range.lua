
local meta = {
	["Name"] = "range";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The range data type";
	["Description"] = "An object representing a 1 dimensional range of numbers, from a given starting number to a given ending number.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Properties";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "min";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The lowest value in the range.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "max";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The highest value in the range.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "size";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The difference between the highest and lowest value in the range.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "clamp";
	["Arguments"] = {"x"};
	["Description"] = "Clamps the input number so that it falls within the range. If the input is smaller than the range's minimum, it returns the minimum. If it's larger than the maximum, it returns the maximum.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "clone";
	["Arguments"] = {};
	["Description"] = "Returns a new range with the same minimum and maximum values.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "contains";
	["Arguments"] = {"x"};
	["Description"] = "Returns true if the given value is at least as large as the minimum value and at most as large as the maximum value.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "interpolate";
	["Arguments"] = {"x"};
	["Description"] = "Interpolates from the range's minimum to the maximum by the given amount. 'x' may also be negative or larger than 1.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "intersection";
	["Arguments"] = {"range"};
	["Description"] = "If two ranges overlap, this returns a new range that is exactly the intersection of those two ranges. Otherwise, it returns nil.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "intersects";
	["Arguments"] = {"range"};
	["Description"] = "Returns true if two ranges overlap.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "randomDecimal";
	["Arguments"] = {"mode"};
	["Description"] = "Returns a random decimal numbers within the given range. 'mode' can be set to nil or 'default' for a truly random value, or 'concentrated' for values that trend towards the center of the range.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "randomInt";
	["Arguments"] = {"mode"};
	["Description"] = "Returns a random integer within the given range. This will error if the range has a non-integer minimum or maximum. 'mode' can be set to nil or 'default' for a truly random value, or 'concentrated' for values that trend towards the center of the range.\n\nBelow is an example from the range 1-40 with 10.000 samples.";
	["Demo"] = function()
		local canvas = love.graphics.newCanvas(200, 100)
		canvas:renderTo(
			function()
				local r, g, b, a = love.graphics.getColor()
				love.graphics.setColor(0, 0, 0, 1)
				love.graphics.rectangle("fill", 0, 0, 400, 100)
				local rng = range(1, 40)
				local values = {}
				for i = 1, 10000 do
					local v = rng:randomInt("concentrated")
					values[v] = (values[v] == nil and 1 or values[v] + 1)
				end
				local highest = 1
				for k, v in pairs(values) do
					highest = math.max(highest, v)
				end
				love.graphics.setColor(1, 1, 0)
				for i = 1, 40 do
					if values[i] ~= nil then
						local height = values[i] / highest * 90
						love.graphics.rectangle("fill", (i - 1) * 5 + 1, 95 - height, 3, height)
					end
				end
				love.graphics.setColor(r, g, b, a)
			end
		)
		return ui.newImageFrame(canvas)
	end
})




table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__add";
	["Arguments"] = {"range"};
	["Description"] = "Return a new range with the sum of the two ranges' minimum and maximum values.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__div";
	["Arguments"] = {"range"};
	["Description"] = "Returns a new range with the first range's minimum and maximum values divided by the second range's minimum and maximum.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__mul";
	["Arguments"] = {"range"};
	["Description"] = "Returns a new range with the first range's minimum and maximum values multiplied by the second range's minimum and maximum.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__sub";
	["Arguments"] = {"range"};
	["Description"] = "Returns a new range with the second range's minimum and maximum values subtracted from the first range's minimum and maximum.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__tostring";
	["Arguments"] = {};
	["Description"] = "Prints the range.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__unm";
	["Arguments"] = {};
	["Description"] = "Makes the range negative.";
})


return {
	["Meta"] = meta;
	["Content"] = content;
}