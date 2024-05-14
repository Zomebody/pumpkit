
local meta = {
	["Name"] = "numbercurve";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The numbercurve data type";
	["Description"] = "An object representing a 2D triangle. Internally, a triangle is constructed from a 3 line variables.";
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
	["Description"] = "Creates and returns a new numbercurve with the same structure.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getNumber";
	["Arguments"] = {"x"};
	["Description"] = "Returns a number on the number curve. The passed value must be between 0 and 1. The curve exists out of linear segments, so the returned value linearly interpolates between the nearest point to its left and right.";
})


return {
	["Meta"] = meta;
	["Content"] = content;
}