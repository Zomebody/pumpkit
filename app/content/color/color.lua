

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

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "components";
	["Arguments"] = {};
	["Description"] = "Returns the r, g, b and a values individually in that order. This can be combined with love.graphics.setColor() to easily set the color.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "clone";
	["Arguments"] = {};
	["Description"] = "Constructs a new color object using the same r, g, b and a values.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "darken";
	["Arguments"] = {"value"};
	["Description"] = "Darkens the color towards black, where 0 is no change and 1 is pitch black.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "lighten";
	["Arguments"] = {"value"};
	["Description"] = "Lightens the color towards white, where 0 is no change and 1 is pure white.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getHSL";
	["Arguments"] = {};
	["Description"] = "TODO: implement this method.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getHSV";
	["Arguments"] = {};
	["Description"] = "Returns the h, s and v components of the color.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getHue";
	["Arguments"] = {};
	["Description"] = "TODO: implement this method.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "shiftHue";
	["Arguments"] = {"degrees"};
	["Description"] = "Shifts the hue by the given number of degrees. 360 degrees is a full circle, 0 degrees is no change.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "set";
	["Arguments"] = {"r", "g", "b", "a"};
	["Description"] = "Sets the r, g, b and a values of the color to the given new values.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "__tostring";
	["Arguments"] = {};
	["Description"] = "Prints the color in the form (r,g,b) where r, g and b are values from 0 to 255.";
})


return {
	["Meta"] = meta;
	["Content"] = content;
}