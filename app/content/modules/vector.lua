

local getpath = require("framework.getpath")
local ui = require(getpath("framework/modules/ui"))
local vector = require(getpath("framework/datatypes/vector"))
local color = require(getpath("framework/datatypes/color"))


local meta = {
	["Name"] = "vector";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The vector Module";
	["Description"] = "A module used to construct vectors.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Constructors";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "fromAngle";
	["Arguments"] = {"angle"};
	["Description"] = "Creates a new vector with a magnitude of 1 from the given angle in radians.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "new";
	["Arguments"] = {"x", "y"};
	["Description"] = "Constructs a vector with the given x and y values.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "random";
	["Arguments"] = {};
	["Description"] = "Creates a new vector with a magnitude of 1, rotated in a random direction.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "dist";
	["Arguments"] = {"vector", "vector"};
	["Description"] = "Returns the distance between two vectors, using Pythagoras.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "isVector";
	["Arguments"] = {"Object"};
	["Description"] = "Checks if the given object is a vector instance. Returns true if so.";
})

return {
	["Meta"] = meta;
	["Content"] = content;
}