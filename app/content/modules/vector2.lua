
local meta = {
	["Name"] = "vector2";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The vector2 Module";
	["Description"] = "A module used to construct vector2s.";
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
	["Description"] = "Creates a new vector2 with a magnitude of 1 from the given angle in radians.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "new";
	["Arguments"] = {"x", "y"};
	["Description"] = "Constructs a vector2 with the given x and y values.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "random";
	["Arguments"] = {};
	["Description"] = "Creates a new vector2 with a magnitude of 1, rotated in a random direction.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "dist";
	["Arguments"] = {"vector2", "vector2"};
	["Description"] = "Returns the distance between two vector2s, using Pythagoras.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "isVector2";
	["Arguments"] = {"Object"};
	["Description"] = "Checks if the given object is a vector2 instance. Returns true if so.";
})

return {
	["Meta"] = meta;
	["Content"] = content;
}