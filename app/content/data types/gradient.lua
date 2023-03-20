
local meta = {
	["Name"] = "gradient";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The gradient data type";
	["Description"] = "An object representing a gradient of colors.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Properties";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "clone";
	["Arguments"] = {};
	["Description"] = "Creates and returns a new gradient with the same structure.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getColor";
	["Arguments"] = {"x"};
	["Description"] = "Returns the color at a given position in the gradient. The given number 'x' must be at least 0 and at most 1.";
})


return {
	["Meta"] = meta;
	["Content"] = content;
}