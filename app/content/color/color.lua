

local ui = require("framework.ui")
local vector = require("framework.datatypes.vector")
local color = require("framework.datatypes.color")


local meta = {
	["Name"] = "color";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The color data type";
	["Description"] = "An object representing a single color.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Properties";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "r";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The red component of the color. This is a value from 0 and 1.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "g";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The green component of the color. This is a value from 0 and 1.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "b";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The blue component of the color. This is a value from 0 and 1.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "a";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The alpha component of the color. This is a value from 0 and 1.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "array";
	["Arguments"] = {};
	["Description"] = "Returns an array representing the color, as {r,g,b,a}.";
})


return {
	["Meta"] = meta;
	["Content"] = content;
}